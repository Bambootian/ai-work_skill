# warn-backlog-size.ps1 - Tier 2 (PostToolUse, matcher: Write|Edit|Bash|PowerShell)
# backlog.md is an index (budget 8KB); over budget = move content out, never
# delete it. For Bash/PowerShell commands that mention backlog.md the file in
# cwd is checked. Exit 2 + stderr (visible to the model). Bad stdin JSON = exit 1.
[Console]::InputEncoding = New-Object System.Text.UTF8Encoding $false
try { $json = [Console]::In.ReadToEnd() | ConvertFrom-Json -ErrorAction Stop }
catch { [Console]::Error.WriteLine('warn-backlog-size: bad stdin JSON'); exit 1 }
$p = $json.tool_input.file_path
if (-not $p -and $json.cwd -and ($json.tool_input.command -match 'backlog\.md')) { $p = Join-Path $json.cwd 'backlog.md' }
if ($p -and ($p -match '(^|[\\/])backlog\.md$') -and (Test-Path -LiteralPath $p -PathType Leaf)) {
  $len = (Get-Item -LiteralPath $p).Length
  if ($len -gt 8KB) {
    $kb = '{0:N1}' -f ($len / 1KB)
    [Console]::Error.WriteLine("backlog.md is ${kb}KB; budget is 8KB (about 2.5k tokens). backlog.md is an index, not a body: move readouts, rulings and handoff history to their own files (toolkit GUIDE section 6) and keep one line plus a path here. Do not delete information.")
    exit 2
  }
}
exit 0
