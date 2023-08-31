$build_dir_name = $args[0]
$powershell_script = $build_dir_name + ".py"

if (-not(Test-Path -Path $powershell_script)) {
    Write-Error "invalid target name: '$build_dir_name', because no such python script exists"
    exit 1
}

$build_dir=$PSScriptRoot + "\" + $build_dir_name
$env:CARGO_MANIFEST_DIR=$build_dir
$env:TARGET="x86_64-pc-windows-msvc"
$env:PROFILE="release"
$env:OUT_DIR=$build_dir + "\target\out"
$env:PYOXIDIZER_ARTIFACT_DIR=$env:OUT_DIR
$env:PYO3_CONFIG_FILE=$build_dir + "\target\out\pyo3-build-config-file.txt"

$mt = "${env:ProgramFiles(x86)}\Windows Kits\10\bin\10.0.22621.0\x64\mt.exe"

if (Test-Path -Path $build_dir_name) {
    rm -r $build_dir_name |out-null
}
if (Test-Path -Path ($PSScriptRoot + "\install")) {
    rm -r ($PSScriptRoot + "\install") |out-null
}

# stage 1: use "pyoxidizer build" to create a simple executable, without resources file

mkdir $build_dir_name
try {
    copy pyoxidizer.bzl $build_dir_name
    copy build.rs $build_dir_name
    copy ($build_dir_name + "-manifest.rc") $build_dir_name
    copy ($build_dir_name + ".exe.manifest") $build_dir_name
    copy $powershell_script $build_dir_name\triage.py

    Push-Location $build_dir_name

    $ErrorActionPreference = 'Continue'
    pyoxidizer build --release 3>&1 2>&1
    $ErrorActionPreference = 'Stop'
    Write-Host -ForegroundColor Green "Created a triage binary"

    copy -R build\x86_64-pc-windows-msvc\release\install ..
} catch {
    Write-Host "An error occurred:"
    Write-Error $_
}
finally {
    Pop-Location
    rm -r $build_dir_name
}

try {
    Push-Location install
    & $mt -nologo -manifest ("..\" + $build_dir_name + ".exe.manifest") -outputresource:($build_dir_name + ".exe;#1")

    Write-Host -ForegroundColor Green "Added manifest successfully"

    Rename-Item ($build_dir_name + ".exe") ($build_dir_name + "_old.exe")
    $procOptions = @{
        FilePath = '..\ResourceHacker.exe'
        Wait = $true
        NoNewWindow = $true
        ArgumentList = @("-open",($build_dir_name + "_old.exe"),"-save",($build_dir_name + ".exe"),"-action","addskip","-res","..\media\fuchs_blau.ico","-mask","ICONGROUP,MAINICON,")
    }
    Start-Process @procOptions
    Write-Host -ForegroundColor Green "Added icon successfully"

    Remove-Item ($build_dir_name + "_old.exe")
} catch {
    Write-Host "An error occurred:"
    Write-Error $_
}
finally {
    Pop-Location
}

Rename-Item install $build_dir_name