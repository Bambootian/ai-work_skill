# block-superpowers-specs-dir.ps1 - Tier 1 (PreToolUse, matcher: Write)
# In an OpenSpec project every spec/design artifact lives under
#   openspec/changes/<change-id>/   (active)
#   openspec/specs/<capability>/    (living spec, written by archive)
# The brainstorming skill's default output path docs/superpowers/specs/ is
# never correct there: it means the skill's built-in write-up steps are being
# followed instead of the project's change-loop.
# Exit 2 = block; stderr is shown to the model. Bad stdin JSON = exit 1.
[Console]::InputEncoding = New-Object System.Text.UTF8Encoding $false
try { $json = [Console]::In.ReadToEnd() | ConvertFrom-Json -ErrorAction Stop }
catch { [Console]::Error.WriteLine('block-superpowers-specs-dir: bad stdin JSON'); exit 1 }
$path = [string]$json.tool_input.file_path
if ($path -match 'docs[/\\]superpowers[/\\]specs') {
  [Console]::Error.WriteLine('BLOCKED: do not write to docs/superpowers/specs/. In OpenSpec projects design docs are produced by /opsx:propose under openspec/changes/<change-id>/; living specs go to openspec/specs/<capability>/spec.md via archive.')
  exit 2
}
exit 0
