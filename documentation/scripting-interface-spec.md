# Scripting interface: command schema and data stream (spec)

**Status.** Proposal, not started. Read with lvkit on `develop` at `67c0043d` on 2026-11-19. Covers this repo plus two shared libraries the user owns: the Instrument Framework (`<user.lib>\LevyLab\Instrument Framework`, `RemoteControl`, `RemoteControl.ZMQ`) and `JSON-Schema.lvlib` (`<vi.lib>\PRIrvin\JSON-Schema`).

**Why.** The lock-in is already scriptable from any language: it is a JSON-RPC server on a ZeroMQ socket, and Python, MATLAB or Lua clients need only a ZeroMQ binding and a JSON parser. Two gaps make that interface harder to use than it should be:

1. **The machine-readable contract is incomplete.** `HELP` already returns a JSON Schema for a command's request and response, but only where someone has generated one and stored it in the typedef's description, and that stored copy goes stale when the typedef changes. Today almost no lock-in typedef has one. A client that sends a wrong key gets "no error, no effect", because `JSON to LVtype.vim` ignores unknown keys (see "JSON command payloads" in CLAUDE.md), so a complete and current schema is what lets a client check a payload before sending it.
2. **Data can only be polled.** A client that wants every new result has to call `getResults` in a loop. The framework's own `waitNewResults.vi` (`Instrument Types\Lockin\API\Macros`) does exactly this: it calls `getResults` every 50 ms and compares `Time Stamp` with the previous one until it changes. Polling wastes round trips, adds up to 50 ms of latency, can miss buffers when the client is slower than the acquisition, and can't tell whether it missed any.

**Design in one line.** Part 1 makes `HELP` generate its schemas live from the typedefs instead of reading stored copies, so every command has a current schema. Part 2 adds a second ZeroMQ socket, PUB, that pushes results and (on request) waveforms as they are produced. The existing REP socket, its commands and its payloads do not change.

## What exists today

| Piece | Where | What it does |
| --- | --- | --- |
| Command server | `RemoteControl.ZMQ.lvclass:Open Server Connection.vi` | Binds a ZeroMQ socket of type 4 (`ZMQ_REP`). One request, one reply, strictly alternating. |
| Lock-in port | `Instrument.Lockin\Overrides\Get SMO Port.vi` | Constant `29170`. |
| Wire format | `JSON-RPC.lvlib` (`<vi.lib>\PRIrvin\JSON-RPC`) | JSON-RPC 2.0 request/response. Instrument errors currently reach the client as a bare `null` (fix tracked in the JSON-RPC repo, see `getInputDAQ-getOutputDAQ-changespec.md`). |
| Command list | `Instrument.Lockin\Overrides\Get SMO Public API.vi` | Parent's commands plus the items of `Lockin.Commands--Enum`, as `[String]`. |
| `HELP` command | `Instrument\Private\Handle Help.vi` (framework) | With no `command` parameter, returns the command list. With `{"command": "<name>"}`, calls `Get SMO HELP.vi` and returns `Help.lvclass:Get JSON API Documentation.vi` of the result, as a string: the command description plus, for each side, `request_example` / `response_example` (generated from the typedef constant) and `request_schema` / `response_schema`. |
| Schema in `HELP` | `Instrument Framework\subsystems\Help\private\Create Request Description.vi` (and the Response twin) | The schema is **not generated**: it is read from the typedef's VI description with `JSON-Schema.lvlib:Read Typedef Description (variant).vi`, and omitted when the description is empty. It exists only if someone ran `Create JSON Schema.vi` with `Write to File? = True` on that typedef. |
| Per-command help | `Instrument.Lockin\Overrides\Get SMO HELP.vi` | A case per command returning `Help--cluster {command, command description, request cluster, response cluster}`. The request and response clusters are **typedef constants** packed into variants (`Sweep.Configuration--Cluster`, `AO.Channel--Cluster`, `Results--Cluster`, ...). The default frame calls the parent. A disabled diagram block already calls `JSON-Schema.lvlib:Create JSON Schema (Interactive).vi`. |
| Schema generator | `JSON-Schema.lvlib:Create JSON Schema.vi` | Takes a variant (`LV Object`), a title and a description, and returns a JSON Schema string. Also `Generate Schema $defs.vi` for shared definitions. |
| Data events | `Instrument.DAQ\private\DAQ.getResults.vi`, `DAQ.getWaveforms.vi`, `DAQ.getSweepWaveforms.vi`, `DAQ.getDAQState.vi` | The DAQ engine fires LabVIEW user events (`PublicEvents--Cluster`) with every new result and waveform set. `getResults` carries `Results--Cluster {Time Stamp, Results (Dictionary): [{key: String, value: DBL}]}`. |
| Event access | `Instrument.Lockin\API (Class)\Lockin.getDAQPublicEvents.vi` | Returns the DAQ engine's `PublicEvents--Cluster`, so any loop can register for those events. |

The useful conclusion: the schema mechanism is already there (`HELP` returns `request_schema` / `response_schema`, built from typedef constants per command in `Get SMO HELP.vi`, using a library that turns a variant into JSON Schema); it only reads stored copies instead of generating them. The data stream needs no change to the DAQ engine (the events it already fires are exactly what a publisher needs).

**Stored schemas today.** Of the `.ctl` files under `src\Instrument.Lockin\Typedefs` and `src\Instrument.DAQ\Typedefs`, only `Sweep.Configuration--Cluster.ctl` contains a `$schema` text, and it is the wrong one: it describes an array of `{Channel, Table}` (the `setSweep_Table` payload), not `{initialWaitTime, sweepTime, returnToStart, sweepChannels}`. So `HELP` currently returns no request schema for any lock-in command except `setSweep`, and that one is wrong. (Found by searching the files for `$schema`; a stored description that LabVIEW compresses would be missed, so confirm with a live `HELP` call.)

## Part 1: command schema

### Goal

Every command's `HELP` reply carries a current JSON Schema for its request and response. A client uses it to:

- validate a payload before sending it, so an unknown or misspelled key is an error on the client instead of a silent no-op on the server;
- generate typed bindings (Python dataclasses or pydantic models, for example with `datamodel-code-generator`);
- detect a contract change (a renamed label) by diffing schemas between releases.

### The change: generate the schema in `HELP` instead of reading it

In the framework's `Create Request Description.vi` and `Create Response Description.vi`, replace `Read Typedef Description (variant).vi` with a call to `Create JSON Schema.vi` (`Write to File? = False`) on the same variant. Everything else about `HELP` stays: same command, same reply keys (`request_schema`, `response_schema`, `request_example`, `response_example`), same client code. The difference is that the schema is now always present and always matches the typedef the server actually parses.

- Every object schema must carry `"additionalProperties": false`, so standard validators reject unknown keys. (`JSON-Schema.lvlib` already writes this; see the stored `Sweep.Configuration--Cluster` text.)
- Enums should be `{"type": "string", "enum": [...item names...]}`, matching how JSONtext writes enums. To confirm in `JSON-Schema.lvlib` (`Add enum Type to JSON Schema.vi`).
- Cost: generating a schema walks the variant's type, so cache the result per command if `HELP` turns out to be slow. It is called rarely, so this is optional.
- Being a framework change, it fixes `HELP` for every instrument at once (lock-in, KH7008, cryostat, ...).

Keep `Write Typedef Description` for what it is good at (documentation in the LabVIEW context help), but stop treating the stored text as the wire contract.

### Optional: whole-API dump in one call

`HELP` with no argument returns the command list, then one `HELP` call per command returns its schema. That is enough for any client. A single-call variant (say `HELP` with `{"command": "*"}`, or a separate `getSchema`) only adds:

- one round trip instead of ~50;
- shared definitions: a typedef used by several commands (`AO.Channel--Cluster` by `setAO` and `getAOconfig`) appears once under `$defs` (`Generate Schema $defs.vi`), which gives a code generator one class instead of two identical ones;
- a version field, so a client can cache the schema and tell when it changed.

Worth doing only if a client generator wants it. Shape, for reference:

```json
{
  "instrument": "Multichannel Lockin",
  "version": "3.10.0.101",
  "schemaVersion": 1,
  "$defs": { "Sweep.Configuration--Cluster": { ... }, "AO.Channel--Cluster": { ... } },
  "commands": {
    "setSweep": {
      "description": "Configure the sweep parameters.",
      "request":  { "$ref": "#/$defs/Sweep.Configuration--Cluster" },
      "response": null
    },
    "getResults": {
      "description": "Returns the results of the lockin calculations.",
      "request":  null,
      "response": { "$ref": "#/$defs/Results--Cluster" }
    }
  }
}
```

`version` is the application version (`Lockin.Utilities\Application Version.vi`); `request`/`response` are `null` for commands with no payload on that side.

### Isolated fixes in `Get SMO HELP.vi`

The generated schema is only as good as the typedef constant in each frame of `Get SMO HELP.vi`. Because they are typedef constants, label renames propagate automatically, so the VI is in good shape overall. These are a few isolated fixes, not a rewrite:

- **Untyped response:** `getSweepResults` / `getSweepWaveforms` return a bare cluster constant `{AO, AI, X, Y}` with empty arrays, not a typedef. Replace it with the typedef the handler actually returns, or the schema will describe four arrays of unknown type.
- **Placeholder text:** `getREFconfig` has the template description "Describe what your command". `setSweepTime` says "Copnfigure".
- **Stale stored schema:** clear the wrong `$schema` text from the description of `Sweep.Configuration--Cluster.ctl` (harmless once `HELP` generates, but misleading in context help).
- **Guard (optional):** a unit test (Caraya) that, for every item of `Get SMO Public API.vi`, calls `Get SMO HELP.vi` and fails on an empty description, so a new command can't ship without help.
- **Non-ASCII labels:** `±` in the Range enum items is byte 0xB1 (Windows-1252), not valid UTF-8; already planned in the Range relabeling in `getInputDAQ-getOutputDAQ-changespec.md`. Every label that appears in a schema must be ASCII.

### Optional later: strict mode on the server

With a schema in hand the server could also validate incoming payloads and reply with an error on unknown keys, instead of ignoring them. This changes behavior for existing clients that send extra keys (Transport may), so it should be opt-in per connection or a release-level decision. Client-side validation gets most of the benefit without that risk.

## Part 2: data stream (PUB socket)

### Goal

A client subscribes once and receives every new result (and, when asked for, waveforms) as soon as the DAQ engine produces it, with sequence numbers so it can tell when it missed something. Configuration and one-off queries stay on the REP socket.

### Yes: REP stays exactly as it is

The PUB socket is purely additive:

- It is a **second socket on its own port**, owned by its own loop. ZeroMQ sockets are not thread-safe, so the REP loop and the PUB loop each own one socket. They can share the ZeroMQ context (`ZMQ.ContextManager` already manages one per process).
- It **listens to the DAQ engine's existing public events** (`Lockin.getDAQPublicEvents.vi`). The DAQ engine, `Instrument.Lockin\Process.vi`, `Handle Command.vi` and every REP command are unchanged. A client that never connects to the PUB port sees no difference.
- A PUB socket **never blocks the sender**. If a subscriber is slow, ZeroMQ drops messages for that subscriber once its send queue (high-water mark) is full. Acquisition can't be stalled by a client.

So existing clients (Transport, LabVIEW API callers, the Python configurator) keep working, and the stream can be released on its own without the "release together" rule that applies to payload renames.

### Advantages

1. **No missed buffers, and you know when you miss one.** Every result is pushed once, with a sequence number. Polling `getResults` silently skips buffers whenever the client's loop is slower than the acquisition, and can't tell it happened.
2. **Lower latency.** A result arrives as soon as the DAQ engine fires the event, instead of up to 50 ms later (the `waitNewResults` poll interval) plus a round trip.
3. **Command traffic is no longer queued behind data.** A REP socket answers one request at a time. Today a client polling `getAI` (megabytes of JSON per reply) holds up every other client's `setAO` or `setSweep` while that reply is built and sent. With data on its own socket, the REP socket carries only small commands and responds promptly.
4. **Fan-out for free.** Several clients (a Python analysis script, a live plot, a logger, Transport) receive the same data from one serialization. With polling, each client costs a full serialization per poll.
5. **Clients can't hurt the instrument.** A slow or hung subscriber only loses its own messages (high-water mark); it can't stall acquisition or the command socket. A slow polling client today occupies the REP loop for as long as its replies take.
6. **Fast waveforms.** The binary path lets Python read waveforms with `numpy.frombuffer` (no parsing), instead of decoding JSON text.
7. **Simpler clients.** A blocking `recv` loop replaces poll-and-compare-timestamps code and the `waitNewResults` / `waitNewWaveforms` / `waitStatus*` macros. The `state` topic tells a client that a sweep finished without polling `getStatus`.
8. **New uses outside LabVIEW.** Recording to HDF5 from Python, remote monitoring dashboards, or a second machine doing analysis, all without touching the lock-in's code or adding commands.
9. **No risk to the existing contract** (previous section): purely additive.

### Cost: CPU and memory

Short answer: small for `results` and `state`, and nothing for waveforms unless someone subscribes. When it replaces a polling client it is a net saving, because the same serialization is done once per buffer instead of once per poll. Estimates below are from data sizes, not measurements; measure with the Profile Performance and Memory window as in `experiments\lockin_profile_2026-10-01`.

| Item | Size | Rate (at Fs = 204789 S/s, #s = 15753: ~13 buffers/s) | CPU | Memory |
| --- | --- | --- | --- | --- |
| `results` | `Results (Dictionary)`: one value per key, a few hundred keys, ~10-20 KB of JSON | ~13 messages/s, ~0.2 MB/s | One JSONtext serialization per buffer, a few ms. The same work `getResults` does per call today, so a client polling every 50 ms (20/s) currently costs more. | Send queue: HWM 100 x ~20 KB = ~2 MB per subscriber at worst. |
| `state`, `sweep` | Small / one sweep result | Per change / per sweep | Negligible | Negligible |
| `waveforms.*`, nobody subscribed | | | **None**, if the waveform event is registered only while XPUB reports a subscriber (below). | None |
| `waveforms.*`, subscribed | 12 AI x 15753 samples x 8 B = ~1.5 MB per buffer (AO similar) | ~20 MB/s per direction | Copying `Y` arrays into one buffer and `Flatten To String` with little-endian byte order are plain memory copies (no formatting, no byte swap on x86): a few copies of 20 MB/s is well under 1% of a core. | One extra copy of the buffer in the publisher's event queue (cap it at 1-2 events), plus HWM 4 x 1.5 MB = ~6 MB per subscriber. |
| Network | | 20 MB/s = 160 Mb/s per waveform subscriber | | Fine on localhost or gigabit; each remote waveform subscriber adds its own 160 Mb/s. |

Compared with today: `getAI` over REP converts the same 1.5 MB per call into JSON text (several times larger, and number formatting is far slower than a memory copy). A client that currently polls waveforms will cost the lock-in much less over the binary stream.

The one cost to watch is **LabVIEW event data copies**: each event registration may receive its own copy of the event data, so a publisher that is permanently registered for `getWaveforms` could add a 1.5 MB copy per buffer even with no subscribers. Registering for the waveform event only while there is a waveform subscriber (dynamic registration with `Register For Events`, re-run when XPUB reports a subscribe or unsubscribe) removes that cost.

### Socket and port

- Socket type `ZMQ_XPUB` (9), bound to `tcp://*:<stream port>`. XPUB sends exactly like PUB (subscribers can't tell the difference) and also tells the publisher which topics have subscribers; see "Waveforms only when subscribed".
- **Stream port = command port + 1** by default (29171 for the lock-in), so a client that knows the command port can find the stream. Also returned by a new REP command `getStreamInfo` so it can be configured differently.
- `ZMQ_SNDHWM` set to a small number of messages (for example 100 for results, 4 for waveforms), so a stalled subscriber costs bounded memory.

### Topics

ZeroMQ filters by message prefix, so each message's first frame is a topic string. A subscriber subscribes to the topics it wants.

| Topic | Source event | When | Payload |
| --- | --- | --- | --- |
| `results` | `DAQ.getResults` | Every buffer (Fs / #s per second; about 13/s at Fs = 204789 S/s and #s = 15753) | `Results--Cluster` as JSON, same shape as the `getResults` reply |
| `waveforms.ai` | `DAQ.getWaveforms` | Every buffer, **only while someone is subscribed** (see below) | AI waveforms, binary |
| `waveforms.ao` | `DAQ.getWaveforms` | Every buffer, only while someone is subscribed | AO waveforms, binary |
| `sweep` | `DAQ.getSweepWaveforms` | End of each sweep | Same shape as the `getSweepResults` reply, JSON |
| `state` | `DAQ.getDAQState` | On every state change | `{"state": "<idle/created/started/stopped/sweeping/...>"}` |

Topic names are part of the public contract once released. Use dotted lower-case names so a subscriber can subscribe to a prefix (`waveforms.` gets both directions).

### Message format

Every message is a ZeroMQ multipart message with three frames:

1. **Topic** (ASCII), as in the table.
2. **Header** (JSON, UTF-8):
   ```json
   {"seq": 18342, "t0": "2026-11-19T15:02:11.482913Z", "schemaVersion": 1, "encoding": "json"}
   ```
   - `seq`: a per-topic counter (U64) starting at 0 when the publisher starts. A gap tells the subscriber it missed messages (slow consumer or late join). A drop back to 0 means the lock-in restarted.
   - `t0`: the buffer's timestamp from the event data (`Time Stamp` for results, `t0` of the first waveform), as ISO 8601 UTC.
   - `encoding`: `json` or `f64le` (below).
   - For binary payloads, also `dt`, `channels` (names, in order) and `samples` (per channel), so the payload can be reshaped without a REP call.
3. **Payload**: JSON for `results`, `sweep` and `state`. For waveforms, raw little-endian float64 (`f64le`), channel-major (`channels` x `samples`), so Python reads it with `numpy.frombuffer(frame, "<f8").reshape(len(channels), samples)` with no parsing.

Why binary for waveforms: one AI buffer is 12 channels x 15753 samples x 8 bytes, about 1.5 MB, about 20 MB/s at 13 buffers/s. As JSON text it is several times larger and has to be formatted in LabVIEW and parsed in the client, the same cost that makes `getAI` slow today. Results are a few hundred numbers per buffer, so JSON is fine there and keeps them readable.

### Waveforms only when subscribed

A plain PUB socket can't tell the sender who is listening, so it would format 20 MB/s of waveforms even with no subscribers. The XPUB socket receives each subscriber's subscribe and unsubscribe messages (one frame: byte `1` or `0` followed by the topic). The publisher keeps a count per topic and:

- registers for `DAQ.getWaveforms` when the count for any `waveforms.` topic goes from 0 to 1, and unregisters when it returns to 0;
- formats only the directions (`ai`, `ao`) that have subscribers.

Set `ZMQ_XPUB_VERBOSE` so every subscribe message is delivered, not only the first per topic; then the per-topic count is exact. ZeroMQ delivers an unsubscribe when a subscriber disconnects, so a crashed client doesn't leave waveforms running.

Fallback if XPUB turns out not to work in `zeromq.lvlib`: a REP command `setStream` `{"waveforms": true/false}`. It is global (one client's "off" stops another client's stream), which is why XPUB is preferred.

`results`, `sweep` and `state` are cheap and always published.

### Late joiners: snapshot from REP, then stream

A subscriber that connects misses everything published before its subscription takes effect (ZeroMQ's "slow joiner": the first few messages after connecting can be lost too). The pattern for a client that needs a consistent view:

1. `SUB` connect and subscribe first.
2. Then call the REP commands for current state (`getResults`, `getAOconfig`, `getREFconfig`, `getSampling`, ...).
3. Use stream messages from then on; anything with `t0` older than the snapshot is discarded.

Configuration is **not** streamed in this design: it changes rarely and REP is the source of truth. If clients later need to hear about configuration changes made by someone else (another client or the UI), a `config` topic carrying only the name of the command that changed it (`{"changed": "setAO"}`) is enough; the client re-reads it over REP.

### Where the publisher lives in LabVIEW

A new loop, ideally an SMO of its own (`Instrument.Lockin.Publisher` or a framework-level `RemoteControl.ZMQ.Publisher`), launched next to the REP server in `Instrument.Lockin\Overrides\onStart.vi` and stopped with it:

1. On start: get the stream port, create and bind the XPUB socket, register for `getResults`, `getSweepWaveforms`, `getDAQState` from `Lockin.getDAQPublicEvents.vi` (`getWaveforms` only once a waveform subscriber appears).
2. Event structure: one case per event. Each case increments that topic's `seq`, formats header and payload, and sends three frames (`zmq_send` with `ZMQ_SNDMORE` on the first two). The timeout case (or a short-timeout `zmq_recv`) reads subscription messages from the XPUB socket and updates the per-topic counts and the waveform registration. Reading and sending on the XPUB socket from the same loop keeps the socket single-threaded.
3. On stop: unregister events, close the socket (`ZMQ_LINGER` 0 so shutdown never waits on slow subscribers).

Keep formatting out of the DAQ engine's loop: the user event queue decouples them. If the publisher falls behind, its event queue grows; limit the waveform event to 1-2 queued instances ("Limit maximum instances of this event in the event queue" in the Edit Events dialog), so the publisher drops stale waveforms and catches up instead of growing without limit. Subscribers see the drop as a `seq` gap only if `seq` counts DAQ buffers rather than sent messages, so count buffers.

The DAQ engine's events are generated with **high priority** (`DAQ.getResults.vi`, `DAQ.getWaveforms.vi`), which is fine for a separate registration: each registration has its own queue.

### Python client (illustration)

```python
import json, zmq, numpy as np

ctx = zmq.Context()
sub = ctx.socket(zmq.SUB)
sub.connect("tcp://localhost:29171")
sub.setsockopt_string(zmq.SUBSCRIBE, "results")

last = None
while True:
    topic, header, payload = sub.recv_multipart()
    h = json.loads(header)
    if last is not None and h["seq"] != last + 1:
        print(f"missed {h['seq'] - last - 1} messages")
    last = h["seq"]
    results = json.loads(payload)            # same shape as the getResults reply
```

and for waveforms:

```python
sub.setsockopt_string(zmq.SUBSCRIBE, "waveforms.ai")
topic, header, payload = sub.recv_multipart()
h = json.loads(header)
ai = np.frombuffer(payload, "<f8").reshape(len(h["channels"]), h["samples"])
```

## New REP commands (summary)

| Command | Request | Response | Part |
| --- | --- | --- | --- |
| `getStreamInfo` | `{}` | `{"port": 29171, "topics": ["results", "waveforms.ai", "waveforms.ao", "sweep", "state"], "schemaVersion": 1}` | 2 |
| `setStream` | `{"waveforms": true}` | none | 2, fallback only if XPUB does not work |
| `HELP` `{"command": "*"}` (or `getSchema`) | | Whole-API schema document | 1, optional |

Part 1 itself adds no command: it changes what `HELP` returns. Each new command needs a frame in `Get SMO HELP.vi` so it has a schema.

## Order of work

1. **Fix the error envelope** in `JSON-RPC.lvlib` (already planned). Every client benefits, and schema-driven clients need real errors to report.
2. **`HELP` generates schemas** (framework: `Create Request/Response Description.vi`), plus the isolated `Get SMO HELP.vi` fixes.
3. **Publisher with `results` and `state` topics**, JSON only. This replaces `waitNewResults` polling and is the bulk of the value.
4. **Waveform topics** (binary, gated by XPUB subscriptions).
5. **Python client package**: models generated from `HELP` schemas, a REP client, a stream iterator.

Steps 2 and 3 are independent and can be done in either order.

## Open questions

- **XPUB in `zeromq.lvlib`:** expected to work (the binding wraps libzmq, and socket type 9 and `ZMQ_XPUB_VERBOSE` are plain libzmq options). Confirm in the first prototype that the socket-type typedef includes XPUB and that `zmq_recv` on it returns the subscription frames. The framework only uses REQ/REP today (`ZMQ Rep Test.vi` / `ZMQ Req Test.vi`).
- **Measure the cost.** The cost table is an estimate from data sizes. Profile the publisher at the largest Fs and channel count you use, with and without a waveform subscriber.
- **Framework or lock-in:** putting the publisher in `RemoteControl.ZMQ` makes it reusable by other instruments, but each instrument's events are different, so only the socket/sequence/framing part generalizes. Suggested split: a generic publisher class in the framework (bind, topics, seq, send multipart), and the lock-in-specific event-to-topic mapping in this repo.
- **Results payload shape:** `Results (Dictionary)` is a list of `{key, value}` pairs. A plain JSON object `{"AI1.X": 0.12, ...}` is easier for clients; decide before the topic is released, because the payload is then part of the contract. Keeping it identical to the `getResults` reply has the advantage that one parser serves both.
- **Timestamps:** LabVIEW timestamps are serialized by JSONtext in their own format today; the header uses ISO 8601 UTC. Confirm how `Time Stamp` appears inside the `results` JSON payload and document it.
