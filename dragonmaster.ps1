#Requires -RunAsAdministrator
$host.UI.RawUI.WindowTitle = "WinDemo Lag Fix"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "SilentlyContinue"

function Show-Menu {
    Clear-Host
    $os = (Get-WmiObject Win32_OperatingSystem).Caption
    Write-Host ""
    Write-Host "          File_Fix_Lag.ps1 v1 By WinDemo Lag Fix ( Beta v0.1 )"
    Write-Host "  ________________________________________________________________"
    Write-Host "  |                                                              |"
    Write-Host "  |  [1]  Quet Don Rac              [2]  Toi Uu Registry        |"
    Write-Host "  |  [3]  Tang Toc WIFI             [4]  Toi Uu Services        |"
    Write-Host "  |  [5]  Tang Toc Internet         [6]  Set Ram Ao             |"
    Write-Host "  |  [7]  Toi Uu RAM                [8]  Tat Windows Defender   |"
    Write-Host "  |  [9]  Tat Hieu Ung Windows      [10] Tat Windows Update     |"
    Write-Host "  |  [11] Kich Hoat Ultimate Perf   [12] Tang Toc GPU           |"
    Write-Host "  |  [13] Toi Uu FPS Game           [14] Khoi Phuc FPS Game     |"
    Write-Host "  |  [15] Tat GameBar               [16] Bat GameBar            |"
    Write-Host "  |  [17] Tat May In                [18] Bat May In             |"
    Write-Host "  |  [19] Toi Uu CPU                [20] Reset Explorer         |"
    Write-Host "  |  [21] Toi Uu Gpedit             [22] Tang Toc Laptop        |"
    Write-Host "  |  [23] Khoi Phuc Laptop          [24] Xoa Edge               |"
    Write-Host "  |  [25] Debloat Windows           [26] Active Windows         |"
    Write-Host "  |  [27] Tao System Restore        [28] Tat WMI                |"
    Write-Host "  |  [29] Bat WMI                   [30] Lien He Tac Gia        |"
    Write-Host "  |  [R]  Menu Khoi Phuc            [X]  Cai DirectX            |"
    Write-Host "  |  [T]  Thoat                                                 |"
    Write-Host "  |______________________________________________________________|"
    Write-Host ""
}

function K1-CleanJunk {
    Clear-Host
    Write-Host "====== Don Dep Rac ======"
    $paths = @(
        "$env:WINDIR\Temp",
        "$env:WINDIR\Prefetch",
        "$env:TEMP",
        "$env:WINDIR\ff*.tmp",
        "$env:WINDIR\history",
        "$env:WINDIR\cookies",
        "$env:WINDIR\recent",
        "$env:WINDIR\spool\printers"
    )
    foreach ($p in $paths) {
        if (Test-Path $p) {
            Remove-Item -Path "$p\*" -Recurse -Force
        }
    }
    Remove-Item -Path "$env:WINDIR\Temp" -Recurse -Force
    New-Item -Path "$env:WINDIR\Temp" -ItemType Directory -Force | Out-Null
    Remove-Item -Path "$env:TEMP" -Recurse -Force
    New-Item -Path "$env:TEMP" -ItemType Directory -Force | Out-Null
    Remove-Item -Path "$env:WINDIR\Prefetch" -Recurse -Force
    New-Item -Path "$env:WINDIR\Prefetch" -ItemType Directory -Force | Out-Null
    Get-WinEvent -ListLog * | ForEach-Object {
        [System.Diagnostics.Eventing.Reader.EventLogSession]::GlobalSession.ClearLog($_.LogName)
    }
    Write-Host "Don dep hoan tat!"
    Pause
}

function K2-OptimizeRegistry {
    Clear-Host
    Write-Host "====== Toi Uu Registry ======"
    $desktopPath = "HKCU:\Control Panel\Desktop"
    $explorerPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
    $controlPath  = "HKLM:\SYSTEM\CurrentControlSet\Control"
    $systemPath   = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    $srPath       = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore"
    $srPolPath    = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\SystemRestore"

    Set-ItemProperty -Path $desktopPath -Name "AutoEndTasks"            -Value "1"
    Set-ItemProperty -Path $desktopPath -Name "HungAppTimeout"           -Value "1000"
    Set-ItemProperty -Path $desktopPath -Name "MenuShowDelay"            -Value "8"
    Set-ItemProperty -Path $desktopPath -Name "WaitToKillAppTimeout"     -Value "2000"
    Set-ItemProperty -Path $desktopPath -Name "LowLevelHooksTimeout"     -Value "1000"

    foreach ($name in @("NoLowDiskSpaceChecks","LinkResolveIgnoreLinkInfo","NoResolveSearch","NoResolveTrack","NoInternetOpenWith")) {
        Set-ItemProperty -Path $explorerPath -Name $name -Value 1 -Type DWord
    }

    Set-ItemProperty -Path $controlPath -Name "WaitToKillServiceTimeout" -Value "2000"
    Set-ItemProperty -Path $systemPath  -Name "EnableLUA"                -Value 0 -Type DWord
    Set-ItemProperty -Path $srPath      -Name "DisableSR"                -Value 1 -Type DWord
    Set-ItemProperty -Path $srPolPath   -Name "DisableSR"                -Value 1 -Type DWord

    Stop-Service    -Name "srservice" -Force
    Set-Service     -Name "srservice" -StartupType Disabled

    Write-Host "Registry da duoc toi uu!"
    Pause
}

function K3-OptimizeWifi {
    Clear-Host
    Write-Host "====== Tang Toc WIFI ======"
    ipconfig /flushdns
    netsh int tcp set global autotuninglevel=Disable
    netsh int tcp set global chimney=enabled
    netsh int tcp set global dca=enabled
    netsh int tcp set global netdma=disabled
    netsh int tcp set global congestionprovider=ctcp
    netsh int tcp set global ecncapability=disabled
    netsh int tcp set heuristics disabled
    netsh int tcp set global rss=enabled
    netsh int tcp set global fastopen=enabled
    netsh int tcp set global nonsackrttresiliency=disabled
    netsh int tcp set global rsc=enabled
    Write-Host "Tang toc WIFI hoan tat!"
    Pause
}

function K4-OptimizeServices {
    Clear-Host
    Write-Host "====== Toi Uu Services ======"
    $services = @(
        "SysMain","wisvc","icssvc","Fax","SessionEnv","TermService",
        "bthserv","TabletInputService","DiagTrack","DPS","DoSvc",
        "WpnService","TrkWks","diagnosticshub.standardcollector.service",
        "RemoteRegistry","WSearch"
    )
    foreach ($svc in $services) {
        Stop-Service -Name $svc -Force
        Set-Service  -Name $svc -StartupType Disabled
    }
    Write-Host "Services da duoc toi uu!"
    Pause
}

function K5-OptimizeInternet {
    Clear-Host
    Write-Host "====== Tang Toc Internet ======"
    ipconfig /flushdns
    ipconfig /release
    ipconfig /renew
    Write-Host "Hoan tat! Vui long khoi dong lai may."
    Pause
}

function K6-SetVirtualRam {
    Clear-Host
    Write-Host "====== Cai Ram Ao ======"
    $cs = Get-WmiObject -Class Win32_ComputerSystem
    $cs.AutomaticManagedPagefile = $false
    $cs.Put() | Out-Null
    $pf = Get-WmiObject -Class Win32_PageFileSetting
    if ($pf) { $pf.Delete() }
    Set-WmiInstance -Class Win32_PageFileSetting -Arguments @{
        Name        = "C:\pagefile.sys"
        InitialSize = 4096
        MaximumSize = 4096
    } | Out-Null
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" `
        -Name "PagingFiles" -Value "C:\pagefile.sys 4096 4096" -Type MultiString
    Write-Host "Ram ao da duoc cai dat!"
    Pause
}

function K7-OptimizeRAM {
    Clear-Host
    Write-Host "====== Toi Uu RAM ======"
    $l2 = (Get-WmiObject Win32_Processor).L2CacheSize
    $l3 = (Get-WmiObject Win32_Processor).L3CacheSize
    $mmPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
    $fsPath = "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem"
    $ram    = (Get-WmiObject Win32_OperatingSystem).TotalVisibleMemorySize + 1024000

    Set-ItemProperty -Path $mmPath -Name "SecondLevelDataCache"    -Value $l2   -Type DWord
    Set-ItemProperty -Path $mmPath -Name "ThirdLevelDataCache"     -Value $l3   -Type DWord
    Set-ItemProperty -Path $mmPath -Name "DisablePagingExecutive"  -Value 1     -Type DWord
    Set-ItemProperty -Path $mmPath -Name "LargeSystemCache"        -Value 0     -Type DWord
    Set-ItemProperty -Path $mmPath -Name "IoPageLockLimit"         -Value 16710656 -Type DWord
    Set-ItemProperty -Path $mmPath -Name "SystemPages"             -Value 4294967295 -Type DWord

    $pfPath = "$mmPath\PrefetchParameters"
    Set-ItemProperty -Path $pfPath -Name "EnableBootTrace"   -Value 0 -Type DWord
    Set-ItemProperty -Path $pfPath -Name "EnablePrefetcher"  -Value 0 -Type DWord
    Set-ItemProperty -Path $pfPath -Name "EnableSuperfetch"  -Value 0 -Type DWord

    foreach ($key in @("NtfsMftZoneReservation","NtfsDisable8dot3NameCreation","NtfsDisableEncryption","RefsDisableLastAccessUpdate","DontVerifyRandomDrivers")) {
        Set-ItemProperty -Path $fsPath -Name $key -Value 1 -Type DWord
    }

    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "SvcHostSplitThresholdInKB" -Value $ram -Type DWord
    Write-Host "RAM da duoc toi uu!"
    Pause
}

function K8-DisableDefender {
    Clear-Host
    Write-Host "====== Tat Windows Defender ======"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -Value 1 -Type DWord
    Write-Host "Windows Defender da tat!"
    Pause
}

function K9-DisableVisualEffects {
    Clear-Host
    Write-Host "====== Tat Hieu Ung Windows ======"
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2 -Type DWord
    Stop-Service  -Name "Themes" -Force
    Set-Service   -Name "Themes" -StartupType Disabled
    Write-Host "Hieu ung da tat!"
    Pause
}

function K10-DisableWindowsUpdate {
    Clear-Host
    Write-Host "====== Tat Windows Update ======"
    Stop-Service -Name "wuauserv" -Force
    Stop-Service -Name "UsoSvc"   -Force
    $wuPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
    $auPath = "$wuPath\AU"
    Set-ItemProperty -Path $wuPath -Name "DoNotConnectToWindowsUpdateInternetLocations" -Value 1 -Type DWord
    Set-ItemProperty -Path $wuPath -Name "SetDisableUXWUAccess"                         -Value 1 -Type DWord
    Set-ItemProperty -Path $wuPath -Name "ExcludeWUDriversInQualityUpdate"              -Value 1 -Type DWord
    Set-ItemProperty -Path $auPath -Name "NoAutoUpdate"                                 -Value 1 -Type DWord
    gpupdate /force
    if (Test-Path "C:\Windows\SoftwareDistribution") {
        Remove-Item -Path "C:\Windows\SoftwareDistribution" -Recurse -Force
    }
    New-Item -Path "C:\Windows\SoftwareDistribution" -ItemType Directory -Force | Out-Null
    Start-Service -Name "wuauserv"
    Start-Service -Name "UsoSvc"
    Write-Host "Windows Update da tat!"
    Pause
}

function K11-UltimatePerformance {
    Clear-Host
    Write-Host "====== Kich Hoat Ultimate Performance ======"
    powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61
    powercfg /setactive e9a42b02-d5df-448d-aa00-03f14749eb61
    powercfg -h off
    Write-Host "Ultimate Performance da kich hoat!"
    Pause
}

function K12-OptimizeGPU {
    Clear-Host
    Write-Host "====== Tang Toc GPU ======"
    bcdedit /set IncreaseUserVa 4096
    bcdedit /deletevalue useplatformclock
    Write-Host "GPU da duoc toi uu! Vui long khoi dong lai may."
    Pause
}

function K13-OptimizeFPS {
    Clear-Host
    Write-Host "====== Toi Uu FPS Game ======"
    $gamePath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
    Set-ItemProperty -Path $gamePath -Name "Affinity"          -Value 0      -Type DWord
    Set-ItemProperty -Path $gamePath -Name "Background Only"   -Value "False"
    Set-ItemProperty -Path $gamePath -Name "Priority"          -Value 6      -Type DWord
    Set-ItemProperty -Path $gamePath -Name "Scheduling Category" -Value "High"
    Set-ItemProperty -Path $gamePath -Name "SFIO Priority"     -Value "High"
    Write-Host "FPS da duoc toi uu!"
    Pause
}

function K14-RestoreFPS {
    Clear-Host
    Write-Host "====== Khoi Phuc FPS Game ======"
    $gamePath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
    Set-ItemProperty -Path $gamePath -Name "Priority"            -Value 2        -Type DWord
    Set-ItemProperty -Path $gamePath -Name "Scheduling Category" -Value "Medium"
    Set-ItemProperty -Path $gamePath -Name "SFIO Priority"       -Value "Normal"
    Write-Host "FPS da khoi phuc ve mac dinh!"
    Pause
}

function K15-DisableGameBar {
    Clear-Host
    Write-Host "====== Tat GameBar ======"
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled"       -Value 0 -Type DWord
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehaviorMode" -Value 2 -Type DWord
    Write-Host "GameBar da tat!"
    Pause
}

function K16-EnableGameBar {
    Clear-Host
    Write-Host "====== Bat GameBar ======"
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled"         -Value 1 -Type DWord
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehaviorMode" -Value 0 -Type DWord
    Write-Host "GameBar da bat!"
    Pause
}

function K17-DisablePrinter {
    Clear-Host
    Write-Host "====== Tat May In ======"
    foreach ($svc in @("Spooler","PrintNotify","PrintWorkflowUserSvc")) {
        Stop-Service -Name $svc -Force
        Set-Service  -Name $svc -StartupType Disabled
    }
    Write-Host "May in da tat!"
    Pause
}

function K18-EnablePrinter {
    Clear-Host
    Write-Host "====== Bat May In ======"
    foreach ($svc in @("Spooler","PrintNotify","PrintWorkflowUserSvc")) {
        Set-Service  -Name $svc -StartupType Automatic
        Start-Service -Name $svc
    }
    Write-Host "May in da bat!"
    Pause
}

function K19-OptimizeCPU {
    Clear-Host
    Write-Host "====== Toi Uu CPU / Telemetry ======"
    $svcs = @("DiagTrack","diagnosticshub.standardcollector.service","dmwappushservice","WMPNetworkSvc","WSearch")
    foreach ($s in $svcs) {
        Stop-Service -Name $s -Force
        Set-Service  -Name $s -StartupType Disabled
    }
    $tasks = @(
        "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
        "Microsoft\Windows\Application Experience\ProgramDataUpdater",
        "Microsoft\Windows\Application Experience\StartupAppTask",
        "Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
        "Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask",
        "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
        "Microsoft\Windows\Customer Experience Improvement Program\Uploader",
        "Microsoft\Windows\Shell\FamilySafetyUpload"
    )
    foreach ($t in $tasks) { Disable-ScheduledTask -TaskPath "\$($t | Split-Path -Parent)\" -TaskName ($t | Split-Path -Leaf) }

    $telPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
    Set-ItemProperty -Path $telPath -Name "AllowTelemetry" -Value 0 -Type DWord
    Write-Host "CPU va Telemetry da duoc toi uu!"
    Pause
}

function K20-ResetExplorer {
    Clear-Host
    Write-Host "====== Reset Windows Explorer ======"
    Stop-Process -Name "explorer" -Force
    Start-Process "explorer.exe"
    Write-Host "Explorer da duoc reset!"
    Pause
}

function K21-OptimizeGpedit {
    Clear-Host
    Write-Host "====== Toi Uu Gpedit / BCD ======"
    bcdedit /set useplatformclock false
    bcdedit /set disabledynamictick yes
    bcdedit /set useplatformtick yes
    bcdedit /timeout 0
    bcdedit /set nx optout
    bcdedit /set bootux disabled
    bcdedit /set bootmenupolicy standard
    bcdedit /set hypervisorlaunchtype off
    bcdedit /set tpmbootentropy ForceDisable
    bcdedit /set quietboot yes
    bcdedit /set linearaddress57 OptOut
    bcdedit /set increaseuserva 268435328
    bcdedit /set firstmegabytepolicy UseAll
    bcdedit /set avoidlowmemory 0x8000000
    bcdedit /set nolowmem Yes
    bcdedit /set allowedinmemorysettings 0x0
    bcdedit /set isolatedcontext No
    bcdedit /set vsmlaunchtype Off
    bcdedit /set vm No
    bcdedit /set configaccesspolicy Default
    bcdedit /set usephysicaldestination No
    bcdedit /set usefirmwarepcisettings No
    Write-Host "Gpedit va BCD da duoc toi uu!"
    Pause
}

function K22-OptimizeLaptop {
    Clear-Host
    Write-Host "====== Tang Toc Laptop ======"
    $regs = @{
        "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" = @{ Disabled = 1 }
        "HKLM:\Software\Policies\Microsoft\Windows\CloudContent" = @{
            DisableSoftLanding = 1; DisableWindowsSpotlightFeatures = 1; DisableWindowsConsumerFeatures = 1
        }
        "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" = @{ DisableAntiSpyware = 1 }
        "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" = @{
            SpyNetReporting = 0; SubmitSamplesConsent = 2; DontReportInfectionInformation = 1
        }
    }
    foreach ($path in $regs.Keys) {
        if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
        foreach ($name in $regs[$path].Keys) {
            Set-ItemProperty -Path $path -Name $name -Value $regs[$path][$name] -Type DWord
        }
    }
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "IRQ8Priority" -Value 1 -Type DWord
    ipconfig /flushdns
    powercfg.exe /hibernate off
    Write-Host "Laptop da duoc tang toc!"
    Pause
}

function K23-RestoreLaptop {
    Clear-Host
    Write-Host "====== Khoi Phuc Laptop ======"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" -Name "Disabled" -Value 0 -Type DWord
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -Value 0 -Type DWord
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "IRQ8Priority" -Value 0 -Type DWord
    bcdedit /set useplatformclock yes
    bcdedit /set disabledynamictick no
    Write-Host "Laptop da duoc khoi phuc!"
    Pause
}

function K26-ActiveWindows {
    Clear-Host
    $choice = Read-Host "Ban muon kich hoat Windows 10 hay 11? (10/11)"
    if ($choice -eq "10") {
        cscript slmgr.vbs /ipk "W269N-WFGWX-YVC9B-4J6C9-T83GX"
        cscript slmgr.vbs /skms kms8.msguides.com
        cscript slmgr.vbs /ato
    } elseif ($choice -eq "11") {
        cscript slmgr.vbs /ipk "W269N-WFGWX-YVC9B-4J6C9-T83GX"
        cscript slmgr.vbs /skms kms.srv.crsoo.com
        cscript slmgr.vbs /ato
    }
    Pause
}

function K27-SystemRestore {
    Clear-Host
    Write-Host "====== Tao Diem Khoi Phuc ======"
    Checkpoint-Computer -Description "WinDemo Lag Fix - Restore Point" -RestorePointType "MODIFY_SETTINGS"
    Write-Host "Diem khoi phuc da duoc tao!"
    Pause
}

function K28-DisableWMI {
    Clear-Host
    Write-Host "====== Tat WMI Reverse Performance ======"
    $wbem = "$env:WINDIR\system32\wbem"
    takeown /F $wbem /R /D Y
    Stop-Process -Name "WmiPrvSE" -Force
    Rename-Item -Path "$wbem\WmiPrvSE.exe" -NewName "WmiPrvSE0.exe" -Force
    Write-Host "WMI da tat!"
    Pause
}

function K29-EnableWMI {
    Clear-Host
    Write-Host "====== Bat WMI ======"
    $wbem = "$env:WINDIR\system32\wbem"
    takeown /F $wbem /R /D Y
    Rename-Item -Path "$wbem\WmiPrvSE0.exe" -NewName "WmiPrvSE.exe" -Force
    Write-Host "WMI da bat!"
    Pause
}

function K30-Contact {
    Clear-Host
    Start-Process "https://www.facebook.com/noobpie"
    Write-Host "Da mo Facebook cua tac gia!"
    Pause
}

function Show-RestoreMenu {
    while ($true) {
        Clear-Host
        Write-Host "====== Menu Khoi Phuc ======"
        Write-Host "[a] Khoi Phuc Services     [b] Bat Windows Defender"
        Write-Host "[c] Bat Windows Update     [d] Xoa Ram Ao"
        Write-Host "[e] Khoi Phuc GPU          [f] Khoi Phuc CPU"
        Write-Host "[g] Khoi Phuc Registry     [h] Khoi Phuc WIFI"
        Write-Host "[i] Khoi Phuc Gpedit       [j] Mo System Restore"
        Write-Host "[k] Tat Ultimate Perf      [m] Khoi Phuc Hieu Ung"
        Write-Host "[back] Quay lai menu chinh"
        $r = Read-Host "Chon chuc nang"
        switch ($r.ToLower()) {
            "a" {
                $svcs = @("MpsSvc","SysMain","ShellHWDetection","iphlpsvc","Fax","wmiApSrv","wcncsvc",
                          "vds","CscService","WinDefend","WSearch","BITS","WdNisSvc","AeLookupSvc",
                          "WPDBusEnum","LanmanServer","lmhosts","PcaSvc","WerSvc","wscsvc","wuauserv",
                          "DiagTrack","dmwappushservice","RemoteRegistry","TrkWks","WMPNetworkSvc")
                foreach ($s in $svcs) { Set-Service -Name $s -StartupType Automatic }
                Write-Host "Services da khoi phuc!"; Pause
            }
            "b" {
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -Value 0 -Type DWord
                Write-Host "Windows Defender da bat!"; Pause
            }
            "c" {
                Set-Service -Name "wuauserv" -StartupType Automatic
                Write-Host "Windows Update da bat!"; Pause
            }
            "d" {
                Set-WmiInstance -Class Win32_PageFileSetting -Arguments @{ Name="C:\pagefile.sys"; InitialSize=0; MaximumSize=0 } | Out-Null
                Write-Host "Ram ao da xoa! Khoi dong lai de co hieu luc."; Pause
            }
            "e" { bcdedit /set IncreaseUserVa 2048; Write-Host "GPU da khoi phuc!"; Pause }
            "f" {
                $svcs = @("DiagTrack","diagnosticshub.standardcollector.service","dmwappushservice","WMPNetworkSvc","WSearch")
                foreach ($s in $svcs) { Set-Service -Name $s -StartupType Automatic }
                Write-Host "CPU da khoi phuc!"; Pause
            }
            "g" {
                Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value "400"
                Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "WaitToKillServiceTimeout" -Value "5000"
                Write-Host "Registry da khoi phuc!"; Pause
            }
            "h" {
                netsh int tcp set global autotuninglevel=normal
                netsh int tcp set global rss=enabled
                Write-Host "WIFI da khoi phuc!"; Pause
            }
            "i" {
                bcdedit /set useplatformclock yes
                bcdedit /set disabledynamictick no
                bcdedit /set useplatformtick yes
                bcdedit /set nolowmem Default
                Write-Host "Gpedit da khoi phuc!"; Pause
            }
            "j" { Start-Process "rstrui.exe"; Pause }
            "k" {
                powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e
                Write-Host "Ultimate Performance da tat!"; Pause
            }
            "m" {
                Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 1 -Type DWord
                Set-Service -Name "Themes" -StartupType Automatic
                Start-Service -Name "Themes"
                Write-Host "Hieu ung da khoi phuc!"; Pause
            }
            "back" { return }
        }
    }
}

while ($true) {
    Show-Menu
    $choice = Read-Host "Chon chuc nang"
    switch ($choice.ToLower()) {
        "1"  { K1-CleanJunk }
        "2"  { K2-OptimizeRegistry }
        "3"  { K3-OptimizeWifi }
        "4"  { K4-OptimizeServices }
        "5"  { K5-OptimizeInternet }
        "6"  { K6-SetVirtualRam }
        "7"  { K7-OptimizeRAM }
        "8"  { K8-DisableDefender }
        "9"  { K9-DisableVisualEffects }
        "10" { K10-DisableWindowsUpdate }
        "11" { K11-UltimatePerformance }
        "12" { K12-OptimizeGPU }
        "13" { K13-OptimizeFPS }
        "14" { K14-RestoreFPS }
        "15" { K15-DisableGameBar }
        "16" { K16-EnableGameBar }
        "17" { K17-DisablePrinter }
        "18" { K18-EnablePrinter }
        "19" { K19-OptimizeCPU }
        "20" { K20-ResetExplorer }
        "21" { K21-OptimizeGpedit }
        "22" { K22-OptimizeLaptop }
        "23" { K23-RestoreLaptop }
        "26" { K26-ActiveWindows }
        "27" { K27-SystemRestore }
        "28" { K28-DisableWMI }
        "29" { K29-EnableWMI }
        "30" { K30-Contact }
        "r"  { Show-RestoreMenu }
        "x"  { Start-Process "https://www.microsoft.com/en-us/download/details.aspx?id=35" }
        "t"  { exit }
    }
}