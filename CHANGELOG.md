# Changelog

本项目的显著变更记录在此文件中。

格式参考 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)，版本号
遵循 [Semantic Versioning](https://semver.org/lang/zh-CN/)。

## [Unreleased]

### Changed

- 将项目名称统一为 AWS-SpeedTest。
- 补充 GitHub 开源发布所需的文档、许可证和第三方归属声明。

## [1.0.0] - 2026-06-09

### Added

- 集成 XIU2/CloudflareSpeedTest v2.3.4 官方 Windows x64 原版程序。
- 使用预设 IP 段进行延迟测试。
- 读取测速结果并支持选择或手动输入目标 IPv4 地址。
- 批量更新 Amazon Seller Central 与 Amazon Advertising hosts 记录。
- 修改 hosts 前自动创建时间戳备份。
- 更新完成后自动刷新 Windows DNS 缓存。
- 支持复用已有测速结果或重新测速。
