# warn-destructive-git.ps1 - Tier 2 (PreToolUse, matcher: Bash|PowerShell)
# Flags git operations that can lose work irreversibly; they are legal only
# when the user explicitly asked for that exact operation.
# Exit 0 + JSON additionalContext (the only exit-0 output the model can see
# on tool events). Bad stdin JSON = exit 1.
[Console]::InputEncoding = New-Object System.Text.UTF8Encoding $false
try { $json = [Console]::In.ReadToEnd() | ConvertFrom-Json -ErrorAction Stop }
catch { [Console]::Error.WriteLine('warn-destructive-git: bad stdin JSON'); exit 1 }
$cmd = [string]$json.tool_input.command
$patterns = @(
  'git\s+reset\s+--hard',
  'git\s+push\s+--force',
  'git\s+push\s+-f\b',
  'git\s+checkout\s+\.',
  'git\s+checkout\s+--\s*\.',
  'git\s+restore\s+\.',
  'git\s+clean\s+-[a-zA-Z]*f',
  'git\s+branch\s+-D\b'
)
foreach ($p in $patterns) {
  if ($cmd -match $p) {
    $msg = "WARNING: destructive git operation detected: '$cmd'. It can cause irreversible data loss. Proceed only if the USER explicitly requested this exact operation; if you decided it on your own, stop and find a safer alternative."
    @{ hookSpecificOutput = @{ hookEventName = 'PreToolUse'; additionalContext = $msg } } | ConvertTo-Json -Compress
    exit 0
  }
}
exit 0
