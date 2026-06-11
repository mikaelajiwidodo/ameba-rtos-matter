# Ameba Camera WebRTC Test Suite

Python-based WebRTC signaling server and test client for verifying the
Ameba camera app's WebRTC video streaming.

## Files

| File | Purpose |
|------|---------|
| `signaling_server.py` | WebSocket signaling relay (pairs camera ↔ viewer) |
| `test_client.py` | Lightweight test client (receives RTP/H.264 video) |
| `README.md` | This file |

## Dependencies

All dependencies are Python packages:

```bash
pip3 install websockets
```

These are already available on the test system:
- `websockets` 10.4 ✓
- `asyncio` (built-in) ✓
- `json` (built-in) ✓

Optional — for playback of captured video:
```bash
sudo apt install ffmpeg ffplay
```

## Usage

### 1. Start the Signaling Server

On the Linux PC (the machine that both camera and viewer connect to):

```bash
cd ameba-rtos-matter/examples/camera/webrtc_test
python3 signaling_server.py --host 0.0.0.0 --port 8765
```

This starts a WebSocket signaling server on port 8765. The camera and
test client will connect to this server to exchange SDP and ICE candidates.

Optional flags:
- `--debug` — Enable verbose logging
- `--host` — Bind address (default: `0.0.0.0`)
- `--port` — Port (default: `8765`)

### 2. Connect the Camera (Ameba Board)

On the Ameba board, the camera app connects to the signaling server
as a `"camera"` role via WebSocket. The camera app needs to:

1. Connect to `ws://<SERVER_IP>:8765`
2. Send: `{"type": "register", "role": "camera"}`
3. Receive SDP offers from viewers
4. Send SDP answers back
5. Exchange ICE candidates
6. Start sending RTP/H.264 video

The signaling protocol is JSON over WebSocket:

| Direction | Message | Description |
|-----------|---------|-------------|
| Camera → Server | `{"type":"register","role":"camera"}` | Register camera |
| Server → Camera | `{"type":"registered","role":"camera"}` | Confirm registration |
| Viewer → Server → Camera | `{"type":"sdp","sdp":"...","sdp_type":"offer"}` | SDP offer relay |
| Camera → Server → Viewer | `{"type":"sdp","sdp":"...","sdp_type":"answer"}` | SDP answer relay |
| Either → Server → Other | `{"type":"ice","candidate":"...","mid":"..."}` | ICE candidate relay |
| Either → Server → Other | `{"type":"end","reason":"..."}` | End session |

### 3. Connect the Test Client

On another terminal (or the same Linux PC):

```bash
python3 test_client.py --server ws://192.168.1.100:8765
```

Replace `192.168.1.100` with the actual IP of the signaling server.

The test client will:
1. Connect to signaling server as a `"viewer"`
2. Open a UDP port for receiving RTP video
3. Wait for the camera to send an SDP offer
4. Send back an SDP answer with the viewer's UDP port
5. Receive RTP packets on the UDP port
6. Parse H.264 NAL units (handles FU-A fragmentation)
7. Save the H.264 stream to `output.h264`
8. Print reception statistics (bitrate, packet count, NAL types)

Optional flags:
- `--server` **(required)** — WebSocket URL of signaling server
- `--ip` — Local IP address (auto-detected if omitted)
- `--output` — Output H.264 file (default: `output.h264`)
- `--debug` — Enable verbose logging

### 4. Play Back the Captured Video

Once the test client has been receiving video, play the H.264 file:

```bash
# Play with ffplay (real-time playback)
ffplay output.h264

# Convert to MP4
ffmpeg -i output.h264 -c:v copy output.mp4

# Inspect stream details
ffprobe output.h264
```

## Test Architecture

```
┌──────────────┐     WebSocket     ┌──────────────────┐     WebSocket     ┌──────────────┐
│              │ ◄──────────────► │                  │ ◄──────────────► │              │
│  Ameba       │   SDP / ICE       │  Signaling       │   SDP / ICE       │  Test Client │
│  Camera      │   messages        │  Server          │   messages        │  (viewer)    │
│              │                   │  (port 8765)     │                   │              │
└──────┬───────┘                   └──────────────────┘                   └──────┬───────┘
       │                                                                         │
       │              RTP / H.264 video (direct UDP, no relay)                  │
       └─────────────────────────────────────────────────────────────────────────┘
                         Camera UDP:XXXX ──► Viewer UDP:YYYY
```

The signaling server only relays SDP and ICE candidates (via WebSocket).
The actual RTP video stream flows **directly** from camera to viewer over UDP,
using the IP/port negotiated during ICE.

## Signaling Protocol Details

### Registration
```json
// Camera registers
→ {"type": "register", "role": "camera"}
← {"type": "registered", "role": "camera"}

// Viewer registers
→ {"type": "register", "role": "viewer"}
← {"type": "registered", "role": "viewer", "viewer_id": 1}
```

### SDP Exchange
```json
// Camera sends SDP offer (when viewer requests stream)
← {"type": "sdp", "sdp": "v=0\r\no=-...", "sdp_type": "offer"}

// Viewer sends SDP answer
→ {"type": "sdp", "sdp": "v=0\r\no=-...", "sdp_type": "answer"}
```

### ICE Candidate Exchange
```json
// Camera sends ICE candidate
← {"type": "ice", "candidate": "candidate:1 1 UDP 2130706431 192.168.1.x 50000 typ host",
   "mid": "video"}

// Viewer responds with its ICE candidate
→ {"type": "ice", "candidate": "candidate:1 1 UDP 2130706431 192.168.1.y 54321 typ host",
   "mid": "video"}
```

### Session End
```json
← {"type": "end", "reason": "Stream ended"}
```

## Troubleshooting

| Symptom | Likely Cause | Solution |
|---------|-------------|----------|
| Connection refused | Signaling server not running | Start `signaling_server.py` first |
| No SDP offer received | Camera not registered with server | Check camera connects with `role:"camera"` |
| No UDP packets received | Wrong IP/port, or NAT blocking | Check `test_client.py --ip` matches actual IP |
| Corrupted H.264 output | FU-A reassembly not working | Check `test_client.py --debug` for NAL traces |
| Duplicate packets | Network issues | Check stats output for duplicate count |
