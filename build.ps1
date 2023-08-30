$build_dir_name = "full-acquire"
$build_dir=$PSScriptRoot + "\" + $build_dir_name
$env:CARGO_MANIFEST_DIR=$build_dir
$env:TARGET="x86_64-pc-windows-msvc"
$env:PROFILE="release"
$env:OUT_DIR=$build_dir + "\target\out"
$env:PYOXIDIZER_ARTIFACT_DIR=$env:OUT_DIR
$env:PYO3_CONFIG_FILE=$build_dir + "\target\out\pyo3-build-config-file.txt"

rm -r $build_dir_name |out-null

$mt = "${env:ProgramFiles(x86)}\Windows Kits\10\bin\10.0.22621.0\x64\mt.exe"

# stage 1: use "pyoxidizer build" to create a simple executable, without resources file

mkdir $build_dir_name
try {
    copy pyoxidizer.bzl $build_dir_name
    copy build.rs $build_dir_name
    copy full-acquire-manifest.rc $build_dir_name
    copy full-acquire.exe.manifest $build_dir_name
    copy triage.py $build_dir_name
    copy -R media $build_dir_name

    Push-Location $build_dir_name

    pyoxidizer build --release

    copy -R build\x86_64-pc-windows-msvc\release\install ..
} catch {
    Write-Warning "An error occurred"
}
finally {
    Pop-Location
    rm -r $build_dir_name
}

& $mt -nologo -manifest full-acquire.exe.manifest -outputresource:"install\full-acquire.exe;#1"
& 'ResourceHacker.exe' -open "install\full-acquire.exe" -save "install\full-acquire2.exe" -action addskip -res "media\fuchs_blau.ico" -mask "ICONGROUP,MAINICON,"
exit


# set SIGNTOOL="C:\Program Files (x86)\Windows Kits\10\bin\10.0.22621.0\x64\signtool"
# %SIGNTOOL% sign /debug /fd certHash /td certHash /n "Telekom MMS Incident Response Service" target\release\full-acquire.exe

# stage 2 seems to be unnecessary

# stage 2: create a more complicate binary and integrate it in the directory structure create by the first stage

#rm -r $build_dir_name
pyoxidizer init-rust-project $build_dir_name

try {
    copy pyoxidizer.bzl $build_dir_name
    copy build.rs $build_dir_name
    copy full-acquire-manifest.rc $build_dir_name
    copy full-acquire.exe.manifest $build_dir_name
    copy triage.py $build_dir_name
    copy -R media $build_dir_name

    Push-Location $build_dir_name

    pyoxidizer run-build-script --var ENABLE_CODE_SIGNING 1 build.rs 

    cargo build --release --no-default-features --features "build-mode-prebuilt-artifacts"
    copy target\release\full-acquire.exe ..\install\full-acquire.exe
} catch {
    Write-Warning "An error occurred"
}
finally {
    Pop-Location
    rm -r $build_dir_name
}

rename-item install $build_dir_name