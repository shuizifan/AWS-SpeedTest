# AWS-SpeedTest GitHub 开源发布整理设计

## 目标

将当前 Windows AWS 优选 IP 与 hosts 更新工具整理为可公开发布的 GitHub
仓库，同时保持用户下载后可直接双击运行的体验，并满足上游
[XIU2/CloudflareSpeedTest](https://github.com/XIU2/CloudflareSpeedTest)
所采用的 GPL-3.0 许可证要求。

## 项目定位

本项目不是 CloudflareSpeedTest 的源码分支。项目直接分发上游官方
CloudflareSpeedTest v2.3.4 Windows 64 位原版二进制文件 `cfst.exe`，并在其
外部增加 PowerShell 与批处理自动化：

- 使用预设 AWS CloudFront IP 段执行延迟测试。
- 从测试结果中选择 IP。
- 将选定 IP 写入 Amazon Seller Central 与 Amazon Advertising 域名的
  Windows hosts 记录。
- 修改前备份 hosts 并在修改后刷新 DNS 缓存。

README 和 NOTICE 必须清楚区分上游组件与本项目新增内容，避免暗示 XIU2
参与、认可或维护本项目。

## 目录结构

采用用户确认的扁平运行目录。所有运行所需文件保留在仓库根目录，降低
Windows 普通用户的使用门槛：

```text
.
├── .gitattributes
├── .gitignore
├── CHANGELOG.md
├── LICENSE
├── NOTICE
├── README.md
├── SECURITY.md
├── amazon_domains.txt
├── cfst.exe
├── ip.txt
├── update-host.ps1
├── 亚马逊测速.bat
└── docs/
    ├── RELEASE.md
    └── superpowers/
        ├── plans/
        └── specs/
```

原有 `使用说明.txt` 的有效内容并入 README，避免维护两份容易不一致的用户
文档。运行后生成的文件不属于源码或发布基础文件，通过 `.gitignore` 排除：

- `result.csv`
- `hosts_backup_*.bak`
- 临时文件、日志和本地发布压缩包

## 文档设计

### README.md

README 使用简体中文，包含：

1. 项目用途与适用系统。
2. 显著的管理员权限及 hosts 修改警告。
3. 功能列表与文件说明。
4. 下载、运行和恢复方法。
5. 配置 Amazon 域名与 IP 段的方法。
6. 常见问题和安全提示。
7. 上游项目归属、版本、二进制校验值和许可证说明。
8. 免责声明。

### NOTICE

NOTICE 记录：

- 上游项目名称、作者和仓库地址。
- 所分发组件为官方 v2.3.4 未修改版 `cfst.exe`。
- 上游组件采用 GNU GPL v3.0。
- 本项目自行增加的脚本与配置内容。
- 上游对应源码的固定版本链接和获取方式。
- XIU2 未参与或认可本衍生工具。

### LICENSE

仓库整体使用 `GPL-3.0-only`，根目录保存 GNU GPL v3.0 完整许可证文本。
README 使用 SPDX 标识 `GPL-3.0-only`。本项目脚本可在文件头加入简短版权与
SPDX 声明；上游原版二进制不作修改。

### CHANGELOG.md

采用 Keep a Changelog 风格，首个公开版本暂定 `v1.0.0`，记录：

- 集成官方 CloudflareSpeedTest v2.3.4。
- 自动读取测速结果并更新 hosts。
- hosts 自动备份与 DNS 刷新。
- Amazon 域名和 CloudFront IP 段配置。

### SECURITY.md

说明该工具需要管理员权限且会修改 hosts，要求用户仅从 GitHub Releases
下载，并提供漏洞报告方式。由于尚未确定仓库所有者，报告入口先使用 GitHub
Security Advisory，不写入个人邮箱。

### docs/RELEASE.md

记录维护者发布流程：

- 更新版本与变更日志。
- 验证 PowerShell 语法。
- 验证 `cfst.exe -h` 显示 v2.3.4。
- 校验并记录 `cfst.exe` SHA-256。
- 从明确的运行文件清单生成 ZIP。
- 检查 ZIP 不包含运行结果或 hosts 备份。
- 在 Release 页面附上 GPL 许可证、上游归属和对应源码链接。

## GPL-3.0 合规策略

仓库分发 GPL-3.0 二进制时，不能只提供项目主页链接。发布材料必须同时保留
许可证和版权归属，并确保接收者能够获得该二进制对应的完整源代码。

本项目采用以下方式：

1. `LICENSE` 提供 GPL v3.0 完整文本。
2. `NOTICE` 和 README 标注 `cfst.exe` 来自 XIU2/CloudflareSpeedTest
   v2.3.4，未经修改。
3. 指向固定标签 `v2.3.4` 的上游源码归档，而不是只指向可能变化的 master
   分支。
4. GitHub Release 说明重复提供归属、许可证和对应源码链接。
5. Release ZIP 内包含 `LICENSE` 与 `NOTICE`。

如未来修改 CloudflareSpeedTest 的 Go 源码并重新编译，必须将修改后的完整
对应源码、构建说明和修改记录一起公开；届时不能继续使用“官方原版未修改”
声明。

## 发布包

GitHub 源码仓库保持专业文档完整。面向普通用户的 ZIP 保持扁平结构，仅包含：

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

不把 `.git`、设计文档、维护者发布文档、测试结果、hosts 备份或历史 ZIP
放入发布包。

## 验证

发布整理完成后执行以下检查：

- PowerShell 解析器确认 `update-host.ps1` 无语法错误。
- `cfst.exe -h` 确认版本为 v2.3.4 并保留上游项目地址。
- 检查 README、NOTICE、LICENSE 中版本和许可证表述一致。
- 检查忽略规则覆盖所有运行生成物。
- 生成测试 ZIP 并逐项核对文件清单。
- 检查 Git 工作区中不存在意外生成文件或敏感信息。

实际写入系统 hosts 的端到端测试会修改本机网络配置，不作为自动发布验证
执行；README 应提供人工验证和恢复说明。
