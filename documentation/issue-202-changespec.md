# Issue #202 - HELP: generated JSON Schema and Get SMO HELP.vi fixes (change spec)

Status: proposal. Read on `develop` at `67c0043d` (2026-11-19). Part A changes the Instrument Framework; Part B changes this repo.

## Summary

`HELP {"command": "<name>"}` returns `request_schema` and `response_schema`, but these are read from text stored in each typedef's description, not generated. Almost no lock-in typedef has stored text, and the one that does is wrong. Because `JSON to LVtype.vim` ignores unknown keys, a client without a schema cannot detect a misspelled key. This change makes `HELP` generate the schema from the typedef and fixes the `Get SMO HELP.vi` frames that would produce a poor schema.

## Current behavior

| Item | Location | Behavior |
| --- | --- | --- |
| `HELP` handler | Framework `Instrument\Private\Handle Help.vi` | No parameter: returns the command list (`Get SMO Public API.vi`). With `command`: calls `Get SMO HELP.vi`, then `Help.lvclass:Get JSON API Documentation.vi`. |
| Schema source | Framework `subsystems\Help\private\Create Request Description.vi` and `Create Response Description.vi` | Read the schema with `JSON-Schema.lvlib:Read Typedef Description (variant).vi`; omitted if empty. Examples (`request_example`, `response_example`) are generated from the typedef constant. |
| Per-command help | `Instrument.Lockin\Overrides\Get SMO HELP.vi` | One case per command: description plus request and response typedef constants in variants. |
| Generator | `JSON-Schema.lvlib:Create JSON Schema.vi` | Variant in, JSON Schema string out. Not called by `HELP`. |

Stored schemas: of the `.ctl` files under `src\Instrument.Lockin\Typedefs` and `src\Instrument.DAQ\Typedefs`, only `Sweep.Configuration--Cluster.ctl` contains `$schema`, and it describes the `setSweep_Table` payload (array of `{Channel, Table}`). Found by text search; confirm with a live `HELP` call.

## Part A: generate the schema (framework)

In `Create Request Description.vi` and `Create Response Description.vi`, replace `Read Typedef Description (variant).vi` with `Create JSON Schema.vi` (`Write to File?` = False) on the same variant.

- The `HELP` command, its reply keys and existing clients are unchanged.
- Object schemas must include `"additionalProperties": false`.
- Enums must be `{"type": "string", "enum": [...]}`, matching JSONtext. Verify in `Add enum Type to JSON Schema.vi`.
- Cache per command if generation is slow (optional; `HELP` is called rarely).
- Applies to every instrument built on the framework.

## Part B: Get SMO HELP.vi fixes (this repo)

The generated schema depends on the typedef constant in each frame.

| Command | Problem | Fix |
| --- | --- | --- |
| `getSweepResults`, `getSweepWaveforms` | Response is a bare cluster constant `{AO, AI, X, Y}` with empty arrays | Use the typedef the handler returns |
| `getREFconfig` | Description is the template text "Describe what your command" | Write the description |
| `setSweepTime` | Description typo "Copnfigure" | Correct it |
| `setSweep` | `Sweep.Configuration--Cluster.ctl` description holds a wrong stored schema | Clear the stored text |

Optional: a Caraya test that calls `Get SMO HELP.vi` for every item of `Get SMO Public API.vi` and fails on an empty description.

Related, already planned: the `±` (0xB1) in the Range enum items is not valid UTF-8 and is relabeled in `getInputDAQ-getOutputDAQ-changespec.md`. Labels that appear in a schema must be ASCII.

## Out of scope

- Whole-API schema in one call (`HELP {"command": "*"}` or `getSchema`) with shared `$defs` and a version field. Add only if a client code generator needs it.
- Server-side validation that rejects unknown keys. This changes behavior for existing clients (Transport may send extra keys) and would need to be opt-in.

## Test plan

1. `HELP {"command": "setSweep"}` returns a `request_schema` with `initialWaitTime`, `sweepTime`, `returnToStart`, `sweepChannels` and `"additionalProperties": false`.
2. `HELP` for `getSweepResults` returns a `response_schema` with typed `AO`, `AI`, `X`, `Y`.
3. For every command, validate `request_example` against `request_schema` with a standard validator (Python `jsonschema`).
4. A payload with an extra key fails validation on the client.
