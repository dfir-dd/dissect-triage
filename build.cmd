:: create self signed certificate with
:: New-SelfSignedCertificate -Subject "Telekom MMS Incident Response Service" -NotAfter (Get-Date).AddMonths(24) -Type CodeSigningCert
::

set CARGO_MANIFEST_DIR=.
set TARGET=x86_64-pc-windows-msvc
set PROFILE=release
set OUT_DIR=target\out
pyoxidizer run-build-script --var ENABLE_CODE_SIGNING 1 build.rs 

set PYOXIDIZER_ARTIFACT_DIR=%CD%\target\out
set PYO3_CONFIG_FILE=%CD%\target\out\pyo3-build-config-file.txt
cargo build --release --no-default-features --features "build-mode-prebuilt-artifacts"