$libPath = "c:\Users\itzme\OneDrive\Desktop\high\lib"

# Fix files in presentation/screens/main/*/ - need ../../../../core instead of ../../core
$mainScreenDirs = @(
    "$libPath\presentation\screens\main\portfolio",
    "$libPath\presentation\screens\main\transactions",
    "$libPath\presentation\screens\main\schemes",
    "$libPath\presentation\screens\main\profile",
    "$libPath\presentation\screens\main\home"
)

foreach ($dir in $mainScreenDirs) {
    if (Test-Path $dir) {
        Get-ChildItem -Path $dir -Filter "*.dart" | ForEach-Object {
            $content = Get-Content $_.FullName -Raw
            $newContent = $content -replace "import '../../core/constants/", "import 'package:slg_golds/core/constants/"
            $newContent = $newContent -replace "import '../../../core/constants/", "import 'package:slg_golds/core/constants/"
            $newContent = $newContent -replace "import '../../../../core/constants/", "import 'package:slg_golds/core/constants/"
            $newContent = $newContent -replace "import '../../../widgets/", "import 'package:slg_golds/presentation/widgets/"
            if ($content -ne $newContent) {
                Set-Content -Path $_.FullName -Value $newContent -NoNewline
                Write-Output "Fixed: $($_.Name)"
            }
        }
    }
}

# Fix files in presentation/screens/admin/ - need ../../../core instead of ../../core
$adminDir = "$libPath\presentation\screens\admin"
if (Test-Path $adminDir) {
    Get-ChildItem -Path $adminDir -Filter "*.dart" | ForEach-Object {
        $content = Get-Content $_.FullName -Raw
        $newContent = $content -replace "import '../../core/constants/", "import 'package:slg_golds/core/constants/"
        $newContent = $newContent -replace "import '../../../core/constants/", "import 'package:slg_golds/core/constants/"
        $newContent = $newContent -replace "import '../../widgets/", "import 'package:slg_golds/presentation/widgets/"
        $newContent = $newContent -replace "import '../../../widgets/", "import 'package:slg_golds/presentation/widgets/"
        if ($content -ne $newContent) {
            Set-Content -Path $_.FullName -Value $newContent -NoNewline
            Write-Output "Fixed: $($_.Name)"
        }
    }
}

# Fix files in presentation/screens/onboarding/registration/ - need ../../../../core instead of ../../../core
$regDir = "$libPath\presentation\screens\onboarding\registration"
if (Test-Path $regDir) {
    Get-ChildItem -Path $regDir -Filter "*.dart" | ForEach-Object {
        $content = Get-Content $_.FullName -Raw
        $newContent = $content -replace "import '../../../core/constants/", "import 'package:slg_golds/core/constants/"
        $newContent = $newContent -replace "import '../../../../core/constants/", "import 'package:slg_golds/core/constants/"
        $newContent = $newContent -replace "import '../../../widgets/", "import 'package:slg_golds/presentation/widgets/"
        if ($content -ne $newContent) {
            Set-Content -Path $_.FullName -Value $newContent -NoNewline
            Write-Output "Fixed: $($_.Name)"
        }
    }
}

# Fix files in presentation/screens/onboarding/ (not registration subdir)
$onboardDir = "$libPath\presentation\screens\onboarding"
if (Test-Path $onboardDir) {
    Get-ChildItem -Path $onboardDir -Filter "*.dart" -File | ForEach-Object {
        $content = Get-Content $_.FullName -Raw
        $newContent = $content -replace "import '../../../core/constants/", "import 'package:slg_golds/core/constants/"
        $newContent = $newContent -replace "import '../../core/constants/", "import 'package:slg_golds/core/constants/"
        if ($content -ne $newContent) {
            Set-Content -Path $_.FullName -Value $newContent -NoNewline
            Write-Output "Fixed: $($_.Name)"
        }
    }
}

# Fix files in presentation/screens/auth/
$authDir = "$libPath\presentation\screens\auth"
if (Test-Path $authDir) {
    Get-ChildItem -Path $authDir -Filter "*.dart" | ForEach-Object {
        $content = Get-Content $_.FullName -Raw
        $newContent = $content -replace "import '../../../core/constants/", "import 'package:slg_golds/core/constants/"
        $newContent = $newContent -replace "import '../../widgets/", "import 'package:slg_golds/presentation/widgets/"
        if ($content -ne $newContent) {
            Set-Content -Path $_.FullName -Value $newContent -NoNewline
            Write-Output "Fixed: $($_.Name)"
        }
    }
}

Write-Output "Done fixing imports!"
