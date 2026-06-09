$ErrorActionPreference = 'Stop'
# AWS-SpeedTest
# Copyright (C) 2026 AWS-SpeedTest contributors
# SPDX-License-Identifier: GPL-3.0-only

try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8; $OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}

function Is-Admin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Read-CsvLoose($path) {
    $rawLines = Get-Content -LiteralPath $path -Encoding UTF8 | Where-Object { $_.Trim() -ne '' }
    if ($rawLines.Count -lt 2) { return @() }

    $headers = $rawLines[0].Split(',') | ForEach-Object { $_.Trim().Trim('"') }
    $ipIndex = -1
    $delayIndex = -1

    for ($i = 0; $i -lt $headers.Count; $i++) {
        $h = $headers[$i]
        if ($ipIndex -lt 0 -and ($h -match '^(IP|IP地址|地址)$' -or $h -match 'IP')) { $ipIndex = $i }
        if ($delayIndex -lt 0 -and ($h -match '平均延迟|延迟|Ping|ping|Latency|latency')) { $delayIndex = $i }
    }

    if ($ipIndex -lt 0) { $ipIndex = 0 }
    if ($delayIndex -lt 0) { $delayIndex = 4 }

    $rows = New-Object System.Collections.Generic.List[object]

    foreach ($line in $rawLines | Select-Object -Skip 1) {
        $cols = $line.Split(',') | ForEach-Object { $_.Trim().Trim('"') }
        if ($cols.Count -le $ipIndex) { continue }

        $ip = $cols[$ipIndex].Trim()
        if ($ip -notmatch '^(\d{1,3}\.){3}\d{1,3}$') { continue }

        $delay = ''
        if ($cols.Count -gt $delayIndex) { $delay = $cols[$delayIndex].Trim() }
        $delay = ($delay -replace 'ms','').Trim()

        $rows.Add([pscustomobject]@{ IP = $ip; Delay = $delay }) | Out-Null
        if ($rows.Count -ge 9) { break }
    }

    return $rows.ToArray()
}

function Invoke-SpeedTest {
    param(
        [string]$ScriptDir
    )

    $cfstPath = Join-Path $ScriptDir 'cfst.exe'
    $ipPath = Join-Path $ScriptDir 'ip.txt'
    $resultPath = Join-Path $ScriptDir 'result.csv'

    if (-not (Test-Path -LiteralPath $cfstPath)) {
        Write-Host '错误：当前目录未找到 cfst.exe' -ForegroundColor Red
        Write-Host '请把本工具放到 cfst.exe 同目录下。'
        exit 1
    }

    if (-not (Test-Path -LiteralPath $ipPath)) {
        Write-Host '错误：当前目录未找到 ip.txt' -ForegroundColor Red
        Write-Host '请把 ip.txt 放到本工具同目录下。'
        exit 1
    }

    Write-Host ''
    Write-Host '即将开始测速：cfst.exe -f ip.txt -dd'
    Write-Host ''

    Push-Location $ScriptDir
    try {
        & .\cfst.exe -f ip.txt -dd
        if ($LASTEXITCODE -ne 0) {
            throw "测速程序退出码：$LASTEXITCODE"
        }
    }
    finally {
        Pop-Location
    }

    if (-not (Test-Path -LiteralPath $resultPath)) {
        Write-Host ''
        Write-Host '错误：测速完成后仍未找到 result.csv。' -ForegroundColor Red
        exit 1
    }

    Write-Host ''
    Write-Host '测速完成，已生成或更新 result.csv。' -ForegroundColor Green
}

function Read-WorkflowAction {
    Write-Host '检测到当前目录已有 result.csv。'
    Write-Host ''
    Write-Host '1. 直接更换 hosts'
    Write-Host '2. 重新测速后再更换 hosts'
    Write-Host '0. 退出'
    Write-Host ''

    while ($true) {
        $choice = Read-Host '请输入序号 0-2'
        switch ($choice) {
            '1' { return 'UseExisting' }
            '2' { return 'Retest' }
            '0' { return 'Exit' }
            default { Write-Host '输入无效，请重新输入。' -ForegroundColor Yellow }
        }
    }
}

function Select-ResultIP {
    param(
        [object[]]$Items
    )

    Write-Host '请选择要写入 hosts 的 IP：'
    Write-Host ''
    Write-Host ("0.`t自定义输入 IP")
    for ($i = 0; $i -lt $Items.Count; $i++) {
        $num = $i + 1
        $ip = $Items[$i].IP
        $delay = $Items[$i].Delay
        if ([string]::IsNullOrWhiteSpace($delay)) {
            Write-Host ("$num.`t$ip`t延迟`t未知")
        } else {
            Write-Host ("$num.`t$ip`t延迟`t$delay ms")
        }
    }
    Write-Host ''

    while ($true) {
        $choice = Read-Host '请输入序号 0-9'
        if ($choice -match '^0$') {
            while ($true) {
                $selectedIP = (Read-Host '请输入自定义 IP').Trim()
                if ($selectedIP -match '^(\d{1,3}\.){3}\d{1,3}$') { return $selectedIP }
                Write-Host 'IP 格式不正确，请重新输入。' -ForegroundColor Yellow
            }
        }

        if ($choice -match '^[1-9]$') {
            $idx = [int]$choice - 1
            if ($idx -ge 0 -and $idx -lt $Items.Count) {
                return $Items[$idx].IP
            }
        }

        Write-Host '输入无效，请重新输入。' -ForegroundColor Yellow
    }
}

function Update-Hosts {
    param(
        [string]$SelectedIP,
        [string]$DomainsPath,
        [string]$HostsPath,
        [string]$ScriptDir
    )

    $domains = Get-Content -LiteralPath $DomainsPath -Encoding UTF8 |
        ForEach-Object { $_.Trim() } |
        Where-Object { $_ -ne '' -and -not $_.StartsWith('#') } |
        Select-Object -Unique

    if ($domains.Count -lt 1) {
        Write-Host '错误：amazon_domains.txt 中没有可用域名。' -ForegroundColor Red
        exit 1
    }

    $backupPath = Join-Path $ScriptDir ("hosts_backup_" + (Get-Date -Format 'yyyyMMdd_HHmmss') + ".bak")
    Copy-Item -LiteralPath $HostsPath -Destination $backupPath -Force

    $hostLines = New-Object System.Collections.Generic.List[string]
    if (Test-Path -LiteralPath $HostsPath) {
        Get-Content -LiteralPath $HostsPath | ForEach-Object { $hostLines.Add($_) | Out-Null }
    }

    $domainSet = @{}
    foreach ($d in $domains) { $domainSet[$d.ToLowerInvariant()] = $true }

    $updatedSet = @{}
    $newLines = New-Object System.Collections.Generic.List[string]

    foreach ($line in $hostLines) {
        $trim = $line.Trim()

        if ($trim -eq '' -or $trim.StartsWith('#')) {
            $newLines.Add($line) | Out-Null
            continue
        }

        $main = $line
        $hashIndex = $line.IndexOf('#')
        if ($hashIndex -ge 0) {
            $main = $line.Substring(0, $hashIndex)
        }

        $parts = $main -split '\s+' | Where-Object { $_ -ne '' }
        if ($parts.Count -lt 2) {
            $newLines.Add($line) | Out-Null
            continue
        }

        $names = @($parts | Select-Object -Skip 1)
        $matched = @($names | Where-Object { $domainSet.ContainsKey($_.ToLowerInvariant()) })

        if ($matched.Count -gt 0) {
            foreach ($m in $matched) {
                $newLines.Add(("$SelectedIP`t$m")) | Out-Null
                $updatedSet[$m.ToLowerInvariant()] = $true
            }
        } else {
            $newLines.Add($line) | Out-Null
        }
    }

    foreach ($d in $domains) {
        if (-not $updatedSet.ContainsKey($d.ToLowerInvariant())) {
            $newLines.Add(("$SelectedIP`t$d")) | Out-Null
        }
    }

    Set-Content -LiteralPath $HostsPath -Value $newLines -Encoding ASCII

    try { ipconfig /flushdns | Out-Null } catch {}

    Write-Host 'hosts 更新完成。' -ForegroundColor Green
    Write-Host "已写入 IP：$SelectedIP"
    Write-Host "域名数量：$($domains.Count)"
    Write-Host "hosts 备份：$backupPath"
    Write-Host 'DNS 缓存已刷新。'
}

try {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    Set-Location $scriptDir

    if (-not (Is-Admin)) {
        Write-Host '错误：当前不是管理员权限。' -ForegroundColor Red
        Write-Host '请双击“亚马逊测速.bat”，并在系统弹窗中允许管理员权限。'
        exit 1
    }

    $resultPath = Join-Path $scriptDir 'result.csv'
    $domainsPath = Join-Path $scriptDir 'amazon_domains.txt'
    $hostsPath = Join-Path $env:SystemRoot 'System32\drivers\etc\hosts'

    if (-not (Test-Path -LiteralPath $domainsPath)) {
        Write-Host '错误：找不到 amazon_domains.txt。' -ForegroundColor Red
        exit 1
    }

    if (Test-Path -LiteralPath $resultPath) {
        $action = Read-WorkflowAction
        if ($action -eq 'Exit') {
            Write-Host '已退出，未修改 hosts。'
            exit 0
        }

        if ($action -eq 'Retest') {
            Invoke-SpeedTest -ScriptDir $scriptDir
        }
    } else {
        Write-Host '未找到 result.csv，将先进行测速。'
        Invoke-SpeedTest -ScriptDir $scriptDir
    }

    $items = @(Read-CsvLoose $resultPath)
    if ($items.Count -lt 1) {
        Write-Host '错误：result.csv 中没有读取到可用 IP。' -ForegroundColor Red
        exit 1
    }

    Write-Host ''
    $selectedIP = Select-ResultIP -Items $items

    Write-Host ''
    Write-Host "当前选择 IP：$selectedIP"
    Write-Host ''

    Update-Hosts -SelectedIP $selectedIP -DomainsPath $domainsPath -HostsPath $hostsPath -ScriptDir $scriptDir
}
catch {
    Write-Host ''
    Write-Host '更新失败：' -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

