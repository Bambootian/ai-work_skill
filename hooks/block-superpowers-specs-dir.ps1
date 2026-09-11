# block-superpowers-specs-dir.ps1 - Tier 1 (PreToolUse, matcher: Write)
# The brainstorming skill's default output path docs/superpowers/specs/ is never
# correct in a change-loop project: specs live in openspec/changes/<change-id>/
# (OpenSpec projects) or root SPEC.md, moved to docs/changes/ at close (others).
# Writing there means the skill's built-in write-up steps are being followed
# instead of the project's change-loop.
# Exit 2 = block; stderr is shown to the model. Bad stdin JSON = exit 1.
[Console]::InputEncoding = New-Object System.Text.UTF8Encoding $false
[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false
try { $json = [Console]::In.ReadToEnd() | ConvertFrom-Json -ErrorAction Stop }
catch { [Console]::Error.WriteLine('block-superpowers-specs-dir: bad stdin JSON'); exit 1 }
$path = [string]$json.tool_input.file_path
if ($path -match 'docs[/\\]superpowers[/\\]specs') {
  [Console]::Error.WriteLine('BLOCKED: do not write to docs/superpowers/specs/. Specs live where change-loop puts them: openspec/changes/<change-id>/ (OpenSpec projects) or root SPEC.md, moved to docs/changes/ at close (other projects).')
  exit 2
}
exit 0
