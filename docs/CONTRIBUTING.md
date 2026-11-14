# Contributing to log-simple

Thank you for your interest in improving `log-simple`. This is a small,
single-maintainer project, so clear and focused contributions are the easiest
to review and merge.

## Ways to contribute

- **Report a bug**: open an issue (see [Reporting bugs](#reporting-bugs)).
- **Suggest a feature**: open an issue first, before writing code, so we can
  agree that it fits the project.
- **Improve the documentation**: typo fixes and clarifications can go straight
  to a pull request.
- **Submit code**: see [Pull requests](#pull-requests).

> **Security vulnerabilities must not be reported in public issues.**
> Follow [`SECURITY.md`](SECURITY.md) instead.

---

## Project principles

Changes are judged against these goals. Please keep them in mind before
proposing a feature.

1. **Single file.** The library stays one sourceable file, `log-simple.sh`.
2. **No dependencies on Bash 5+.** No external commands in the normal path.
   Older Bash may fall back to standard tools such as `date`.
3. **Small.** New features must be useful to most users. Niche needs are better
   solved in the user's own script.
4. **Safe in strict mode.** Everything must work under `set -euo pipefail`.
5. **Clean output.** No colour codes may reach files or pipes.
6. **Stable public interface.** The functions `trace`, `debug`, `info`, `warn`,
   `error`, `fatal`, the variables `LOG_LEVEL` and `NO_COLOR`, and the arrays
   `WARNINGS`, `ERRORS`, `FATALS` are public. Functions starting with `_` are
   internal and may change.

---

## Reporting bugs

Please include:

- Bash version: `bash --version`
- Operating system, and `date` version if relevant: `date --version`
  (GNU) or "BSD date" (macOS)
- Whether the output went to a terminal, a file or a pipe
- A minimal script that reproduces the problem
- What you expected to happen, and what happened instead

---

## Pull requests

1. **Fork** the repository and create a branch from the default branch:
   ```bash
   git switch -c fix/short-description
   ```
2. **Make one change per pull request.** Unrelated fixes belong in separate
   pull requests.
3. **Follow the [coding style](#coding-style).**
4. **Run the [tests](#testing)** and say in the pull request what you ran and
   on which Bash version and OS.
5. **Update the documentation** if behaviour changes: `README.md`, and
   `SECURITY.md` if the change affects safety.
6. **Add an entry to `CHANGELOG.md`** in the proper version/release, in the right
   group (`Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`).
7. **Open the pull request** with a clear description of *what* changed and
   *why*.

Breaking changes to the public interface need prior discussion in an issue and
a migration note in `CHANGELOG.md`.

---

## Coding style

Follow the style already used in `log-simple.sh`:

- Indent with **4 spaces**, no tabs.
- Use `[[ … ]]` for tests and `(( … ))` for arithmetic.
- **Quote every expansion** (`"$var"`, `"$@"`) unless word splitting is
  intended, and say why in a comment when it is.
- Declare function variables with `local`.
- Use `printf`, not `echo`, for output.
- Prefix internal functions with `_`.
- Avoid `((n++))` as a statement: it returns failure when `n` is 0 and
  stops scripts running under `set -e`. Use `n=$((n + 1))`.
- End functions that may legitimately "do nothing" with `return 0`, so they do
  not trip `set -e`.
- Keep comments short and explain *why*, not *what*.
- Write comments and documentation in **UK English** (e.g. *colour*,
  *behaviour*, *licence* as a noun).

Linting with **ShellCheck** is recommended:

```bash
shellcheck log-simple.sh
```

> The current code has not yet been checked with ShellCheck. If it reports
> warnings on existing code, a pull request fixing them is welcome.

---

## Testing

There is no automated test suite yet. Before opening a pull request, please
run these checks and confirm the expected results.

**1. Syntax check**: no output means no errors:
```bash
bash -n log-simple.sh
```

**2. Demo**: all six levels appear, and the line after `FATAL` is still printed:
```bash
bash log-simple.sh
```

**3. Strict mode and level filtering**: only `INFO` and `FATAL` are shown,
then `W=1 E=0 F=1 still alive`:
```bash
bash -c 'set -euo pipefail; source ./log-simple.sh
         trace t; debug d; info i; LOG_LEVEL=ERROR warn hidden; fatal f
         echo "W=${#WARNINGS[@]} E=${#ERRORS[@]} F=${#FATALS[@]} still alive"'
```

**4. No colour in files**: must print `0`:
```bash
bash log-simple.sh > /tmp/out.log 2>&1; grep -c $'\e' /tmp/out.log
```

**5. Timestamp format**: must print `OK`:
```bash
bash -c 'source ./log-simple.sh; info x' \
  | grep -Eq '^[0-9]{4}-[0-9]{2}-[0-9]{2}--[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]{3} ' && echo OK
```

If you can, also test on an older Bash or on macOS, and mention it in the pull
request. Those platforms are currently untested.

---

## Commit messages

- Use the imperative mood: *"Add microsecond option"*, not *"Added …"*.
- Keep the first line under about 72 characters.
- Explain *why* in the body if it is not obvious.

### Sign-off

Please sign off each commit to certify that you wrote the change or have the
right to submit it under the project's licence (the *Developer Certificate of
Origin*):

```bash
git commit -s -m "Fix timestamp on Bash 4.4"
```

This adds a `Signed-off-by: Your Name <you@example.com>` line.

---

## AI-assisted contributions

This project itself was written with the help of generative AI (see
*AI use disclosure* in [`README.md`](README.md)), and AI-assisted contributions
are welcome on the same terms:

- **Disclose it.** Say in the pull request which parts were generated with AI
  and which tool you used.
- **Understand it.** You must be able to explain and defend every line you
  submit.
- **Test it yourself.** Run the [tests](#testing) and report the results;
  AI-generated code can look correct and still be wrong.
- **Take responsibility.** By signing off, you certify the contribution as your
  own submission, however it was produced.

---

## Licence

This project is licensed under the **GNU Affero General Public License v3.0** (`AGPL-3.0`). By submitting a contribution, you agree that it
is licensed under the same terms. No separate contributor licence agreement is
required.

---

## Conduct

Be respectful and constructive. Criticise code, not people. Harassment or abuse
of any kind is not tolerated, and the maintainer may remove comments, close
issues or block users who do not follow this.
