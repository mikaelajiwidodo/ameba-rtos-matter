#!/usr/bin/env python3
"""
Ameba Camera WebRTC Test Client

A lightweight Python test client that connects to the camera via the
signaling server. Receives RTP/H.264 video packets on a UDP socket and
saves them to a file for analysis.

This client acts as a simplified WebRTC viewer:
  1. Connects to the signaling server (WebSocket) as a viewer
  2. Relays SDP/ICE between camera and this client
  3. Opens a UDP port to receive RTP video from the camera
  4. Parses RTP headers and saves H.264 raw stream to file
  5. Logs packet statistics

Usage:
    python3 test_client.py --server ws://192.168.1.100:8765

Dependencies:
    pip3 install websockets numpy

The resulting output.h264 file can be played with:
    ffplay output.h264
    ffmpeg -i output.h264 -c:v copy output.mp4
"""

import asyncio
import json
import logging
import socket
import struct
import argparse
import sys
import os
import time
from datetime import datetime

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
log = logging.getLogger("client")

# ─── RTP Constants ───────────────────────────────────────────────
RTP_HEADER_SIZE = 12
H264_NAL_FU_A = 28        # FU-A fragmentation unit
H264_NAL_STAP_A = 24      # STAP-A aggregation packet
H264_NAL_SINGLE_MIN = 1
H264_NAL_SINGLE_MAX = 23

# ─── RTP Statistics ──────────────────────────────────────────────
class RTPStats:
    def __init__(self):
        self.total_packets = 0
        self.total_bytes = 0
        self.first_seq = None
        self.last_seq = None
        self.first_ts = None
        self.last_ts = None
        self.lost_packets = 0
        self.duplicate_packets = 0
        self.reordered_packets = 0
        self.seqs_seen = set()
        self.start_time = None

    def record(self, seq, ts, size):
        if self.start_time is None:
            self.start_time = time.time()
        self.total_packets += 1
        self.total_bytes += size

        if self.first_seq is None:
            self.first_seq = seq
            self.first_ts = ts
        self.last_seq = seq
        self.last_ts = ts

        if seq in self.seqs_seen:
            self.duplicate_packets += 1
            return
        self.seqs_seen.add(seq)

    def report(self):
        elapsed = time.time() - (self.start_time or time.time())
        rate = self.total_bytes / (elapsed or 1) / 125000  # Mbps
        log.info("─" * 50)
        log.info("RTP RECEPTION STATISTICS")
        log.info(f"  Duration:        {elapsed:.1f} seconds")
        log.info(f"  Total packets:   {self.total_packets}")
        log.info(f"  Total data:      {self.total_bytes} bytes ({self.total_bytes/1024:.1f} KB)")
        log.info(f"  Bitrate:         {rate:.2f} Mbps")
        log.info(f"  Sequence range:  {self.first_seq} → {self.last_seq}")
        log.info(f"  Duplicates:      {self.duplicate_packets}")
        log.info("─" * 50)


# ─── RTP Packet Parser ───────────────────────────────────────────
def parse_rtp_header(data):
    """Parse RTP header from raw bytes."""
    if len(data) < RTP_HEADER_SIZE:
        return None

    b0 = data[0]
    b1 = data[1]
    version = (b0 >> 6) & 0x03
    padding = (b0 >> 5) & 0x01
    extension = (b0 >> 4) & 0x01
    csrc_count = b0 & 0x0F
    marker = (b1 >> 7) & 0x01
    payload_type = b1 & 0x7F

    seq = struct.unpack("!H", data[2:4])[0]
    ts = struct.unpack("!I", data[4:8])[0]
    ssrc = struct.unpack("!I", data[8:12])[0]

    header_size = RTP_HEADER_SIZE + (csrc_count * 4)
    payload = data[header_size:] if len(data) > header_size else b""

    return {
        "version": version,
        "padding": padding,
        "extension": extension,
        "marker": marker,
        "payload_type": payload_type,
        "sequence_number": seq,
        "timestamp": ts,
        "ssrc": ssrc,
        "payload": payload,
    }


def parse_h264_nal(data):
    """Parse the first NAL unit from RTP payload (handles FU-A)."""
    if len(data) < 2:
        return None

    nal_type = data[0] & 0x1F

    if nal_type == H264_NAL_FU_A:
        # FU-A: first byte is FU indicator, second is FU header
        fu_indicator = data[0]
        fu_header = data[1]
        start_bit = (fu_header >> 7) & 0x01
        end_bit = (fu_header >> 6) & 0x01
        original_nal_type = fu_header & 0x1F

        # Reconstruct NAL header from FU indicator + FU header type
        nal_header = bytes([(fu_indicator & 0xE0) | original_nal_type])
        nal_data = data[2:]
        return {
            "type": "FU-A",
            "nal_type": original_nal_type,
            "start": start_bit,
            "end": end_bit,
            "nal_header": nal_header,
            "data": nal_data,
            "is_video": original_nal_type in (1, 5, 7, 8),
        }
    elif nal_type <= H264_NAL_SINGLE_MAX:
        # Single NAL unit
        return {
            "type": "SINGLE",
            "nal_type": nal_type,
            "start": True,
            "end": True,
            "nal_header": data[:1],
            "data": data[1:],
            "is_video": nal_type in (1, 5, 7, 8),
        }
    else:
        return {
            "type": f"OTHER({nal_type})",
            "nal_type": nal_type,
            "start": True,
            "end": True,
            "nal_header": data[:1],
            "data": data[1:],
            "is_video": True,
        }


# ─── NAL Type Names ──────────────────────────────────────────────
NAL_TYPE_NAMES = {
    0: "Unspecified", 1: "CodedSlice", 2: "DataPartitionA",
    3: "DataPartitionB", 4: "DataPartitionC", 5: "IDR",
    6: "SEI", 7: "SPS", 8: "PPS", 9: "AccessUnitDelimiter",
    10: "EndOfSequence", 11: "EndOfStream", 12: "Filler",
    13: "SEIExt", 19: "AuxiliarySlice",
    24: "STAP-A", 25: "STAP-B", 26: "MTAP16", 27: "MTAP24",
    28: "FU-A", 29: "FU-B",
}


def nal_type_name(t):
    return NAL_TYPE_NAMES.get(t, f"Unknown({t})")


# ─── H.264 Stream Writer ─────────────────────────────────────────
class H264StreamWriter:
    """Reassembles H.264 NAL units from RTP and writes Annex-B stream."""

    START_CODE = b"\x00\x00\x00\x01"

    def __init__(self, filename="output.h264"):
        self.filename = filename
        self.file = open(filename, "wb")
        self.frag_buffer = {}       # {ssrc: (nal_header, data_parts)}
        self.nal_count = 0
        self.sps_count = 0
        self.pps_count = 0
        self.idr_count = 0
        self.slice_count = 0
        log.info(f"Writing H.264 stream to: {filename}")

    def write_nal(self, nal_header, nal_data, is_end=False):
        """Write a complete NAL unit to file with Annex-B start code."""
        nal_type = nal_header[0] & 0x1F
        self.file.write(self.START_CODE)
        self.file.write(nal_header)
        self.file.write(nal_data)
        self.file.flush()
        self.nal_count += 1

        if nal_type == 7:    self.sps_count += 1
        elif nal_type == 8:  self.pps_count += 1
        elif nal_type == 5:  self.idr_count += 1
        elif nal_type == 1:  self.slice_count += 1

        # Periodic stats
        if self.nal_count % 50 == 0:
            log.info(f"  NALs: {self.nal_count} total, "
                     f"SPS:{self.sps_count} PPS:{self.pps_count} "
                     f"IDR:{self.idr_count} Slice:{self.slice_count}")

    def process_rtp_payload(self, rtp_ts, payload):
        """Process RTP payload and reassemble H.264 NAL units."""
        if len(payload) < 2:
            return

        nal = parse_h264_nal(payload)
        if nal is None:
            return

        if nal["type"] == "FU-A":
            # Fragmentation Unit
            bitstream_id = (rtp_ts << 16)  # Use timestamp as key

            if nal["start"]:
                # Start of new fragment
                self.frag_buffer[bitstream_id] = [nal["nal_header"], b""]

            if bitstream_id in self.frag_buffer:
                parts = self.frag_buffer[bitstream_id]
                parts[1] += nal["data"]

                if nal["end"]:
                    # Complete NAL unit
                    self.write_nal(parts[0], parts[1])
                    del self.frag_buffer[bitstream_id]

        elif nal["type"] == "SINGLE":
            # Complete NAL unit
            self.write_nal(nal["nal_header"], nal["data"])

    def close(self):
        """Close the output file and print summary."""
        self.file.close()
        log.info(f"Stream saved to {self.filename} "
                 f"({os.path.getsize(self.filename)} bytes)")
        log.info(f"NAL units: {self.nal_count} total, "
                 f"SPS:{self.sps_count} PPS:{self.pps_count} "
                 f"IDR:{self.idr_count} Slice:{self.slice_count}")


# ─── Camera SDP Generator (mimics what camera would produce) ─────
def build_viewer_sdp(local_ip, local_port):
    """
    Build a minimal SDP answer that matches what the camera sends.
    The camera sends H.264 on payload type 96, Opus on 111.
    """
    ssrc_video = 42
    ssrc_audio = 43

    sdp = f"""v=0
o=- 0 0 IN IP4 {local_ip}
s=AmebaViewer
c=IN IP4 {local_ip}
t=0 0
a=group:BUNDLE video audio

m=video {local_port} UDP/TLS/RTP/SAVPF 96
c=IN IP4 {local_ip}
a=mid:video
a=recvonly
a=rtpmap:96 H264/90000
a=fmtp:96 packetization-mode=1;profile-level-id=42001f;level-asymmetry-allowed=1
a=ssrc:{ssrc_video} cname:viewer
a=ssrc:{ssrc_video} msid:viewer-stream video-track
a=msid:viewer-stream video-track

m=audio {local_port} UDP/TLS/RTP/SAVPF 111
c=IN IP4 {local_ip}
a=mid:audio
a=recvonly
a=rtpmap:111 opus/48000/2
a=ssrc:{ssrc_audio} cname:viewer
"""
    return sdp.strip()


# ─── Main Test Client ────────────────────────────────────────────
class WebRTCTestClient:
    """
    WebRTC test client that:
    1. Connects to signaling server as a viewer
    2. Opens a UDP port to receive video
    3. Relays SDP/ICE via signaling server
    4. Saves received H.264 stream to file
    """

    def __init__(self, server_url, local_ip=None, output_file="output.h264"):
        self.server_url = server_url
        self.output_file = output_file
        self.local_ip = local_ip or self._get_local_ip()
        self.ws = None
        self.udp_sock = None
        self.udp_port = 0
        self.running = True
        self.stats = RTPStats()
        self.stream = None  # H264StreamWriter
        self.camera_connected = False

    def _get_local_ip(self):
        """Get the local IP address."""
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            s.connect(("8.8.8.8", 80))
            ip = s.getsockname()[0]
            s.close()
            return ip
        except Exception:
            return "127.0.0.1"

    def _create_udp_socket(self):
        """Create a UDP socket for receiving RTP video."""
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        sock.bind(("0.0.0.0", 0))   # Bind to random port
        self.udp_port = sock.getsockname()[1]
        sock.setblocking(False)
        log.info(f"UDP receiver on port {self.udp_port} (IP: {self.local_ip})")
        return sock

    async def _handle_signaling(self):
        """Handle incoming signaling messages from server."""
        async for raw in self.ws:
            if not self.running:
                break
            try:
                msg = json.loads(raw)
            except json.JSONDecodeError:
                continue

            msg_type = msg.get("type")
            log.debug(f"Signaling ← {msg_type}")

            if msg_type == "registered":
                log.info(f"Registered as viewer #{msg.get('viewer_id')}")

            elif msg_type == "camera_ready":
                log.info("Camera is ready! Waiting for SDP offer...")

            elif msg_type == "camera_disconnected":
                log.warning("Camera disconnected!")
                self.camera_connected = False

            elif msg_type == "sdp":
                sdp = msg.get("sdp", "")
                sdp_type = msg.get("sdp_type", "")
                log.info(f"Received SDP {sdp_type} ({len(sdp)} bytes)")

                if sdp_type == "offer":
                    # Camera sent an offer — relay it as-is to the viewer
                    # (our client side just needs to receive RTP on the UDP port)
                    log.info(f"SDP Offer received. Ready to receive video on "
                             f"UDP port {self.udp_port}")

                    # Send a simple answer back
                    answer_sdp = build_viewer_sdp(self.local_ip, self.udp_port)
                    await self._send_signaling({
                        "type": "sdp",
                        "sdp": answer_sdp,
                        "sdp_type": "answer",
                    })
                    log.info("Sent SDP answer")

            elif msg_type == "ice":
                candidate = msg.get("candidate", "")
                mid = msg.get("mid", "")
                log.info(f"ICE candidate: mid={mid}")
                log.debug(f"  {candidate[:80]}...")

                # Extract IP and port from candidate for logging
                if "udp" in candidate:
                    parts = candidate.split()
                    if len(parts) >= 6:
                        cand_ip = parts[4]
                        cand_port = parts[5]
                        log.info(f"  → Camera media at {cand_ip}:{cand_port}")

            elif msg_type == "end":
                reason = msg.get("reason", "Unknown")
                log.warning(f"Session ended: {reason}")
                self.running = False

    async def _send_signaling(self, msg):
        """Send a JSON message to the signaling server."""
        if self.ws:
            try:
                await self.ws.send(json.dumps(msg))
            except Exception as e:
                log.error(f"Send signaling failed: {e}")

    async def _receive_udp_loop(self):
        """Receive RTP packets on UDP socket."""
        log.info("UDP receive loop started")

        while self.running:
            try:
                data, addr = self.udp_sock.recvfrom(65535)

                # Parse RTP header
                rtp = parse_rtp_header(data)
                if rtp is None or rtp["version"] != 2:
                    continue

                # Record stats
                self.stats.record(
                    rtp["sequence_number"],
                    rtp["timestamp"],
                    len(data)
                )

                # Process H.264 payload
                if rtp["payload_type"] == 96 and len(rtp["payload"]) > 0:
                    if self.stream is None:
                        self.stream = H264StreamWriter(self.output_file)
                    self.stream.process_rtp_payload(
                        rtp["timestamp"], rtp["payload"]
                    )

            except (BlockingIOError, socket.timeout):
                await asyncio.sleep(0.001)
            except Exception as e:
                if self.running:
                    log.debug(f"UDP recv error: {e}")

    async def run(self):
        """Run the test client."""
        log.info(f"Starting WebRTC test client")
        log.info(f"  Signaling server: {self.server_url}")
        log.info(f"  Local IP:         {self.local_ip}")
        log.info(f"  Output file:      {self.output_file}")

        # Create UDP socket
        self.udp_sock = self._create_udp_socket()

        # Connect to signaling server
        try:
            self.ws = await websockets.connect(
                self.server_url,
                ping_interval=30,
                ping_timeout=10,
            )
        except Exception as e:
            log.error(f"Failed to connect to signaling server: {e}")
            return

        log.info("Connected to signaling server")

        # Register as viewer
        await self._send_signaling({"type": "register", "role": "viewer"})

        # Start tasks
        signaling_task = asyncio.create_task(self._handle_signaling())
        udp_task = asyncio.create_task(self._receive_udp_loop())

        # Wait for signaling to complete (or interruption)
        try:
            await asyncio.gather(signaling_task, udp_task)
        except asyncio.CancelledError:
            pass
        finally:
            self.running = False
            signaling_task.cancel()
            udp_task.cancel()

            # Cleanup
            if self.ws:
                await self.ws.close()
            if self.udp_sock:
                self.udp_sock.close()

            # Print statistics
            self.stats.report()
            if self.stream:
                self.stream.close()

            log.info("Test client stopped")


async def main():
    parser = argparse.ArgumentParser(
        description="Ameba Camera WebRTC Test Client"
    )
    parser.add_argument("--server", required=True,
                        help="WebSocket signaling server URL "
                             "(e.g., ws://192.168.1.100:8765)")
    parser.add_argument("--ip",
                        help="Local IP address (auto-detected if omitted)")
    parser.add_argument("--output", default="output.h264",
                        help="Output H.264 file (default: output.h264)")
    parser.add_argument("--debug", action="store_true",
                        help="Enable debug logging")
    args = parser.parse_args()

    if args.debug:
        logging.getLogger().setLevel(logging.DEBUG)

    client = WebRTCTestClient(
        server_url=args.server,
        local_ip=args.ip,
        output_file=args.output,
    )

    try:
        await client.run()
    except KeyboardInterrupt:
        pass


if __name__ == "__main__":
    asyncio.run(main())
