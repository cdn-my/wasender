# WA SENDER ADMIN SHORTCUT INSTALLER WITH REPLACE
# Version: 2.0
# Description: Create admin shortcut for WA Sender dengan replace existing

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "    WA SENDER ADMIN SHORTCUT INSTALLER" -ForegroundColor Yellow
Write-Host "           WITH REPLACE FUNCTION" -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Cyan

function Test-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Remove-OldShortcuts {
    $DesktopPath = [Environment]::GetFolderPath("Desktop")
    $ShortcutPatterns = @(
        "WA Sender*.lnk",
        "WASender*.lnk", 
        "WhatsApp Sender*.lnk",
        "WaSender*.lnk"
    )
    
    $removedCount = 0
    $removedNames = @()
    
    foreach ($pattern in $ShortcutPatterns) {
        $oldShortcuts = Get-ChildItem -Path $DesktopPath -Filter $pattern -ErrorAction SilentlyContinue
        
        foreach ($shortcut in $oldShortcuts) {
            try {
                $shortcutName = $shortcut.Name
                Remove-Item -Path $shortcut.FullName -Force -ErrorAction Stop
                Write-Host "🗑️  Shortcut lama dipadam: $shortcutName" -ForegroundColor Magenta
                $removedCount++
                $removedNames += $shortcutName
            }
            catch {
                Write-Host "⚠️  Gagal padam shortcut: $($shortcut.Name) - $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }
    }
    
    return @{
        Count = $removedCount
        Names = $removedNames
    }
}

function Test-WASenderExists {
    $possiblePaths = @(
        "C:\Program Files (x86)\TrendingApps\WaSenderSetUp\WASender.exe",
        "C:\Program Files\TrendingApps\WaSenderSetUp\WASender.exe",
        "$env:USERPROFILE\AppData\Local\TrendingApps\WaSenderSetUp\WASender.exe",
        "$env:PROGRAMFILES\TrendingApps\WaSenderSetUp\WASender.exe",
        "$env:LOCALAPPDATA\TrendingApps\WaSenderSetUp\WASender.exe"
    )
    
    foreach ($path in $possiblePaths) {
        if (Test-Path $path) {
            Write-Host "✅ WA Sender ditemukan di: $path" -ForegroundColor Green
            return $path
        }
    }
    
    # Additional search in Program Files directories
    $programFilesDirs = @(
        ${env:ProgramFiles(x86)},
        $env:ProgramFiles
    )
    
    foreach $dir in $programFilesDirs {
        if (Test-Path $dir) {
            $found = Get-ChildItem -Path $dir -Recurse -Filter "WASender.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($found) {
                Write-Host "✅ WA Sender ditemukan melalui search: $($found.FullName)" -ForegroundColor Green
                return $found.FullName
            }
        }
    }
    
    return $null
}

function Create-WASenderShortcut {
    param(
        [string]$WASenderPath
    )
    
    $ShortcutName = "WA Sender (Admin)"
    $DesktopPath = [Environment]::GetFolderPath("Desktop")
    $ShortcutPath = "$DesktopPath\$ShortcutName.lnk"
    
    try {
        # Create shortcut object
        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
        
        # Set shortcut properties
        $Shortcut.TargetPath = "powershell.exe"
        $Shortcut.Arguments = "-WindowStyle Hidden -Command `"Start-Process '$WASenderPath' -Verb RunAs`""
        $Shortcut.WorkingDirectory = (Get-Item $WASenderPath).DirectoryName
        $Shortcut.IconLocation = $WASenderPath
        $Shortcut.Description = "WA Sender - Run as Administrator"
        
        # Save shortcut
        $Shortcut.Save()
        
        Write-Host "✅ Shortcut baru berhasil dibuat!" -ForegroundColor Green
        Write-Host "📁 Lokasi: $ShortcutPath" -ForegroundColor Cyan
        
        return $true
    }
    catch {
        Write-Host "❌ Error creating shortcut: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Show-InstallationSummary {
    param(
        [int]$RemovedCount,
        [array]$RemovedNames,
        [bool]$ShortcutCreated
    )
    
    Write-Host "`n" + "="*50 -ForegroundColor Cyan
    Write-Host "           📊 SUMMARY INSTALLASI" -ForegroundColor Yellow
    Write-Host "="*50 -ForegroundColor Cyan
    
    Write-Host "`n🗑️  SHORTCUT LAMA DIPADAM:" -ForegroundColor White
    if ($RemovedCount -gt 0) {
        Write-Host "   Jumlah: $RemovedCount shortcut" -ForegroundColor Green
        foreach ($name in $RemovedNames) {
            Write-Host "   • $name" -ForegroundColor Gray
        }
    } else {
        Write-Host "   Tiada shortcut lama ditemukan" -ForegroundColor Gray
    }
    
    Write-Host "`n🆕 SHORTCUT BARU:" -ForegroundColor White
    if ($ShortcutCreated) {
        Write-Host "   ✅ 'WA Sender (Admin)' berhasil dibuat" -ForegroundColor Green
        Write-Host "   📍 Lokasi: Desktop" -ForegroundColor Gray
    } else {
        Write-Host "   ❌ Gagal membuat shortcut baru" -ForegroundColor Red
    }
    
    Write-Host "`n🎯 CARA PENGGUNAAN:" -ForegroundColor Yellow
    Write-Host "   1. Double-click 'WA Sender (Admin)' di desktop" -ForegroundColor White
    Write-Host "   2. Klik 'Yes' pada UAC prompt" -ForegroundColor White
    Write-Host "   3. WA Sender akan run sebagai administrator" -ForegroundColor White
    Write-Host "`n" + "="*50 -ForegroundColor Cyan
}

# Main execution
Clear-Host
Write-Host "Memulai instalasi WA Sender Admin Shortcut..." -ForegroundColor Yellow
Write-Host "Dengan fungsi replace shortcut lama" -ForegroundColor Cyan

# Step 1: Cari WA Sender
Write-Host "`n🔍 Mencari WA Sender di sistem..." -ForegroundColor Yellow
$wasenderPath = Test-WASenderExists

if (-not $wasenderPath) {
    Write-Host "❌ WA Sender tidak ditemukan di sistem." -ForegroundColor Red
    Write-Host "   Pastikan WA Sender sudah diinstall terlebih dahulu." -ForegroundColor Yellow
    Write-Host "`nPress any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# Step 2: Padam shortcut lama
Write-Host "`n🗑️  Mencari dan memadam shortcut lama..." -ForegroundColor Yellow
$removalResult = Remove-OldShortcuts

# Step 3: Buat shortcut baru
Write-Host "`n🆕 Membuat shortcut baru..." -ForegroundColor Yellow
$shortcutCreated = Create-WASenderShortcut -WASenderPath $wasenderPath

# Step 4: Show summary
Show-InstallationSummary -RemovedCount $removalResult.Count -RemovedNames $removalResult.Names -ShortcutCreated $shortcutCreated

# Final message
if ($shortcutCreated) {
    Write-Host "🎉 INSTALLASI BERJAYA!" -ForegroundColor Green
    if ($removalResult.Count -gt 0) {
        Write-Host "Shortcut lama telah digantikan dengan yang baru." -ForegroundColor White
    }
} else {
    Write-Host "❌ INSTALLASI GAGAL!" -ForegroundColor Red
    Write-Host "Silakan cuba run PowerShell sebagai Administrator." -ForegroundColor Yellow
}

# Pause sebelum exit
Write-Host "`nPress any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
