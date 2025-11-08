# WASender Admin Shortcut Online Installer
# Created by: Your Name
# Description: Create admin shortcut for WA Sender with desktop icon

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "    WA SENDER ADMIN SHORTCUT INSTALLER" -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Cyan

function Test-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Create-WASenderShortcut {
    $WASenderPath = "C:\Program Files (x86)\TrendingApps\WaSenderSetUp\WASender.exe"
    $ShortcutName = "WA Sender (Admin)"
    $DesktopPath = [Environment]::GetFolderPath("Desktop")
    $ShortcutPath = "$DesktopPath\$ShortcutName.lnk"
    
    # Check if WA Sender exists
    if (-not (Test-Path $WASenderPath)) {
        Write-Host "❌ WA Sender tidak ditemukan di lokasi: $WASenderPath" -ForegroundColor Red
        Write-Host "📁 Mencari WA Sender di seluruh system..." -ForegroundColor Yellow
        
        # Try to find WASender.exe in other locations
        $possiblePaths = @(
            "C:\Program Files\TrendingApps\WaSenderSetUp\WASender.exe"
            "$env:USERPROFILE\AppData\Local\TrendingApps\WaSenderSetUp\WASender.exe"
            "$env:PROGRAMFILES\TrendingApps\WaSenderSetUp\WASender.exe"
        )
        
        foreach ($path in $possiblePaths) {
            if (Test-Path $path) {
                $WASenderPath = $path
                Write-Host "✅ WA Sender ditemukan di: $WASenderPath" -ForegroundColor Green
                break
            }
        }
        
        if (-not (Test-Path $WASenderPath)) {
            Write-Host "❌ WA Sender tidak ditemukan di sistem." -ForegroundColor Red
            return $false
        }
    }
    
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
        
        Write-Host "✅ Shortcut berhasil dibuat di Desktop!" -ForegroundColor Green
        Write-Host "📁 Lokasi: $ShortcutPath" -ForegroundColor Cyan
        Write-Host "🎯 Nama: $ShortcutName" -ForegroundColor Cyan
        
        return $true
    }
    catch {
        Write-Host "❌ Error creating shortcut: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Show-SuccessMessage {
    Write-Host "`n🎉 INSTALLASI BERHASIL!" -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "Shortcut 'WA Sender (Admin)' telah dibuat di desktop." -ForegroundColor White
    Write-Host "`n📝 Cara penggunaan:" -ForegroundColor Yellow
    Write-Host "1. Double-click shortcut 'WA Sender (Admin)' di desktop" -ForegroundColor White
    Write-Host "2. Klik 'Yes' ketika UAC prompt muncul" -ForegroundColor White
    Write-Host "3. WA Sender akan terbuka dengan hak akses administrator" -ForegroundColor White
    Write-Host "`n⚠️  Catatan: Setiap kali menjalankan, akan diminta konfirmasi UAC" -ForegroundColor Magenta
    Write-Host "==========================================" -ForegroundColor Cyan
}

# Main execution
Clear-Host
Write-Host "Memulai instalasi WA Sender Admin Shortcut..." -ForegroundColor Yellow

# Check if running as admin (optional, just for info)
if (Test-Admin) {
    Write-Host "ℹ️  Script berjalan sebagai Administrator" -ForegroundColor Blue
} else {
    Write-Host "ℹ️  Script tidak berjalan sebagai Administrator (tidak diperlukan)" -ForegroundColor Blue
}

# Create the shortcut
$success = Create-WASenderShortcut

if ($success) {
    Show-SuccessMessage
} else {
    Write-Host "`n❌ INSTALLASI GAGAL!" -ForegroundColor Red
    Write-Host "Silakan cek:" -ForegroundColor Yellow
    Write-Host "1. Apakah WA Sender sudah terinstall?" -ForegroundColor White
    Write-Host "2. Path program是否正确?" -ForegroundColor White
    Write-Host "3. Coba run PowerShell sebagai admin" -ForegroundColor White
}

# Pause untuk melihat hasil
Write-Host "`nPress any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")