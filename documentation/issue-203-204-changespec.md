# Issues #203 and #204 - data stream over a ZeroMQ XPUB socket (change spec)

Status: proposal. Read on `develop` at `67c0043d` (2026-11-19). #203 covers the socket, the publisher structure and the JSON topics; #204 adds binary waveform topics.

## Summary

Clients currently obtain data by polling REP commands (`getResults`, `getAI`); the framework macro `waitNewResults.vi` polls `getResults` every 50 ms and compares `Time Stamp`. This change adds a second socket that publishes each result as the DAQ engine produces it. The REP command socket, its commands and payloads are unchanged.

Benefits:

- Every buffer is delivered once, with a sequence number; gaps are detectable. Polling skips buffers silently.
- Latency is the event latency, not the poll interval plus a round trip.
- Data replies no longer occupy the REP socket, which serves one request at a time. Commands are not delayed by large `getAI` replies.
- Any number of subscribers share one serialization per buffer.
- A slow subscriber loses only its own messages; it cannot stall acquisition or the REP socket.
- Waveforms are sent as binary and read in Python with `numpy.frombuffer`.

## Current behavior

| Item | Location | Behavior |
| --- | --- | --- |
| Command server | `RemoteControl.ZMQ.lvclass:Open Server Connection.vi` | `ZMQ_REP` socket, port from `Instrument.Lockin\Overrides\Get SMO Port.vi` (29170) |
| Data events | `Instrument.DAQ\private\DAQ.getResults.vi`, `DAQ.getWaveforms.vi`, `DAQ.getSweepWaveforms.vi`, `DAQ.getDAQState.vi` | User events in `PublicEvents--Cluster`, generated with high priority |
| Event access | `Instrument.Lockin\API (Class)\Lockin.getDAQPublicEvents.vi` | Returns `PublicEvents--Cluster`; used by `Instrument.Lockin` and the UI |
| ZeroMQ binding | `<vi.lib>\addons\zeromq` | Has `ZMQ_XPUB` (`socket_type.ctl`), `ZMQ_SNDHWM`, `ZMQ_LINGER` (`socket_options.ctl`), `zmq_send_multi.vi`, `zmq_recv_multi.vi` |

## Socket

- Type `ZMQ_XPUB`, bound to `tcp://*:<stream port>`. Subscribers use `ZMQ_SUB`; XPUB behaves as PUB toward them and also delivers their subscribe and unsubscribe messages to the publisher.
- Subscription messages are one frame: byte `0x01` (subscribe) or `0x00` (unsubscribe) followed by the prefix. With the default `ZMQ_XPUB_VERBOSE` = 0, XPUB removes duplicates: a subscribe is delivered only for the first subscriber to a prefix, and an unsubscribe only when the last one leaves (including on disconnect). Each message is therefore a transition of that prefix between "no subscribers" and "at least one", and no counting is needed. `ZMQ_XPUB_VERBOSE` = 1 would deliver every subscribe but still only the last unsubscribe, which breaks counting; do not set it.
- Stream port: command port + 1 (29171). Also reported by `getStreamInfo`.
- Options: `ZMQ_XPUB_VERBOSE` left at its default (0; see below), `ZMQ_SNDHWM` = 100 for #203 (lower once waveforms are added), `ZMQ_LINGER` = 0.

## Topics

| Topic | Issue | Source event | Rate | Payload |
| --- | --- | --- | --- | --- |
| `results` | #203 | `getResults` | Every buffer (about 13/s at Fs = 204789 S/s, 15753 samples) | JSON, same as the `getResults` reply |
| `sweep` | #203 | `getSweepWaveforms` | End of each sweep | JSON, same as the `getSweepResults` reply |
| `state` | #203 | `getDAQState` | Each state change | JSON `{"state": "<state>"}` |
| `waveforms.ai` | #204 | `getWaveforms` | Every buffer, only while subscribed | Binary f64le |
| `waveforms.ao` | #204 | `getWaveforms` | Every buffer, only while subscribed | Binary f64le |

Topic names become part of the public interface on release.

## Message format

Each message is a ZeroMQ multipart message of three frames, sent with `zmq_send_multi.vi`. Frames are delivered atomically. Subscription filtering matches a prefix of the first frame only.

1. Topic (ASCII).
2. Header (JSON):
   ```json
   {"seq": 18342, "t0": "2026-11-19T15:02:11.482913Z", "schemaVersion": 1, "encoding": "json"}
   ```
   - `seq`: U64 per topic, counting DAQ buffers from 0 at publisher start. A gap indicates dropped messages; a reset to 0 indicates a restart.
   - `t0`: buffer timestamp, ISO 8601 UTC.
   - `encoding`: `json` or `f64le`.
   - Binary payloads add `channels` (names, in order), `samples` (per channel) and `dt`.
3. Payload: JSON text, or for `f64le` little-endian float64, channel-major (`channels` x `samples`).

## LabVIEW structure

```
DAQ SMO --public events--> lock-in adapter loop --Publish.vi (lossy queue)--> XPUB SMO --> socket
                                   ^                                              |
                                   +--------- Is Subscribed.vi (prefixes) --------+
```

The publisher is not placed in `Instrument.Lockin\Process.vi`, where serialization would delay command handling, nor in the RemoteControl SMO, where publishing and command handling would block each other. Each ZeroMQ socket is owned by one loop.

### XPUB SMO (generic)

No lock-in types. Built in this repo; moved to the framework once proven.

- Input: a fixed-size queue (about 8 elements) of `Publish.Message--Cluster {topic: String, header: String, payload: String}`. The payload string holds JSON text or raw bytes. `Publish.vi` calls Lossy Enqueue Element, so an overloaded publisher drops the oldest message rather than growing memory.
- Loop: dequeue with a 10 ms timeout and send the three frames; then read pending subscription messages without blocking: on `0x01` add the prefix to the set of subscribed prefixes, on `0x00` remove it.
- The set of subscribed prefixes is held in a DVR. `Is Subscribed.vi` takes a topic and returns True if any subscribed prefix is a prefix of it. The empty prefix (a client subscribed to everything) matches every topic, including waveforms. Optionally, a public event `{prefix, subscribed: Boolean}` is fired on each change.
- Started from `Instrument.Lockin\Overrides\onStart.vi` and stopped with the instrument.

### Lock-in adapter loop

A helper loop started from `onStart.vi` after the XPUB SMO. It registers for the DAQ public events and performs all serialization.

- Each event case returns immediately if `Is Subscribed.vi` is False; otherwise it builds the header and payload and calls `Publish.vi`.
- JSON payloads are serialized with JSONtext.
- `seq` is maintained here, per topic.

### Waveform handling (#204)

- Payload: the `Y` arrays as one 2D DBL array, Flatten To String with byte order little-endian and "prepend array or string size" False.
- The `getWaveforms` event case is limited to 1 queued instance.
- The adapter stays registered for `getWaveforms` and skips serialization when unsubscribed. If profiling shows that the idle registration copies event data, register and unregister on the XPUB SMO's subscription-change event instead.
- Fallback if XPUB subscription frames are not usable: a REP command `setStream {"waveforms": true|false}`. It is global across clients.

## New REP commands

| Command | Issue | Request | Response |
| --- | --- | --- | --- |
| `getStreamInfo` | #203 | none | `{"port": 29171, "topics": [...], "schemaVersion": 1}` |
| `setStream` | #204, fallback only | `{"waveforms": true}` | none |

Each needs a frame in `Get SMO HELP.vi`.

## Client usage

A client that needs a consistent view subscribes first, then reads current state over REP, then discards stream messages with `t0` older than the snapshot. Configuration is not streamed.

```python
import json, zmq, numpy as np

sub = zmq.Context().socket(zmq.SUB)
sub.connect("tcp://localhost:29171")
sub.setsockopt_string(zmq.SUBSCRIBE, "results")
sub.setsockopt_string(zmq.SUBSCRIBE, "waveforms.ai")

last = {}
while True:
    topic, header, payload = sub.recv_multipart()
    h = json.loads(header)
    t = topic.decode()
    if t in last and h["seq"] != last[t] + 1:
        print(f"{t}: missed {h['seq'] - last[t] - 1}")
    last[t] = h["seq"]
    if h["encoding"] == "f64le":
        data = np.frombuffer(payload, "<f8").reshape(len(h["channels"]), h["samples"])
    else:
        data = json.loads(payload)
```

## Estimated cost

Estimates from data sizes at Fs = 204789 S/s, 15753 samples per buffer, 12 AI channels. To be measured (Profile Performance and Memory) as part of each issue.

| Stream | Data rate | CPU | Memory |
| --- | --- | --- | --- |
| `results` | 10-20 KB per buffer, about 0.2 MB/s | One JSON serialization per buffer (a few ms); less than one client polling `getResults` at 20 Hz | About 2 MB per subscriber at HWM 100 |
| `sweep`, `state` | Small | Negligible | Negligible |
| Waveforms, no subscriber | 0 | None beyond a possible event data copy (see above) | None |
| Waveforms, subscribed | About 1.5 MB per buffer, 20 MB/s per direction | Memory copies only; well under 1% of a core | About 6 MB per subscriber at HWM 4; network 160 Mb/s per remote subscriber |

## Test plan

#203:

1. Prototype: `zmq_recv` on the XPUB socket returns `0x01` + prefix when the first SUB subscribes and `0x00` + prefix when the last one unsubscribes or disconnects.
2. A Python subscriber to `results` receives consecutive `seq` values for 10 minutes with no gaps at default sampling.
3. REP command latency (`getStatus`) is unchanged with the publisher running.
4. Stopping and restarting the instrument closes and rebinds the stream port without error.

#204:

1. With no `waveforms.*` subscriber, CPU and memory match the #203 baseline.
2. With a subscriber, the decoded `waveforms.ai` array equals the `getAI` reply for the same buffer.
3. A subscriber that stops reading causes `seq` gaps but no growth in lock-in memory.

## Open questions

- Results payload shape: keep the `getResults` form (list of `{key, value}`) or use a JSON object. Decide before release.
- Format of `Time Stamp` inside the JSON payload as written by JSONtext.
