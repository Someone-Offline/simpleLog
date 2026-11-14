# Security Policy

## Supported Versions

Use this section to tell people about which versions of your project are
currently being supported with security updates.

| Version | Supported          |
| ------- | ------------------ |
| 5.1.x   | :white_check_mark: |
| 5.0.x   | :x:                |
| 4.0.x   | :white_check_mark: |
| < 4.0   | :x:                |

## Reporting a Vulnerability

Use this section to tell people how to report a vulnerability.

Tell them where to go, how often they can expect to get an update on a
reported vulnerability, what to expect if the vulnerability is accepted or
declined, etc.

## Supported versions

This project is maintained on a best-effort basis by a single maintainer.
Security fixes are applied to the latest version on the default branch only.

| Version | Supported |
|---|---|
| Latest commit on the default branch | ✅ |
| Older commits, forks and modified copies | ❌ |

If you have copied `log-simple.sh` into your own project, update your copy
from the default branch to receive fixes.

---

## Reporting a vulnerability

**Do not open a public issue for a security problem.**
 
Report it privately through this repository's **Security** tab, using **Report a vulnerability** or contact **[Someone-Offline](https://github.com/Someone-Offline)**.

Include, where possible:

- A description of the issue and its impact.
- The Bash version (`bash --version`) and operating system.
- Minimal steps that reproduce it.
- Any suggested fix or mitigation.

### What to expect

| Stage | Target |
|---|---|
| Acknowledgement of your report | On a best-effort basis. |
| Assessment (accepted / declined, with reasons) | On a best-effort basis. |
| Fix or mitigation for accepted reports | As soon as practical, depending on severity and complexity |

These are targets, not guarantees, as this is a volunteer project. You will be
kept informed of progress, and you are welcome to ask for an update at any time.

### Coordinated disclosure

- Allow time for a fix before disclosing publicly.
- Once fixed, the issue will be described in a GitHub Security Advisory.
- Reporters are credited in the advisory unless they prefer to remain
  anonymous.

---

## Scope

### In scope

Issues in `log-simple.sh` itself, for example:

- Code execution, or evaluation of message content as code.
- Format-string handling that lets message content alter output formatting.
- Behaviour that writes to, creates or overwrites files unexpectedly.
- Environment variables (`LOG_LEVEL`, `NO_COLOR`, `EPOCHREALTIME`, …) causing
  anything beyond their documented effect.
- Examples in the documentation that encourage unsafe practice.

### Out of scope

- Vulnerabilities in Bash, `date`, the terminal emulator or the operating system.
  Please report those to their respective maintainers.
- Scripts that use this library, unless the problem is caused by the library.
- Modified copies of `log-simple.sh`.
- The known limitations listed below, unless you have found a way to make them
  worse than described.

---

## Known limitations and safe usage

These are documented behaviours, not vulnerabilities, but users should be
aware of them.

### 1. Messages are printed as given, not sanitised

The library always passes messages through `printf '%s'`, so they cannot inject
format directives. It does **not** remove control characters. If a message
contains **untrusted input** (file names, user input, network data, HTTP
headers), that input can:

- **Inject terminal escape sequences**, changing colours, hiding text, moving
  the cursor or, on some terminals, triggering terminal-specific behaviour.
- **Inject newlines**, creating fake log lines such as
  `2026-11-14--16-13-01-408 INFO:  backup completed`.

If you log untrusted data, sanitise it first or show it unambiguously.

### 2. Only source the library from a trusted location

`source` runs the file as code with the full permissions of your script. Load it
by a path you control, such as one next to your script, never from a
world-writable directory, the current working directory of an untrusted user,
or a path built from untrusted input.

### 3. Do not write logs to predictable paths in shared directories

If you redirect stderr to a file, avoid fixed names in world-writable
directories such as `/tmp` (for example `/tmp/myscript.log`). Another local
user could create that path in advance as a symlink, causing your script to
append to a file of their choosing. This matters most for scripts run as
root. Prefer:

- A directory owned by the user running the script (e.g. `$HOME`, or
  `/var/log/<app>/` with correct ownership and permissions), or
- A unique file created with `mktemp`.

### 4. Logs may contain sensitive data

The library writes exactly what it is given. Do not pass passwords, tokens,
keys or personal data to any log level, including `trace` and `debug`. Those
levels are hidden by default but can be switched on with `LOG_LEVEL`.

### 5. The code was written with AI assistance

`log-simple.sh` was generated with the help of an AI system (see *AI use
disclosure* in [`README.md`](README.md)) and tested only on GNU Bash 5.2 on
Linux. AI-generated code can contain mistakes that look plausible. Review the
file before using it in sensitive contexts,
and report anything suspicious through the process above.

### 6. Collected messages live in shell variables

`WARNINGS`, `ERRORS` and `FATALS` are ordinary Bash arrays. Anything that can
read your script's memory or variables (for example `set -x` output, or a
debugging trap) can read them. They are not written to disk unless your script
does so.
