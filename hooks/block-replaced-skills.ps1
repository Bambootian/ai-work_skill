# block-replaced-skills.ps1 - Tier 1 (PreToolUse, matcher: Skill)
# These superpowers skills are permanently replaced by change-loop:
#   writing-plans   -> change-loop routing: R1 SPEC-lite, R2+ /opsx:propose (OpenSpec projects)
#   executing-plans -> change-loop inner loop (one task per iteration, green to green,
#                      commit per task); OpenSpec projects run it via /opsx:apply
# Exit 2 = block; stderr is shown to the model. Bad stdin JSON = exit 1.
[Console]::InputEncoding = New-Object System.Text.UTF8Encoding $false
[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false
try { $json = [Console]::In.ReadToEnd() | ConvertFrom-Json -ErrorAction Stop }
catch { [Console]::Error.WriteLine('block-replaced-skills: bad stdin JSON'); exit 1 }
$skill = [string]$json.tool_input.skill
if ($skill -match '^(superpowers:)?writing-plans$') {
  [Console]::Error.WriteLine('BLOCKED: writing-plans is replaced by change-loop routing in this project - R1 writes SPEC-lite, R2+ runs /opsx:propose (OpenSpec projects). Invoke change-loop first.')
  exit 2
}
if ($skill -match '^(superpowers:)?executing-plans$') {
  [Console]::Error.WriteLine('BLOCKED: executing-plans is replaced by the change-loop inner loop (one task per iteration, green to green, commit per task); OpenSpec projects run it via /opsx:apply.')
  exit 2
}
exit 0
