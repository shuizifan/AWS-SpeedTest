# AWS-SpeedTest

测试预设 IP 段的网络延迟，将选中的 IP 写入 Windows `hosts` 文件，用于优化 Amazon Seller Central / Amazon Advertising 的访问速度。

> [!WARNING]
> 需要管理员权限，会修改系统 `hosts` 文件。运行前请关闭代理软件，工具会在每次写入前自动备份原 hosts。

## 使用方法

1. 从 Releases 下载压缩包并完整解压。
2. 关闭代理软件。
3. 双击 `亚马逊测速.bat`，UAC 弹窗选择"是"。
4. 等待测速完成，输入序号选择 IP。
5. 看到"hosts 更新完成"后，重新打开浏览器访问对应 Amazon 站点。

再次运行时，可选择直接使用已有测速结果或重新测速。

## 文件说明

| 文件 | 用途 |
| --- | --- |
| `亚马逊测速.bat` | 入口，申请管理员权限并启动脚本 |
| `update-host.ps1` | 读取结果、选择 IP、备份和更新 hosts |
| `cfst.exe` | XIU2/CloudflareSpeedTest v2.3.4 原版程序 |
| `ip.txt` | 待测速的 IP 或 CIDR 网段 |
| `amazon_domains.txt` | 需要写入 hosts 的域名，每行一个，支持 `#` 注释 |

## 恢复 hosts

工具每次更新前会在当前目录生成 `hosts_backup_*.bak`，将其复制覆盖到 `C:\Windows\System32\drivers\etc\hosts`，然后运行 `ipconfig /flushdns` 即可恢复。

## 上游项目

`cfst.exe` 来自 [XIU2/CloudflareSpeedTest](https://github.com/XIU2/CloudflareSpeedTest) v2.3.4，未经修改。SHA-256：

```
1FAF41130C1CAB185EC82CA7DDB58108574FDDBAE5B0F85CC92C07EE87AEC331
```

## License

[GPL-3.0-only](LICENSE)
