# Runs the test suite with a stable temp root.
#
# flutter_tools creates a listener file under %TEMP% and deletes it again when
# the run finishes. On this machine an external cleaner can remove that folder
# first, which makes the runner exit with
#
#   PathNotFoundException: Deletion failed, path = ...\flutter_test_listener...
#
# even though every test passed. Pointing TMP/TEMP at a project-local folder
# keeps the run deterministic.
$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$tmp = Join-Path $root '.testtmp'
New-Item -ItemType Directory -Path $tmp -Force | Out-Null

$env:TMP = $tmp
$env:TEMP = $tmp

Push-Location $root
try {
    flutter test @args
} finally {
    Pop-Location
}
