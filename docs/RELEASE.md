# AWS-SpeedTest 发布指南

## 发布前检查

1. 更新 `CHANGELOG.md`，将待发布内容移入正式版本。
2. 确认 README、NOTICE 和发布说明中的 CloudflareSpeedTest 版本一致。
3. 验证 PowerShell 语法：

   ```powershell
   $tokens = $null
   $errors = $null
   [System.Management.Automation.Language.Parser]::ParseFile(
       (Resolve-Path '.\update-host.ps1'),
       [ref]$tokens,
       [ref]$errors
   ) | Out-Null
   $errors
   ```

   预期结果：不输出任何错误。

4. 验证上游程序版本：

   ```powershell
   .\cfst.exe -h
   ```

   预期结果包含：

   ```text
   CloudflareSpeedTest v2.3.4
   https://github.com/XIU2/CloudflareSpeedTest
   ```

5. 验证二进制校验值：

   ```powershell
   (Get-FileHash .\cfst.exe -Algorithm SHA256).Hash
   ```

   预期结果：

   ```text
   1FAF41130C1CAB185EC82CA7DDB58108574FDDBAE5B0F85CC92C07EE87AEC331
   ```

## 构建发布包

从干净工作区创建 `release` 目录，并仅复制以下文件：

```text
LICENSE
NOTICE
README.md
amazon_domains.txt
cfst.exe
ip.txt
update-host.ps1
亚马逊测速.bat
```

发布包文件名格式：

```text
AWS-SpeedTest-v1.0.0-windows-x64.zip
```

不得包含：

- `.git` 或 `.github`
- `result.csv`
- `hosts_backup_*.bak`
- 历史 ZIP、日志或临时文件
- `docs/superpowers`

## GPL 发布要求

发布 ZIP 必须包含 `LICENSE` 和 `NOTICE`。GitHub Release 页面必须明确说明：

- `cfst.exe` 为 XIU2/CloudflareSpeedTest v2.3.4 官方原版，未经修改。
- 上游许可证为 GNU GPL v3.0。
- 对应源码可从以下固定版本地址获得：
  <https://github.com/XIU2/CloudflareSpeedTest/archive/refs/tags/v2.3.4.zip>

建议同时把上述源码归档作为 Release 附件上传，文件名使用：

```text
CloudflareSpeedTest-v2.3.4-source.zip
```

如果未来修改并重新编译 `cfst.exe`，必须发布修改后的完整对应源码、构建说明
和修改记录，不得继续使用“官方原版、未经修改”的声明。

## Release 说明模板

```markdown
## AWS-SpeedTest v1.0.0

Windows AWS 优选 IP 与 hosts 更新工具。

### 下载

下载 `AWS-SpeedTest-v1.0.0-windows-x64.zip`，完整解压后双击
`亚马逊测速.bat`。

### 第三方组件

本版本包含未经修改的 XIU2/CloudflareSpeedTest v2.3.4 Windows x64
`cfst.exe`，采用 GNU GPL v3.0。对应源码：
https://github.com/XIU2/CloudflareSpeedTest/archive/refs/tags/v2.3.4.zip

### 校验值

cfst.exe SHA-256:
1FAF41130C1CAB185EC82CA7DDB58108574FDDBAE5B0F85CC92C07EE87AEC331
```
