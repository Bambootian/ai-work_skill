# block-replaced-skills.ps1 - Tier 1 (PreToolUse, matcher: Skill)
# In an OpenSpec project these superpowers skills are permanently replaced:
#   writing-plans   -> /opsx:propose (design.md + tasks.md + specs)
#   executing-plans -> /opsx:apply   (walks tasks.md with TDD)
# Exit 2 = block; stderr is shown to the model. Bad stdin JSON = exit 1.
[Console]::InputEncoding = New-Object System.Text.UTF8Encoding $false
try { $json = [Console]::In.ReadToEnd() | ConvertFrom-Json -ErrorAction Stop }
catch { [Console]::Error.WriteLine('block-replaced-skills: bad stdin JSON'); exit 1 }
$skill = [string]$json.tool_input.skill
if ($skill -match '^(superpowers:)?writing-plans$') {
  [Console]::Error.WriteLine('BLOCKED: this project uses OpenSpec. Use /opsx:propose instead - propose IS the planning phase (design.md, tasks.md, specs).')
  exit 2
}
if ($skill -match '^(superpowers:)?executing-plans$') {
  [Console]::Error.WriteLine('BLOCKED: this project uses OpenSpec. Use /opsx:apply instead - apply walks tasks.md with TDD.')
  exit 2
}
exit 0
