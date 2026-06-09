# 安全策略

## 支持版本

安全修复仅面向最新发布版本。请先确认问题能够在最新 GitHub Release 中复现。

## 报告安全问题

请优先通过 GitHub 仓库的 **Security > Report a vulnerability** 私密报告安全
问题。不要在公开 Issue 中发布可直接利用的漏洞细节、个人数据或系统配置。

报告时请提供：

- 受影响版本和 Windows 版本。
- 复现步骤与预期行为。
- 实际影响及必要的日志片段。
- 是否涉及 `update-host.ps1`、管理员权限或 hosts 文件。

如果仓库尚未启用 Private Vulnerability Reporting，请创建不含敏感细节的
Issue，请求维护者提供私密沟通方式。

## 使用安全

AWS-SpeedTest 会申请管理员权限并修改：

```text
C:\Windows\System32\drivers\etc\hosts
```

请只从本项目 GitHub Releases 下载，并在运行前核对 `cfst.exe` 的 SHA-256。
不要运行来源不明、校验值不一致或被重新打包的版本。

上游 `cfst.exe` 自身的问题请同时参考：
[XIU2/CloudflareSpeedTest Security](https://github.com/XIU2/CloudflareSpeedTest/security)
