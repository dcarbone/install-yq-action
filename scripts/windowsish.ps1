$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

Write-Host "::group::Prep"

$_base_url = "https://github.com/mikefarah/yq/releases/download"

switch ($Env:RUNNER_ARCH)
{
    "X86" {
        $_arch = "386"
    }
    "X64" {
        $_arch = "amd64"
    }
    default {
        Write-Host "Cannot handle arch of type $Env:RUNNER_ARCH"
        Write-Host "Expected one of: [ X86 X64 ]"
        exit 1
    }
}

$_dir_name = "yq_windows_${_arch}"
$_bin_name = "${_dir_name}.exe"

if ($Env:DL_COMPRESSED -eq "true")
{
    $_dl_name = "${_dir_name}.zip"
    $_dl_path = "$Env:RUNNER_TEMP\${_dl_name}"
}
else
{
    $_dl_name = "${_bin_name}"
    $_dl_path = "$Env:RUNNER_TEMP\${_dir_name}\${_dl_name}"
    New-Item "$Env:RUNNER_TEMP\${_dir_name}\" -ItemType Directory -Force
}

$_dl_url = "${_base_url}/$Env:YQ_VERSION/${_dl_name}"

Write-Host "::endgroup::"

Write-Host "::group::Downloading yq"

Invoke-WebRequest -Uri "${_dl_url}" -OutFile "${_dl_path}"

Write-Host "::endgroup"

if ($Env:DL_COMPRESSED -eq "true")
{
    Write-Host "::group::Expanding archive"
    New-Item "$Env:RUNNER_TEMP\${_dir_name}" -ItemType Directory -Force
    Expand-Archive -LiteralPath "${_dl_path}" -DestinationPath "$Env:RUNNER_TEMP\${_dir_name}"
    Remove-Item -Force -Path "${_dl_path}"
    Write-Host "::endgroup::"
}

Write-Host "::group::Copying to temporary dir"
Move-Item -Force -LiteralPath "$Env:RUNNER_TEMP\${_dir_name}\${_bin_name}" -Destination "$Env:YQ_BIN_DIR\yq"
Remove-Item -Force -Recurse -Path "$Env:RUNNER_TEMP\${_dir_name}"
Write-Host "::endgroup::"
