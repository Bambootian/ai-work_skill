# warn-route-before-opsx.ps1 - Tier 2 (PreToolUse, matcher: Skill)
# Reminds the model that change-loop's route declaration must precede any
# change-creating opsx command. Command list: check against the installed
# OpenSpec version (propose / new / ff create changes as of 1.13).
# Exit 0 + JSON additionalContext. Bad stdin JSON = exit 1.
[Console]::InputEncoding = New-Object System.Text.UTF8Encoding $false
[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false
try { $json = [Console]::In.ReadToEnd() | ConvertFrom-Json -ErrorAction Stop }
catch { [Console]::Error.WriteLine('warn-route-before-opsx: bad stdin JSON'); exit 1 }
if ($json.tool_input.skill -cmatch '^opsx:(propose|new|ff)$') {
  $msg = "This project requires a change-loop route declaration (Route / mainline / Next lines) before $($json.tool_input.skill). If none was posted this session, stop and invoke change-loop first."
  @{ hookSpecificOutput = @{ hookEventName = 'PreToolUse'; additionalContext = $msg } } | ConvertTo-Json -Compress
}
exit 0
