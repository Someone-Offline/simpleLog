# simpleLog
Minimal, dependency-free logging helpers for Bash scripts, with six standard log levels, millisecond timestamps, terminal-aware colours, and in-memory collection of warnings, errors and fatals.

---

## Features

- **Six standard levels**: `TRACE`, `DEBUG`, `INFO`, `WARN`, `ERROR`, `FATAL`,
  matching the level set used by Apache Log4j 2 and the OpenTelemetry Logs Data Model.
- **Level filtering** through a single `LOG_LEVEL` variable.
- **Millisecond timestamps** in the format `YYYY-mm-dd--HH-MM-SS-fff`.
- **Colour only when it makes sense**: enabled for terminals, disabled
  automatically for files and pipes, and disabled on request with
  [`NO_COLOR`](https://no-color.org).
- **Correct streams**: `INFO` goes to stdout; everything else goes to stderr.
- **Problem collection**: warnings, errors and fatals are saved in arrays so a
  script can summarise them or set its exit code.
- **Safe with `set -euo pipefail`.**
- **No dependencies** on Bash 5+; falls back to `date` on older versions.
- **Single file**, ~80 lines; source it or paste it into a script.

---

## Requirements

| Environment | Status |
|---|---|
| Bash 5.0+ (any OS) | Fully supported; timestamps built in Bash, no external commands |
| Bash 4.x / 3.x with GNU `date` (Linux) | Supported through the `date` fallback |
| Bash 3.x with BSD `date` (stock macOS) | Works, but timestamps have **no milliseconds** |
| zsh, sh, dash | **Not supported**: the file uses Bash-only features |

> Tested on GNU Bash 5.2 on Linux. The older-Bash and macOS paths have not
> been tested on real systems; please open an issue if they misbehave.

---

## Installation

Copy `log-simple.sh` into your project, next to the scripts that use it:

```bash
git clone https://github.com/<your-user>/log-simple.git
cp log-simple/log-simple.sh /path/to/your/project/
```

Then load it at the top of your script:

```bash
#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/log-simple.sh"
```

Run the file directly to see a demo of every level:

```bash
bash log-simple.sh
```

The demo only runs when the file is executed. Sourcing it loads the functions
silently.

---

## Usage

```bash
trace "Entering copy_file() with $file"
debug "Config: SRC=$SRC DEST=$DEST"
info  "Starting backup of $SRC"
warn  "No config file found, using defaults"
error "Cannot read $file, skipped"
fatal "Destination is not writable"
```

### Levels

| Function | Label | Colour | Stream | Saved in | Use it when… |
|---|---|---|---|---|---|
| `trace` | `TRACE:` | dim grey | stderr | — | You need every step: function entry/exit, loop iterations |
| `debug` | `DEBUG:` | cyan | stderr | — | You need values and decisions: variables, settings, branches taken |
| `info` | `INFO:` | blue | stdout | — | Normal progress a user wants to see |
| `warn` | `WARN:` | yellow | stderr | `WARNINGS` | Something is unexpected, but the job still gets done |
| `error` | `ERROR:` | red | stderr | `ERRORS` | One part failed; the script continues with the rest |
| `fatal` | `FATAL:` | red background | stderr | `FATALS` | The script cannot sensibly continue |

### examples

```
2026-11-14--16-13-01-407 TRACE: this is a trace
2026-11-14--16-13-01-407 DEBUG: this is a debug
2026-11-14--16-13-01-408 INFO:  this is an info
2026-11-14--16-13-01-408 WARN:  this is a warn
2026-11-14--16-13-01-408 ERROR: this is an error
2026-11-14--16-13-01-408 FATAL: this is a fatal (script keeps running)
```

**Choosing between `ERROR` and `FATAL`:** ask *"can the rest of the job still
be done?"* If yes, use `error` and continue. If no, use `fatal` and exit.

### `fatal` does not exit

This is deliberate. `fatal` reports the problem, and **your script decides
when to stop**, so it can clean up first (remove temp files, release locks,
print a summary):

```bash
[[ -d $SRC ]] || { fatal "Source folder not found: $SRC"; exit 1; }

command -v rsync >/dev/null || { fatal "rsync is not installed"; exit 1; }
```

> ⚠️ Forgetting the `exit` means the script keeps running after a fatal
> problem.

---

## Configuration

All settings are environment variables. Set them before running the script,
or inside it.

| Variable | Values | Default | Effect |
|---|---|---|---|
| `LOG_LEVEL` | `TRACE` `DEBUG` `INFO` `WARN` `ERROR` `FATAL` (case-insensitive) | `INFO` | Minimum level shown. Unrecognised values fall back to `INFO`. |
| `NO_COLOR` | any value | unset | Disables colour |

```bash
LOG_LEVEL=DEBUG ./my-script.sh     # show DEBUG and above
LOG_LEVEL=WARN  ./my-script.sh     # problems only
NO_COLOR=1      ./my-script.sh     # plain output
```

Messages hidden by `LOG_LEVEL` are **still saved** in `WARNINGS`, `ERRORS`
and `FATALS`.

### Timestamp precision

The timestamp is built in the `_ts` function, in two places that must be kept
in step:

```bash
printf -v TS '%(%Y-%m-%d--%H-%M-%S)T-%s' "$sec" "${usec:0:3}"   # Bash 5+
TS=$(date +%Y-%m-%d--%H-%M-%S-%3N)                               # older Bash
```

| Precision | Bash 5+ | Fallback |
|---|---|---|
| Tenths | `${usec:0:1}` | `%1N` |
| Milliseconds (default) | `${usec:0:3}` | `%3N` |
| Microseconds | `${usec:0:6}` | `%6N` |

Bash 5 provides at most 6 fractional digits. Digits are truncated, not rounded.
If the fallback `date` does not support `%N`, the milliseconds are dropped
automatically rather than printing invalid output.

---

## Recalling warnings, errors and fatals

Problems are sent to **stderr** and saved in **in-memory arrays**. The arrays
exist only while the script runs.

### During the run

```bash
echo "Warnings: ${#WARNINGS[@]}  Errors: ${#ERRORS[@]}  Fatals: ${#FATALS[@]}"
printf '  - %s\n' "${ERRORS[@]}"

# Non-zero exit code if anything failed (useful for cron and CI)
(( ${#FATALS[@]} + ${#ERRORS[@]} == 0 )) || exit 1
```

A summary that runs however the script ends:

```bash
summary() {
    local m
    (( ${#WARNINGS[@]} )) && { echo "Warnings (${#WARNINGS[@]}):"; for m in "${WARNINGS[@]}"; do echo "  - $m"; done; }
    (( ${#ERRORS[@]}   )) && { echo "Errors (${#ERRORS[@]}):";     for m in "${ERRORS[@]}";   do echo "  - $m"; done; }
    (( ${#FATALS[@]}   )) && { echo "Fatals (${#FATALS[@]}):";     for m in "${FATALS[@]}";   do echo "  - $m"; done; }
    return 0
} >&2
trap summary EXIT
```

### After the run

Write stderr to a file:

```bash
./my-script.sh 2> problems.log                       # problems to file only
./my-script.sh 2> >(tee -a problems.log >&2)         # screen and file
grep -E 'WARN:|ERROR:|FATAL:' problems.log           # read them later
```

When stderr goes through `tee`, it is no longer a terminal, so problems print
without colour. The log file stays clean.

### Known limitation: subshells

Array entries made inside a **subshell** are lost when the subshell ends (the
message is still printed):

```bash
cat files.txt | while read -r f; do warn "$f"; done   # entries lost
while read -r f; do warn "$f"; done < files.txt        # entries kept
```

`$( … )` and `( … )` are subshells too.

---

## How it works

| Part | Role |
|---|---|
| `WARNINGS`, `ERRORS`, `FATALS` | Arrays that collect problem messages |
| `_ts` | Sets `TS` to the current timestamp |
| `_enabled` | Returns success if a level number is at or above `LOG_LEVEL` |
| `_out` | Filters, pads the label, colours if appropriate, writes to stdout/stderr |
| `trace` … `fatal` | Public functions; each passes its level, stream, colour and label to `_out` |
| Demo block | Runs only when the file is executed, not when sourced |

Functions prefixed with `_` are internal and may change.

---

## Contributing

Issues and pull requests are welcome. Please:

1. Keep the library a single file with no external dependencies on Bash 5+.
2. Test under `set -euo pipefail`.
3. Check output both in a terminal and redirected to a file (no colour codes
   should reach the file).

---

## AI use disclosure

The code and documentation in this project were written with the help of Claude (Anthropic).
The maintainer defined the requirements, directed the changes and is responsible for the project.
Testing so far was carried out by the AI on GNU Bash 5.2 on Linux; review the code before relying on it.

AI-generated code can contain subtle mistakes. Review it before using it in
production, and report problems as described in [`SECURITY.md`](SECURITY.md).

### EU AI Act (Regulation (EU) 2024/1689)

This disclosure is **voluntary**. As understood by the maintainer, the AI Act
does not impose obligations on this repository, because:

- `log-simple.sh` is a logging script, **not an AI system**. It contains no
  model, learning or inference.
- The marking of AI-generated output (Article 50(2)) is an obligation on the
  **provider of the AI system** used, not on people who use its output.
- The disclosure duty for AI-generated text (Article 50(4)) covers text
  published to inform the public on matters of public interest. Software
  documentation is not such text.

This is not legal advice. If you build an AI system with this library, your
own obligations under the AI Act depend on that system, not on this library.

### Contributions made with AI

AI-assisted contributions are welcome. Please say so in the pull request
description, and state which parts were generated and how you tested them.

---

## License

Copyright (C) 2026 [Someone-Offline](https://github.com/Someone-Offline)
This program is free software: you can redistribute it and/or modify it under
the terms of the **GNU Affero General Public License** as published by the Free
Software Foundation, either version 3 of the License.

This program is distributed in the hope that it will be useful, but **WITHOUT
ANY WARRANTY**; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
details.

You should have received a copy of the GNU Affero General Public License along
with this program, in the [`LICENSE`](LICENSE) file. If not, see
<https://www.gnu.org/licenses/>.

SPDX-License-Identifier: `AGPL-3.0`
