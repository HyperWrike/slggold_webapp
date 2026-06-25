$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# Define installation target directory (placing it next to the app folder in P-4)
$workDir = "C:\HYPERWRIKE\P-4"
$downloadDir = Join-Path $workDir ".flutter_download"
$zipFile = Join-Path $downloadDir "flutter.zip"
$flutterDest = Join-Path $workDir "flutter"
$binPath = Join-Path $flutterDest "bin"

Write-Output "--- Setting up Flutter SDK ---"

# 1. Create temporary download folder
if (-not (Test-Path $downloadDir)) {
    Write-Output "Creating download cache directory..."
    New-Item -ItemType Directory -Path $downloadDir | Out-Null
}

# 2. Download stable Flutter SDK if not already downloaded
$url = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.44.3-stable.zip"
if (-not (Test-Path $zipFile)) {
    Write-Output "Downloading Flutter SDK (~1GB) from storage.googleapis.com..."
    Write-Output "This might take a few minutes depending on your internet connection."
    Invoke-WebRequest -Uri $url -OutFile $zipFile
    Write-Output "Download complete!"
} else {
    Write-Output "Found existing downloaded Flutter zip."
}

# 3. Unzip Flutter SDK
if (-not (Test-Path $flutterDest)) {
    Write-Output "Extracting Flutter SDK to $workDir..."
    Write-Output "Extracting... (this will take 1-3 minutes)"
    Expand-Archive -Path $zipFile -DestinationPath $workDir
    Write-Output "Extraction complete!"
} else {
    Write-Output "Flutter SDK is already extracted at $flutterDest."
}

# 4. Add to Environment Path permanently for the User
Write-Output "Adding Flutter to User PATH environment variable..."
$currentUserPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
if ($currentUserPath -notlike "*$binPath*") {
    $newPath = $currentUserPath + ";" + $binPath
    # Clean up double semicolons if any
    $newPath = $newPath -replace ";+", ";"
    [System.Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Output "Flutter added to User PATH environment variable successfully."
} else {
    Write-Output "Flutter is already in your PATH."
}

# Add to the current session's path as well
$env:Path += ";$binPath"

# 5. Run Flutter doctor to initialize and verify
Write-Output "Initializing Flutter and running doctor check..."
& "$binPath\flutter.bat" doctor -v

Write-Output "--- Flutter Setup Complete! ---"
