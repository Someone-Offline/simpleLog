# simpleLog

## Overview

Minimal, dependency-free logging helper for Bash scripts, with six standard log levels, millisecond timestamps, terminal-aware colours, and in-memory collection of warnings, errors and fatals.

[![License: AGPL v3](https://img.shields.io/badge/License-AGPL_v3-blue.svg)](LICENSE)

## Table of contents

- [Features](#features)
- [Installation](#installation)
    - [Prerequisites](#prerequisites)
    - [Steps](#steps)
- [Configuration](#configuration)
- [Running the Application](#running-the-application)
- [Documentation Folder Structure](#documentation-folder-structure)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [AI use disclosure](#ai-use-disclosure)
- [License](#license)

---

## Features

- **Six standard levels**: `TRACE`, `DEBUG`, `INFO`, `WARN`, `ERROR`, `FATAL`.
- **One switch for verbosity**: the `LOG_LEVEL` variable.
- **Correct streams**: `INFO` goes to stdout, everything else to stderr.
- **Clean files and pipes**: colour only when writing to a terminal; [`NO_COLOR`](https://no-color.org) turns it off.
- **Problem collection**: `WARNINGS`, `ERRORS` and `FATALS` arrays, filled even when `LOG_LEVEL` hides the message.
- **Safe with `set -euo pipefail`**, single file, about 80 lines.

## Installation

### Prerequisites

| Environment | Status |
| :--- | :--- |
| Bash 5.0+ (any OS) | Fully supported, no external commands |
| Older Bash with GNU `date` (Linux) | Supported through a `date` fallback |
| Older Bash with BSD `date` (stock macOS) | Works, but timestamps have no milliseconds |
| zsh, sh, dash | Not supported (Bash-only features) |

> [!NOTE]
> Tested only on GNU Bash 5.2 on Linux. The older-Bash and macOS paths are untested; please open an issue if they misbehave.

### Steps

1. Download the library and copy it next to the scripts that use it:

    ```bash
    git clone https://github.com/Someone-Offline/simpleLog.git
    cp simpleLog/simpleLog.sh /path/to/your/project/
    ```

2. Load it at the top of your script:

    ```bash
    #!/usr/bin/env bash
    set -euo pipefail
    source "$(dirname -- "${BASH_SOURCE[0]}")/simpleLog.sh"
    ```

3. Optionally, run the file directly to see every level (the demo does not run when the file is sourced):

    ```bash
    bash simpleLog.sh
    ```

## Configuration

| Variable | Values | Default | Effect |
| :--- | :--- | :--- | :--- |
| `LOG_LEVEL` | `TRACE` `DEBUG` `INFO` `WARN` `ERROR` `FATAL` (upper or lower case) | `INFO` | Minimum level shown; unrecognised values mean `INFO` |
| `NO_COLOR` | any value | unset | Disables colour |

```bash
LOG_LEVEL=DEBUG ./my-script.sh   # show DEBUG and above
NO_COLOR=1 ./my-script.sh        # plain output
```

## Running the Application

```bash
info  "Starting backup of $SRC"
warn  "No config file found, using defaults"
error "Cannot read $file, skipped"

[[ -d $DEST ]] || { fatal "Destination not found: $DEST"; exit 1; }

# Fail the run (for cron or CI) if anything went wrong
(( ${#ERRORS[@]} + ${#FATALS[@]} == 0 )) || exit 1
```

Running the file directly prints every level:

```console
$ bash simpleLog.sh
2026-11-14--16-13-01-407 TRACE: this is a trace
2026-11-14--16-13-01-407 DEBUG: this is a debug
2026-11-14--16-13-01-408 INFO:  this is an info
2026-11-14--16-13-01-408 WARN:  this is a warn
2026-11-14--16-13-01-408 ERROR: this is an error
2026-11-14--16-13-01-408 FATAL: this is a fatal (script keeps running)
2026-11-14--16-13-01-408 INFO:  still running after fatal
```

> [!IMPORTANT]
> `fatal` reports the problem but **does not exit**, this is deliberate so **your script decides when to stop**

| Function | Use it when… | Stream | Saved in |
| :--- | :--- | :--- | :--- |
| `trace` | You need every step: function entry, loop iterations | stderr | — |
| `debug` | You need values and decisions | stderr | — |
| `info` | Normal progress a user wants to see | stdout | — |
| `warn` | Something is unexpected, but the job still gets done | stderr | `WARNINGS` |
| `error` | One part failed; the rest can continue | stderr | `ERRORS` |
| `fatal` | The script cannot sensibly continue | stderr | `FATALS` |

The [user guide](docs/GUIDE.md) covers end-of-run summaries, saving problems to a file, timestamp precision, the subshell limitation and how the code is organised.

## Documentation Folder Structure

```text
.
├── .github/
│   ├── CONTRIBUTING.md  # principles, coding style, manual tests, sign-off
│   └── SECURITY.md      # reporting vulnerabilities and safe-usage limitations
├── .gitignore           # files and folders Git should not track
├── CHANGELOG.md         # release history
├── LICENSE              # full text of the GNU AGPL v3.0
├── README.md            # overview, installation and quick start
└── simpleLog.sh         # the library (single file)

```

- [Contributing guide](.github/CONTRIBUTING.md)
- [Security policy](.github/SECURITY.md)
- [Changelog](CHANGELOG.md)
- [LICENSE](LICENSE)
- [README](README.md)

## Troubleshooting

**`Syntax error: "(" unexpected` (or other errors) when sourcing**: the script is running under sh, dash or zsh, not Bash. Fix: run it with Bash (`#!/usr/bin/env bash`, or `bash my-script.sh`).

**Timestamps end at seconds, with no milliseconds**: older Bash with BSD `date` (stock macOS) has no `%N`, so the fallback drops the milliseconds. Fix: use Bash 5+, e.g. from Homebrew.

**`WARNINGS`, `ERRORS` or `FATALS` are empty although messages were printed**: they were logged inside a subshell, such as a `cmd | while read` loop, `$( … )` or `( … )`. Fix: feed the loop with a redirect, `while read -r f; do …; done < file`.

**The script keeps running after `fatal`**: this is by design. Fix: add the exit yourself, `[[ -d $dir ]] || { fatal "Missing $dir"; exit 1; }`.

**No colours**: output is going to a file or pipe (including `tee`), or `NO_COLOR` is set. This is intended and keeps log files clean.

**Strange colours, hidden text or fake log lines**: a message contained untrusted input with control characters or newlines. Fix: sanitise it before logging; see [Known limitations and safe usage](docs/SECURITY.md#known-limitations-and-safe-usage).

## Contributing

Contributions are welcome, including AI-assisted ones. Before contributing,
please read and follow the [contributing guide](docs/CONTRIBUTING.md).

Security vulnerabilities must be reported as described in the [security policy](docs/SECURITY.md),
never in a public issue.

Changes are listed in the [changelog](docs/CHANGELOG.md).

Contributions are accepted under the [project's licence](LICENSE), `AGPL-3.0`.

## AI use disclosure

The code and documentation were written with the help of Claude (Anthropic). The maintainer defined the requirements, directed the changes and is responsible for the project.
Testing so far was done on GNU Bash 5.2 on Linux, so review the code before relying on it in production.
See the [user guide](docs/GUIDE.md#ai-use-and-the-eu-ai-act) for why this disclosure is voluntary under the EU AI Act.

## License

Copyright (C) 2026 [Someone-Offline](https://github.com/Someone-Offline).

Released under the [GNU Affero General Public License v3.0](LICENSE), without any warranty. Contributions are accepted under the same licence.

You should have received a copy of the GNU Affero General Public License v3.0 along
with this program, in the [`LICENSE`](LICENSE) file. If not, see
<https://www.gnu.org/licenses/>.

SPDX-License-Identifier: `AGPL-3.0`
