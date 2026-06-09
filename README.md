# AWS-SpeedTest

**AWS 优选 IP 工具**

一个面向 Windows 的 Amazon Seller Central / Amazon Advertising 访问优化辅助
工具。它调用 [XIU2/CloudflareSpeedTest](https://github.com/XIU2/CloudflareSpeedTest)
测试预设 IP 段的网络延迟，并将用户选中的 IP 写入 Windows `hosts` 文件。

> [!WARNING]
> 本工具需要管理员权限，并会修改系统 `hosts` 文件。运行前请关闭可能影响
> 测速结果的代理软件，并确认你了解 hosts 修改的作用。工具会在每次写入前
> 自动备份原 hosts 文件。

## 功能

- 使用预设 IP 段执行延迟测试。
- 自动读取 `result.csv` 中排名靠前的测速结果。
- 支持从测速结果中选择 IP，或手动输入 IPv4 地址。
- 批量更新 Amazon Seller Central 与 Amazon Advertising 域名。
- 修改前自动备份 hosts 文件。
- 修改后自动刷新 Windows DNS 缓存。
- 已有测速结果时，可直接更新 hosts 或重新测速。

## 系统要求

- Windows 10 或 Windows 11
- 64 位 x86 系统
- Windows PowerShell 5.1 或更高版本
- 可用的网络连接
- 本机管理员权限

当前仓库包含的 `cfst.exe` 是 Windows x64 版本，不适用于 ARM、Linux 或
macOS。

## 快速开始

1. 从 GitHub Releases 下载发布压缩包并完整解压。
2. 暂时关闭代理软件，避免测速流量被代理转发。
3. 双击 `亚马逊测速.bat`。
4. Windows 弹出权限确认窗口时选择“是”。
5. 等待测速完成，然后输入序号选择要写入 hosts 的 IP。
6. 看到“hosts 更新完成”后，重新打开浏览器并访问对应 Amazon 站点。

不要直接在压缩包内运行，也不要只复制其中某一个文件。

## 使用流程

### 首次运行

当前目录不存在 `result.csv` 时，工具会自动执行：

```text
cfst.exe -f ip.txt -dd
```

测速完成后，工具读取结果并显示最多 9 个候选 IP：

```text
0. 自定义输入 IP
1-9. 使用对应的测速结果
```

选择后，工具会备份系统 hosts、写入 Amazon 域名并刷新 DNS 缓存。

### 再次运行

检测到已有 `result.csv` 时，可选择：

```text
1. 直接使用现有结果更换 hosts
2. 重新测速后再更换 hosts
0. 退出
```

## 文件说明

| 文件 | 用途 |
| --- | --- |
| `亚马逊测速.bat` | 用户入口，申请管理员权限并启动 PowerShell 脚本 |
| `update-host.ps1` | 读取测速结果、选择 IP、备份和更新 hosts |
| `cfst.exe` | XIU2/CloudflareSpeedTest v2.3.4 官方原版程序 |
| `ip.txt` | 待测速的 IP 或 CIDR 网段 |
| `amazon_domains.txt` | 需要写入 hosts 的 Amazon 域名 |
| `result.csv` | 测速后自动生成，不属于发布基础文件 |
| `hosts_backup_*.bak` | 修改 hosts 前自动生成的备份 |

## 自定义配置

### 修改 Amazon 域名

使用文本编辑器打开 `amazon_domains.txt`：

- 每行填写一个完整域名。
- 空行会被忽略。
- 以 `#` 开头的行会被视为注释。
- 修改前建议核对域名，避免把无关站点指向同一个 IP。

### 修改测速 IP 段

使用文本编辑器打开 `ip.txt`，每行填写一个 IPv4 地址或 CIDR 网段。预设网段
可能随云服务商调整而失效，维护者应定期核对其来源与有效性。

## 恢复 hosts

每次更新前，工具都会在当前目录创建类似以下文件：

```text
hosts_backup_20260609_120000.bak
```

需要完全恢复时：

1. 以管理员身份打开文件资源管理器或 PowerShell。
2. 将所需备份复制并覆盖：

   ```text
   C:\Windows\System32\drivers\etc\hosts
   ```

3. 在管理员终端运行：

   ```powershell
   ipconfig /flushdns
   ```

也可以手动编辑系统 hosts，删除 `amazon_domains.txt` 中域名对应的记录，再刷新
DNS 缓存。

## 常见问题

### 测速延迟异常低

如果平均延迟低至 `0.xx ms`，通常表示测速流量经过了本机代理。关闭代理软件，
或将本工具相关流量排除代理后重新测速。

### 没有生成 result.csv

确认 `cfst.exe`、`ip.txt` 和脚本位于同一目录，并检查安全软件是否阻止了
`cfst.exe` 运行。也可以在当前目录的终端中执行：

```powershell
.\cfst.exe -f .\ip.txt -dd
```

### 更新后网站无法访问

选中的 IP 可能已失效、所在节点不适合目标域名，或受到本地网络限制。请重新
测速并更换 IP；仍无法恢复时，使用自动生成的 hosts 备份。

### 安全软件提示风险

本工具会申请管理员权限、启动命令行程序并修改 hosts，这些行为可能触发安全
软件提示。请只从本项目 GitHub Releases 或上游官方仓库获取文件，并核对
校验值。不要关闭安全软件来运行来源不明的副本。

## 上游项目与开源声明

本项目使用以下第三方组件：

- 项目：[XIU2/CloudflareSpeedTest](https://github.com/XIU2/CloudflareSpeedTest)
- 版本：`v2.3.4`
- 文件：`cfst.exe`
- 状态：上游官方发布的 Windows x64 原版，本项目未修改该二进制文件
- 许可证：[GNU General Public License v3.0](LICENSE)
- 对应源码：
  [v2.3.4 标签](https://github.com/XIU2/CloudflareSpeedTest/tree/v2.3.4) /
  [源码归档](https://github.com/XIU2/CloudflareSpeedTest/archive/refs/tags/v2.3.4.zip)

仓库中 `cfst.exe` 的 SHA-256：

```text
1FAF41130C1CAB185EC82CA7DDB58108574FDDBAE5B0F85CC92C07EE87AEC331
```

本项目增加了 Windows 启动脚本、测速结果处理、Amazon 域名配置、hosts 备份
与更新流程。XIU2/CloudflareSpeedTest 的作者未参与本项目，也不代表其认可或
维护本项目。详细归属信息见 [NOTICE](NOTICE)。

本仓库以 `GPL-3.0-only` 许可证发布。分发修改版本时，必须继续遵守 GNU GPL
v3.0，包括保留许可证与版权声明，并向接收者提供相应的完整源代码。

## 安全与隐私

- 脚本仅在本机读取测速结果和修改 hosts。
- 工具不会收集或上传账号、Cookie、密码等个人信息。
- `cfst.exe` 的网络行为及实现由上游项目负责。
- 请勿在无法确认来源和校验值的情况下授予管理员权限。

安全问题请参阅 [SECURITY.md](SECURITY.md)。

## 免责声明

本项目与 Amazon、Amazon Web Services、Cloudflare 或 XIU2 均无隶属、合作或
官方认可关系。“Amazon”“AWS”“Cloudflare”等名称及商标归各自权利人所有。

网络路由、CDN 节点和 IP 可用性会随时间变化。本工具不保证能够提升访问速度
或持续可用。修改 hosts 可能造成目标网站无法访问、登录异常或连接到非预期
节点。使用者应自行评估风险并对操作结果负责。

## License

[GNU General Public License v3.0 only](LICENSE) (`GPL-3.0-only`)
