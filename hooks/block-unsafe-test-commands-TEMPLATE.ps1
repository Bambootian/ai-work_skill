# block-unsafe-test-commands.ps1 - Tier 1 (PreToolUse, matcher: Bash|PowerShell)
# Bare test-runner invocations trigger heavy/integration tests (multi-GB data,
# containers, e2e browsers) in parallel and can freeze the machine. This hook
# blocks them across every change and session.
#
# PROJECT CUSTOMIZATION - exactly three placeholders, each recurring in the
# comments, the code and the block message. Replace ALL occurrences, save the
# file without the -TEMPLATE suffix, then `grep -E '<[A-Z_]+>'` must be empty.
#   <TEST_CMD_REGEX>      regex matching the bare test command, e.g.
#                           '\bdotnet\s+test\b'                (.NET)
#                           '\bpytest\b'                        (Python)
#                           '\bgo\s+test\b'                     (Go)
#                           '\bnpm\s+(?:test|run\s+test)\b'     (Node)
#                           '\bcargo\s+test\b'                  (Rust)
#   <SAFE_FILTER_REGEX>   regex proving a scope-narrowing flag is present.
#                         MATCHED AGAINST THE ARGUMENT TAIL AFTER THE RUNNER
#                         NAME, never the whole command line (see below).
#                           '--filter\b'                        (.NET)
#                           '(^|\s)-(k|m)(\s|=)'                (pytest)
#                           '(^|\s)-run(\s|=)'                  (Go)
#                           '--testNamePattern\b'               (Jest)
#                           '\s--\s.*\btest::'                  (Cargo, partial)
#   <ESCAPE_VAR>          project-specific env var authorising a full run,
#                         e.g. MYPROJECT_ALLOW_FULL_TEST (avoid generic names).
#
# Runner-name split (2026-08-09, zd-tool):
#   The filter check runs on the substring AFTER the runner name. Reason:
#   `python -m pytest` contains a bare ` -m ` that belongs to Python, not to
#   pytest; a whole-line match on '-m' would allow EVERY bare full-suite run
#   and the hook would be silently dead while looking installed. Same class:
#   `go -run`, `npm test -- -t`, any wrapper reusing a short flag letter.
#   CAUTION: <TEST_CMD_REGEX> doubles as the split point, so it must use
#   NON-capturing groups '(?:...)'. PowerShell -split injects captured groups
#   into the result array; a capturing group makes [1] the captured text
#   instead of the argument tail (verified 2026-08-09).
#
# Rules:
#   runner without a scope flag and without <ESCAPE_VAR>=1  -> block
#   runner with a scope flag                                 -> allow
#   <ESCAPE_VAR>=1 before the runner                         -> allow
#   any command not invoking the runner                      -> allow
#   Subagents MUST NEVER set <ESCAPE_VAR>=1 on their own; only the human or
#   main-loop Claude after explicit human authorisation. Restate this in
#   every subagent dispatch (dispatch-prompt.md Constraints slot).
#   Known false positive: the runner name inside literal text (a commit
#   message, a heredoc, a report) is blocked too - write the text to a file
#   and use `git commit -F`, or rephrase.
#
# Exit 2 = block; stderr is shown to the model. Bad stdin JSON = exit 1.
[Console]::InputEncoding = New-Object System.Text.UTF8Encoding $false
[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false
try { $json = [Console]::In.ReadToEnd() | ConvertFrom-Json -ErrorAction Stop }
catch { [Console]::Error.WriteLine('block-unsafe-test-commands: bad stdin JSON'); exit 1 }
$cmd = [string]$json.tool_input.command
if (-not $cmd) { exit 0 }

# Only inspect commands that actually invoke the test runner.
if ($cmd -notmatch '<TEST_CMD_REGEX>') { exit 0 }

# Escape hatch: explicit authorisation via env var (bash prefix or PowerShell assignment).
if ($cmd -match '<ESCAPE_VAR>\s*=\s*1' -or
    $cmd -match '\$env:<ESCAPE_VAR>\s*=\s*[''"]?1') { exit 0 }

# Allow if a scope-narrowing flag is present in the ARGUMENT TAIL after the runner name.
$tail = ($cmd -split '<TEST_CMD_REGEX>', 2)[1]
if ($tail -match '<SAFE_FILTER_REGEX>') { exit 0 }

# Everything else is a bare full-suite run.
[Console]::Error.WriteLine(@"
BLOCKED: bare test command is forbidden in this project.

Reason: full-suite runs trigger heavy/integration tests that consume RAM,
containers or external services concurrently and can crash the machine.

Use a scoped run instead - the filter flag and examples are in CLAUDE.md
Stack & Conventions (test command discipline).

If you GENUINELY need a full run (verify phase, archive prep, after human
authorisation), prefix the command with <ESCAPE_VAR>=1.

Subagents MUST NOT set this variable. Only main-loop Claude may, after the
human explicitly approved a full run for this specific moment.

If the runner name only appears inside literal text (commit message, heredoc,
report), write the text to a file and use `git commit -F`, or rephrase.
"@)
exit 2
