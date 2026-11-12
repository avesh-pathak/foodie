Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.IO.Compression.FileSystem

# Rebuilds the launcher icon in the Zomato palette.
#
# Step 1 restores the original artwork from the last APK that still carried it
# (the working tree icons were already recolored once). Step 2 squeezes the
# whole orange band onto red instead of rotating it, which avoids the leftover
# orange patches a naive hue shift produces.

$root = Split-Path -Parent $PSScriptRoot
$res = Join-Path $root 'android\app\src\main\res'
$apk = Join-Path $root 'dist\Foodie-arm64-v8a.apk'
$staging = Join-Path $env:TEMP 'foodie-icon-originals'

if (Test-Path $staging) { Remove-Item $staging -Recurse -Force }
New-Item -ItemType Directory -Path $staging -Force | Out-Null

$zip = [System.IO.Compression.ZipFile]::OpenRead($apk)
$pngs = $zip.Entries |
    Where-Object { $_.FullName -like '*.png' } |
    Sort-Object Length
$i = 0
foreach ($entry in $pngs) {
    $target = Join-Path $staging ("icon{0}.png" -f $i)
    [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $target, $true)
    $i++
}
$zip.Dispose()

$densityOrder = @('mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi')
for ($n = 0; $n -lt $densityOrder.Count -and $n -lt $i; $n++) {
    $dest = Join-Path $res ("mipmap-{0}\ic_launcher.png" -f $densityOrder[$n])
    Copy-Item (Join-Path $staging ("icon{0}.png" -f $n)) $dest -Force
}
Write-Output "restored $i originals"

function Convert-RgbToHsl([int]$R, [int]$G, [int]$B) {
    $r = $R / 255.0; $g = $G / 255.0; $b = $B / 255.0
    $max = [Math]::Max($r, [Math]::Max($g, $b))
    $min = [Math]::Min($r, [Math]::Min($g, $b))
    $l = ($max + $min) / 2.0
    $delta = $max - $min
    $s = 0.0
    if ($delta -ne 0) { $s = $delta / (1 - [Math]::Abs(2 * $l - 1)) }
    $h = 0.0
    if ($delta -ne 0) {
        if ($max -eq $r) { $h = 60 * (($g - $b) / $delta) }
        elseif ($max -eq $g) { $h = 60 * ((($b - $r) / $delta) + 2) }
        else { $h = 60 * ((($r - $g) / $delta) + 4) }
    }
    if ($h -lt 0) { $h += 360 }
    return @($h, $s, $l)
}

function Convert-HslToRgb([double]$h, [double]$s, [double]$l) {
    $c = (1 - [Math]::Abs(2 * $l - 1)) * $s
    $hp = $h / 60.0
    $x = $c * (1 - [Math]::Abs(($hp % 2) - 1))
    $r1 = 0.0; $g1 = 0.0; $b1 = 0.0
    if ($hp -lt 1) { $r1 = $c; $g1 = $x }
    elseif ($hp -lt 2) { $r1 = $x; $g1 = $c }
    elseif ($hp -lt 3) { $g1 = $c; $b1 = $x }
    elseif ($hp -lt 4) { $g1 = $x; $b1 = $c }
    elseif ($hp -lt 5) { $r1 = $x; $b1 = $c }
    else { $r1 = $c; $b1 = $x }
    $m = $l - $c / 2
    return @(
        [int][Math]::Round(($r1 + $m) * 255),
        [int][Math]::Round(($g1 + $m) * 255),
        [int][Math]::Round(($b1 + $m) * 255)
    )
}

foreach ($density in $densityOrder) {
    $path = Join-Path $res "mipmap-$density\ic_launcher.png"
    if (-not (Test-Path $path)) { continue }

    $src = [System.Drawing.Bitmap]::FromFile($path)
    $out = New-Object System.Drawing.Bitmap $src.Width, $src.Height

    for ($y = 0; $y -lt $src.Height; $y++) {
        for ($x = 0; $x -lt $src.Width; $x++) {
            $c = $src.GetPixel($x, $y)
            $hsl = Convert-RgbToHsl $c.R $c.G $c.B
            $h = $hsl[0]; $s = $hsl[1]; $l = $hsl[2]

            # The whole warm band (orange through amber) lands on red.
            if ($s -gt 0.18 -and $h -ge 4 -and $h -le 90) {
                $h = (352 + (($h - 4) / 86.0) * 16) % 360
                $s = [Math]::Min(1.0, $s * 1.02)
                $l = [Math]::Min(0.58, [Math]::Max(0.26, $l * 0.86))
            }

            $rgb = Convert-HslToRgb $h $s $l
            $out.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($c.A, $rgb[0], $rgb[1], $rgb[2]))
        }
    }

    $src.Dispose()
    $out.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $out.Dispose()
    Write-Output "rebranded $density"
}
