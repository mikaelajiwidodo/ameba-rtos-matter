#!/usr/bin/env python3
"""
Ameba Camera WebRTC Signaling Server

A simple WebSocket-based signaling server that relays SDP offers/answers
and ICE candidates between a camera (Ameba device) and viewers (test clients).

Usage:
    python3 signaling_server.py [--host 0.0.0.0] [--port 8765]

Protocol:
    Clients connect via WebSocket and send JSON messages.
    
    Register:
        {"type": "register", "role": "camera"}        # Camera device
        {"type": "register", "role": "viewer"}         # Viewer client
    
    Messages relayed between camera and viewer:
        {"type": "sdp", "sdp": "...", "sdp_type": "offer/answer"}
        {"type": "ice", "candidate": "...", "mid": "..."}
        {"type": "end", "reason": "..."}
"""

import asyncio
import json
import logging
import argparse
import signal
import sys

try:
    import websockets
except ImportError:
    print("ERROR: 'websockets' package not found. Install with: pip3 install websockets")
    sys.exit(1)

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%H:%M:%S",
)
log = logging.getLogger("signaling")


class SignalingServer:
    """
    WebSocket signaling server that pairs one camera with multiple viewers.
    """

    def __init__(self):
        self.camera_ws = None       # Single camera connection
        self.viewers = {}           # {websocket: viewer_id}
        self.next_viewer_id = 1
        self.camera_ready = asyncio.Event()
        log.info("Signaling server initialized")

    async def handle_client(self, websocket):
        """Handle an incoming WebSocket connection."""
        role = None
        viewer_id = None

        try:
            async for raw in websocket:
                try:
                    msg = json.loads(raw)
                except json.JSONDecodeError as e:
                    log.warning(f"Invalid JSON: {e}")
                    continue

                msg_type = msg.get("type")

                if msg_type == "register":
                    role = msg.get("role")
                    if role == "camera":
                        if self.camera_ws is not None:
                            old_ws = self.camera_ws
                            self.camera_ws = None
                            self.camera_ready.clear()
                            log.info("Camera replaced, closing old connection")
                            await self._safe_close(old_ws, "Camera replaced")
                        self.camera_ws = websocket
                        self.camera_ready.set()
                        log.info("Camera registered")
                        await self._send(websocket, {"type": "registered", "role": "camera"})
                        # Notify all viewers that camera is ready
                        await self._broadcast_viewers({
                            "type": "camera_ready",
                            "message": "Camera is connected and ready"
                        })

                    elif role == "viewer":
                        viewer_id = self.next_viewer_id
                        self.next_viewer_id += 1
                        self.viewers[websocket] = viewer_id
                        log.info(f"Viewer #{viewer_id} registered")
                        await self._send(websocket, {
                            "type": "registered",
                            "role": "viewer",
                            "viewer_id": viewer_id
                        })
                        # Notify viewer if camera is ready
                        if self.camera_ws is not None:
                            await self._send(websocket, {
                                "type": "camera_ready",
                                "message": "Camera is already connected"
                            })
                    else:
                        log.warning(f"Unknown role: {role}")
                        await self._send(websocket, {
                            "type": "error",
                            "message": f"Unknown role: {role}"
                        })

                elif msg_type == "sdp":
                    sdp = msg.get("sdp", "")
                    sdp_type = msg.get("sdp_type", "offer")
                    log.info(f"SDP {sdp_type} from {role or 'unknown'} "
                             f"({len(sdp)} bytes)")

                    if role == "camera" and self.viewers:
                        # Relay camera's SDP to all viewers
                        await self._broadcast_viewers({
                            "type": "sdp", "sdp": sdp, "sdp_type": sdp_type
                        })
                    elif role == "viewer" and self.camera_ws:
                        # Relay viewer's SDP to camera
                        await self._send(self.camera_ws, {
                            "type": "sdp", "sdp": sdp, "sdp_type": sdp_type
                        })
                    else:
                        log.warning(f"No peer to relay SDP to (role={role})")

                elif msg_type == "ice":
                    candidate = msg.get("candidate", "")
                    mid = msg.get("mid", "")
                    log.info(f"ICE candidate from {role}: mid={mid}, "
                             f"candidate={candidate[:60]}...")

                    if role == "camera" and self.viewers:
                        await self._broadcast_viewers({
                            "type": "ice", "candidate": candidate, "mid": mid
                        })
                    elif role == "viewer" and self.camera_ws:
                        await self._send(self.camera_ws, {
                            "type": "ice", "candidate": candidate, "mid": mid
                        })
                    else:
                        log.warning(f"No peer to relay ICE candidate (role={role})")

                elif msg_type == "end":
                    reason = msg.get("reason", "Unknown")
                    log.info(f"Session end from {role}: {reason}")

                    if role == "camera" and self.viewers:
                        await self._broadcast_viewers({
                            "type": "end", "reason": reason
                        })
                    elif role == "viewer" and self.camera_ws:
                        await self._send(self.camera_ws, {
                            "type": "end", "reason": reason
                        })

                elif msg_type == "ping":
                    await self._send(websocket, {"type": "pong"})

                else:
                    log.warning(f"Unknown message type: {msg_type}")

        except websockets.exceptions.ConnectionClosed as e:
            log.info(f"Connection closed: {e}")
        except Exception as e:
            log.error(f"Error handling client: {e}")
        finally:
            # Cleanup on disconnect
            if role == "camera":
                self.camera_ws = None
                self.camera_ready.clear()
                log.info("Camera disconnected")
                await self._broadcast_viewers({
                    "type": "camera_disconnected",
                    "message": "Camera has disconnected"
                })
            elif role == "viewer" and websocket in self.viewers:
                vid = self.viewers.pop(websocket)
                log.info(f"Viewer #{vid} disconnected")
            else:
                # Unknown client disconnected
                pass

    async def _send(self, ws, msg):
        """Send a JSON message to a WebSocket client."""
        try:
            await ws.send(json.dumps(msg))
        except Exception as e:
            log.warning(f"Send failed: {e}")

    async def _broadcast_viewers(self, msg):
        """Send a message to all connected viewers."""
        payload = json.dumps(msg)
        disconnected = []
        for ws, vid in self.viewers.items():
            try:
                await ws.send(payload)
            except Exception:
                disconnected.append(ws)
        for ws in disconnected:
            self.viewers.pop(ws, None)
            log.info(f"Removed disconnected viewer during broadcast")

    async def _safe_close(self, ws, reason=""):
        """Safely close a WebSocket connection."""
        try:
            await ws.close(code=1000, reason=reason)
        except Exception:
            pass

    async def status_reporter(self, interval=10):
        """Periodically log connection status."""
        while True:
            await asyncio.sleep(interval)
            camera_status = "connected" if self.camera_ws else "disconnected"
            viewer_count = len(self.viewers)
            log.info(f"Status — camera: {camera_status}, "
                     f"viewers: {viewer_count}")


async def main():
    parser = argparse.ArgumentParser(
        description="Ameba Camera WebRTC Signaling Server"
    )
    parser.add_argument("--host", default="0.0.0.0",
                        help="Host to bind (default: 0.0.0.0)")
    parser.add_argument("--port", type=int, default=8765,
                        help="Port to listen on (default: 8765)")
    parser.add_argument("--debug", action="store_true",
                        help="Enable debug logging")
    args = parser.parse_args()

    if args.debug:
        logging.getLogger().setLevel(logging.DEBUG)

    server = SignalingServer()

    stop = asyncio.Future()

    def shutdown():
        if not stop.done():
            stop.set_result(None)

    loop = asyncio.get_event_loop()
    for sig in (signal.SIGINT, signal.SIGTERM):
        try:
            loop.add_signal_handler(sig, shutdown)
        except NotImplementedError:
            # Windows fallback
            signal.signal(sig, lambda s, f: shutdown())

    async with websockets.serve(
        server.handle_client,
        host=args.host,
        port=args.port,
        ping_interval=30,
        ping_timeout=10,
    ):
        log.info(f"Signaling server listening on ws://{args.host}:{args.port}")
        log.info("Clients connect via WebSocket and send JSON messages")
        log.info("  Register as camera: {\"type\": \"register\", \"role\": \"camera\"}")
        log.info("  Register as viewer: {\"type\": \"register\", \"role\": \"viewer\"}")

        # Start periodic status reporter
        status_task = asyncio.create_task(server.status_reporter())

        try:
            await stop
        except asyncio.CancelledError:
            pass
        finally:
            status_task.cancel()
            log.info("Shutting down...")


if __name__ == "__main__":
    asyncio.run(main())
