# Contributing to simpleLog

Thank you for your interest in improving simpleLog. Bug reports, fixes,
documentation improvements, testing on untested platforms and feature ideas
are all welcome. This is a small project with a single maintainer, so clear,
focused contributions are the easiest to review and merge. Before you start,
read the section below that matches what you want to do.

## Table of contents

Use these links to jump to the section you need.

* [Code of conduct](#code-of-conduct)
* [Questions and support](#questions-and-support)
* [Ways to contribute](#ways-to-contribute)
  * [Reporting bugs](#reporting-bugs)
  * [Reporting security vulnerabilities](#reporting-security-vulnerabilities)
  * [Suggesting enhancements](#suggesting-enhancements)
  * [Your first code contribution](#your-first-code-contribution)
  * [Improving the documentation](#improving-the-documentation)
* [Project principles](#project-principles)
* [Development setup](#development-setup)
* [Development workflow](#development-workflow)
  * [Branch naming](#branch-naming)
  * [Running the checks](#running-the-checks)
  * [Commit messages](#commit-messages)
  * [Signing off your commits](#signing-off-your-commits)
  * [Updating the changelog](#updating-the-changelog)
  * [Pull requests](#pull-requests)
  * [Code review](#code-review)
* [Coding style](#coding-style)
* [AI-assisted contributions](#ai-assisted-contributions)
* [Licensing of contributions](#licensing-of-contributions)

## Code of conduct

Be respectful and constructive, and criticise code, not people. Harassment or
abuse of any kind is not tolerated. The maintainer may remove comments, close
issues or block accounts that do not follow these rules. To report
unacceptable behaviour, contact the maintainer,
[Someone-Offline](https://github.com/Someone-Offline), on GitHub.

## Questions and support

Ask questions in the repository's
[GitHub Discussions](https://github.com/Someone-Offline/simpleLog/discussions),
not in issues. Issues are for bugs and agreed changes.

Before you ask, check the
[Troubleshooting section of the README](../README.md#troubleshooting) and
search existing discussions and issues. When you ask, include your Bash
version (`bash --version`), your operating system and a short example of
what you are trying to do.

## Ways to contribute

Pick the type of contribution below. Each one has its own process.

### Reporting bugs

A good bug report lets the maintainer reproduce the problem on the first try.

#### Before you report a bug

1. Make sure you are using the latest `simpleLog.sh` from the `main` branch.
   Only the latest version receives fixes.
2. Check the [Troubleshooting section of the README](../README.md#troubleshooting).
   Several common surprises, such as `fatal` not exiting, are deliberate.
3. Check the [known limitations](SECURITY.md#known-limitations-and-safe-usage).
   Behaviour listed there is documented, not a bug.
4. Search the [existing issues](https://github.com/Someone-Offline/simpleLog/issues)
   to see whether the problem has already been reported.

#### How to submit a good bug report

Open a new issue with a short, specific title, and include these details:

* Bash version: the output of `bash --version`.
* Operating system and, if timestamps are involved, your `date` version:
  `date --version` for GNU, or "BSD date" on macOS.
* Where the output went: a terminal, a file or a pipe.
* A minimal script that reproduces the problem.
* What you expected to happen, and what happened instead, including the exact
  output or error message.
* Optionally, what you think the cause is or what you have already tried.

### Reporting security vulnerabilities

Security problems need a private channel so that they can be fixed before
anyone can exploit them.

> [!IMPORTANT]
> Do not report security vulnerabilities in public issues or discussions.
> Report them privately as described in the [security policy](SECURITY.md).

### Suggesting enhancements

Open an issue before you write any code, so that you and the maintainer can
agree that the idea fits the [project principles](#project-principles). In the
issue, include these details:

* A clear, descriptive title.
* The current behaviour, and the behaviour you propose.
* Why the change would help most people who use simpleLog, not only your
  own script.
* Any alternatives you considered, including solving it in your own script.

Changes to the public interface, listed in the
[project principles](#project-principles), need this discussion before a pull
request is opened.

### Your first code contribution

These are good places to start, because the project explicitly needs them:

* Testing on an older Bash or on macOS, which are currently untested, and
  reporting the results in an issue.

Then follow the [development setup](#development-setup) and the
[development workflow](#development-workflow).

### Improving the documentation

The documentation is in [`README.md`](../README.md),
[`SECURITY.md`](SECURITY.md), [`CHANGELOG.md`](../CHANGELOG.md) and this
file. Typo fixes and clarifications can go straight to a pull request, without
an issue first. Write documentation in UK English, for example "colour",
"behaviour", and "licence" as a noun.

## Project principles

Every change is judged against these goals, so read them before you propose a
feature.

1. **Single file:** The library stays one sourceable file, `simpleLog.sh`.
2. **No dependencies on Bash 5.0 or later:** The normal path uses no external
   commands. Older Bash may fall back to standard tools such as `date`.
3. **Small:** New features must be useful to most people who use the library.
   Niche needs are better solved in their own scripts.
4. **Safe in strict mode:** Everything must work under `set -euo pipefail`.
5. **Clean output:** No colour codes may reach files or pipes.
6. **Stable public interface:** The functions `trace`, `debug`, `info`,
   `warn`, `error` and `fatal`, the variables `LOG_LEVEL` and `NO_COLOR`, and
   the arrays `WARNINGS`, `ERRORS` and `FATALS` are public. Functions whose
   names start with `_` are internal and may change.

## Development setup

You need Bash 5.0 or later and Git. [ShellCheck](https://www.shellcheck.net)
is recommended. simpleLog has no build step and no other dependencies.

1. On GitHub, open the
   [simpleLog repository](https://github.com/Someone-Offline/simpleLog) and
   click **Fork**.
2. Clone your fork, replacing `YOUR-USERNAME` with your GitHub username:

   ```shell
   git clone https://github.com/YOUR-USERNAME/simpleLog.git
   cd simpleLog
   ```

3. Add the original repository as `upstream`, so that you can keep your fork
   up to date:

   ```shell
   git remote add upstream https://github.com/Someone-Offline/simpleLog.git
   ```

4. To confirm that everything works, run the demo:

   ```shell
   bash simpleLog.sh
   ```

For how the library is used, see the [README](../README.md).

## Development workflow

Every change goes through a pull request from a branch in your fork.

### Branch naming

Create a branch from an up-to-date `main`. Name it with the type of change and
a short description, using the same types as
[commit messages](#commit-messages) in lower case:

```shell
git switch main
git pull upstream main
git switch -c fix/bsd-date-milliseconds
```

### Running the tests

> [!NOTE]
> There is no automated test suite or continuous integration (CI) yet. These
> manual checks are the only tests, so run every one of them.

Run all five test before you open a pull request, and say in the pull
request which Bash version and operating system you ran them on.

> [!NOTE]
> These tests may not reach a Quality Gating and good percentage coverage, test suites and improvements are are all welcome.

1. To check the syntax, enter this command. No output means no errors.

   ```shell
   bash -n simpleLog.sh
   ```

2. To check the demo, run the file. All six levels must appear, and the line
   after `FATAL` must still be printed.

   ```shell
   bash simpleLog.sh
   ```

3. To check strict mode and level filtering, run this script. Only the `INFO`
   and `FATAL` lines must appear, followed by `W=1 E=0 F=1 still alive`.

   ```shell
   bash -c 'set -euo pipefail; source ./simpleLog.sh
     trace t; debug d; info i
     LOG_LEVEL=ERROR warn hidden; fatal f
     echo "W=${#WARNINGS[@]} E=${#ERRORS[@]} F=${#FATALS[@]} still alive"'
   ```

4. To check that no colour codes reach files, run these commands. The `grep`
   command must print `0`.

   ```shell
   log=$(mktemp)
   bash simpleLog.sh > "$log" 2>&1
   grep -c $'\e' "$log"
   rm -f "$log"
   ```

5. To check the timestamp format, run this command. It must print `OK`.

   ```shell
   bash -c 'source ./simpleLog.sh; info x' \
     | grep -Eq '^[0-9]{4}-[0-9]{2}-[0-9]{2}--[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]{3} ' \
     && echo OK
   ```

If you can, also run the checks on an older Bash or on macOS, and report the
results in the pull request.

### Commit messages

Write commit messages in the
[Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) format,
with the type in Pascal case and the summary in the imperative mood:

```text
Type(optional-scope): Summary in the imperative mood

Optional body explaining why the change was made.

Signed-off-by: Your Name <you@example.com>
```

Use one of these types:

* `Build`: Changes to packaging or release tooling.
* `Chore`: Maintenance that changes neither the library nor its documentation.
* `Docs`: Documentation only.
* `Feat`: A new feature.
* `Fix`: A bug fix.
* `Perf`: A change that improves performance.
* `Refactor`: A code change that neither fixes a bug nor adds a feature.
* `Revert`: Reverts an earlier commit.
* `Style`: Formatting only, with no change in behaviour.
* `Test`: Adds or changes checks.

Keep the first line under about 72 characters, and start the summary with a
capital letter: `Fix(timestamp): Drop milliseconds when date lacks %N`, not
`Fixed timestamps`. For a change that breaks the public interface, add `!`
after the type or scope, as in `Feat!: Rename LOG_LEVEL`, and add a
`BREAKING CHANGE:` footer, in capitals, that explains the migration.

### Signing off your commits

Every commit must be signed off. A sign-off certifies, under the Developer
Certificate of Origin (DCO), that you wrote the change or have the right to
submit it under the project's licence. To sign off, commit with `-s`:

```shell
git commit -s -m "Fix(timestamp): Handle Bash 4.4 without EPOCHREALTIME"
```

Git adds a `Signed-off-by:` line with the name and email from your Git
configuration.

> [!TIP]
> If you forgot to sign off, run `git rebase --signoff main` on your branch
> to add the line to every commit since `main`.

### Updating the changelog

Add an entry for every change that affects people who use the library to
[`CHANGELOG.md`](../CHANGELOG.md), which follows Keep a Changelog. Put the
entry under an `## [Unreleased]` heading above the latest release, creating
the heading if it does not exist, in the right group: `Added`, `Changed`,
`Deprecated`, `Removed`, `Fixed` or `Security`. A breaking change also needs
a migration note.

### Pull requests

Before you open a pull request, make sure it meets these requirements:

1. It contains one change. Put unrelated fixes in separate pull requests.
2. It follows the [coding style](#coding-style).
3. All five [checks](#running-the-checks) pass, and the description says
   which Bash version and operating system you ran them on.
4. The documentation is updated if behaviour changes: `README.md`, and
   `SECURITY.md` if the change affects safety.
5. `CHANGELOG.md` has an entry, as described in
   [updating the changelog](#updating-the-changelog).
6. Every commit is signed off.
7. The description explains what changed and why, links the related issue,
   and discloses any AI assistance as described in
   [AI-assisted contributions](#ai-assisted-contributions).

To open the pull request, push your branch to your fork, then on GitHub click
**Compare & pull request**.

> [!CAUTION]
> If you rebase after review has started, force-push only to your own branch,
> with `git push --force-with-lease`, and say so in a comment. A plain force
> push can overwrite commits and makes earlier review comments hard to follow.

### Code review

The project has a single maintainer, who does all reviews:

* **Approval:** One approval from the maintainer is needed.
* **Merging:** Only the maintainer merges pull requests.

Reviews are done on a best-effort, volunteer basis, so reply to review
comments in the pull request rather than opening a new one.

## Coding style

Follow the style already used in [`simpleLog.sh`](../simpleLog.sh):

* Indent with 4 spaces, not tabs.
* Use `[[ … ]]` for tests and `(( … ))` for arithmetic.
* Quote every expansion (`"$var"`, `"$@"`) unless word splitting is intended,
  and explain why in a comment when it is.
* Declare variables inside functions with `local`.
* Use `printf`, not `echo`, for output.
* Prefix internal functions with `_`.
* Do not use `((n++))` as a statement. It returns failure when `n` is 0, which
  stops scripts running under `set -e`. Use `n=$((n + 1))` instead.
* End functions that may legitimately do nothing with `return 0`, so that they
  do not trip `set -e`.
* Keep comments short, and explain why, not what.
* Write comments in UK English.

To lint the file with ShellCheck, run this command:

```shell
shellcheck simpleLog.sh
```

## AI-assisted contributions

simpleLog itself was written with the help of generative AI, as explained in
the [AI use disclosure in the README](../README.md#ai-use-disclosure).
AI-assisted contributions are welcome on the same terms:

* **Disclose it:** In the pull request, say which parts were generated with
  AI and which tool you used.
* **Understand it:** You must be able to explain and defend every line you
  submit.
* **Test it yourself:** Run all the [checks](#running-the-checks) and report
  the results. AI-generated code can look correct and still be wrong.
* **Take responsibility:** By signing off, you certify the contribution as
  your own submission, however it was produced.

## Licensing of contributions

simpleLog is licensed under the
[GNU Affero General Public License v3.0](../LICENSE). By submitting a
contribution, you agree that it is licensed under the same terms. No separate
contributor licence agreement is required; the
[sign-off](#signing-off-your-commits) is the only certification needed.
