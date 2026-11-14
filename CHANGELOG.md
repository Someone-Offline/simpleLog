# Changelog

All notable changes to this project are documented in this file.

The format is based on *Keep a Changelog* (version 1.1.0), and this project
follows *Semantic Versioning* (version 2.0.0). While the version is below
1.0.0, minor releases (0.x.0) may include breaking changes; these are always
listed under **Changed** or **Removed** with migration notes.

## [0.1.0] - 2026-11-14

First public release.

### Added

- Six log levels:
  `trace`, `debug`, `info`, `warn`, `error`, `fatal`.
- `LOG_LEVEL` variable to set the minimum level shown
  (`TRACE` | `DEBUG` | `INFO` | `WARN` | `ERROR` | `FATAL`, case-insensitive,
  default `INFO`).
- Millisecond timestamps in the format `YYYY-mm-dd--HH-MM-SS-fff`:
  - built in Bash on Bash 5.0+, with no external commands;
  - fallback to `date +%3N` on older Bash;
  - milliseconds dropped automatically when `date` does not support `%N`
    (e.g. BSD `date` on stock macOS), instead of printing invalid output.
- Colour output, used only when the stream is a terminal; disabled with
  `NO_COLOR`.
- Labels padded to a fixed width so messages line up.
- `WARNINGS`, `ERRORS` and `FATALS` arrays collecting problem messages,
  including those hidden by `LOG_LEVEL`.
- Demo of every level when the file is executed directly; silent when sourced.
- SPDX licence identifier and AI-use note in the file header.
- Documentation: `README.md`, `SECURITY.md`, `CHANGELOG.md`.
- Licence: GNU Affero General Public License v3.0 or later.

### Notes

- `fatal` reports but **does not exit**. Scripts must stop themselves, e.g.
  `[[ -d $dir ]] || { fatal "Missing $dir"; exit 1; }`.
- `info` writes to stdout; all other levels write to stderr.
- Messages are not sanitised. See *Known limitations and safe usage* in
  `SECURITY.md` before logging untrusted input.
- Tested on GNU Bash 5.2 on Linux only.

### Development history

Before its first release the library went through private drafts. They were
never published, so they have no version numbers.

[Unreleased]: #unreleased
[0.1.0]: #010---yyyy-mm-dd
