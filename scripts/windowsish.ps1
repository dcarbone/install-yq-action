$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

Write-Host "::group::Prep"

# validate input and prepare some vars

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

$_base_url = "https://github.com/mikefarah/yq/releases/download"

$_root_name = "yq_windows_${_arch}"
$_bin_name = "${_root_name}.exe"

Write-Host "Creating temporary directory $Env:RUNNER_TEMP\${_root_name}\"
New-Item "$Env:RUNNER_TEMP\${_root_name}\" -ItemType Directory -Force

if ($Env:DL_COMPRESSED -eq "true")
{
    $_dl_name = "${_root_name}.zip"
    $_dl_path = "$Env:RUNNER_TEMP\${_dl_name}"
}
else
{
    $_dl_name = "${_bin_name}"
    $_dl_path = "$Env:RUNNER_TEMP\${_root_name}\${_dl_name}"
    Write-Host "Creating temporary directory $Env:RUNNER_TEMP\${_root_name}\"
    New-Item "$Env:RUNNER_TEMP\${_root_name}\" -ItemType Directory -Force
}

$_version = "$Env:YQ_VERSION"

# default to _something_...
if ($_version -eq "")
{
    $_version = "v4.44.3"
}

$_dl_url = "${_base_url}/${_version}/${_dl_name}"

Write-Host "::endgroup::"

# download artifact

Write-Host "::group::Downloading yq ${_version}"

Write-Host "Src: ${_dl_url}"
Write-Host "Dst: ${_dl_path}"

Invoke-WebRequest -Uri "${_dl_url}" -OutFile "${_dl_path}"

Write-Host "::endgroup::"

# expand archive, if necessary

if ($Env:DL_COMPRESSED -eq "true")
{
    Write-Host "::group::Expanding archive"

    Expand-Archive -LiteralPath "${_dl_path}" -DestinationPath "$Env:RUNNER_TEMP\${_root_name}\"

    Write-Host "Removing ${_dl_path}"
    Remove-Item -Force -Path "${_dl_path}"

    Write-Host "::endgroup::"
}

# install into tool cache

Write-Host "::group::Copying to tool cache"

Write-Host "Creating tool cache directory $Env:RUNNER_TOOL_CACHE\yq\"
New-Item "$Env:RUNNER_TOOL_CACHE\yq\" -ItemType Directory -Force

Write-Host "Installing into tool cache:"
Write-Host "Src: $Env:RUNNER_TEMP\${_root_name}\${_bin_name}"
Write-Host "Dst: $Env:RUNNER_TOOL_CACHE\yq\yq.exe"
Move-Item -Force -LiteralPath "$Env:RUNNER_TEMP\${_root_name}\${_bin_name}" -Destination "$Env:RUNNER_TOOL_CACHE\yq\yq.exe"

Write-Host "Removing $Env:RUNNER_TEMP\${_root_name}"
Remove-Item -Force -Recurse -Path "$Env:RUNNER_TEMP\${_root_name}"

Write-Host "Adding $Env:RUNNER_TOOL_CACHE\yq\ to path..."
Add-Content "$Env:GITHUB_PATH" "$Env:RUNNER_TOOL_CACHE\yq\"

Write-Host "::endgroup::"
