# XingSend

我的个人局域网传输工具——基于开源项目 [LocalSend](https://github.com/localsend/localsend) 改名定制。

与 LocalSend 一样：无需互联网、无需账号，同一局域网内的设备互相发现即可安全收发文件和消息。

## 与 LocalSend 的关系

- 本仓库是 LocalSend v1.18.2 的私人定制分支，应用更名为 **XingSend**，换了独立图标
- 安卓包名 `com.xingsend.app`、Windows 安装器独立 AppId，可与官方 LocalSend **同时安装、互不干扰**
- 传输协议未做任何修改，与官方 LocalSend 客户端**完全互通**
- 全部界面文案、应用图标、链接分享网页均已更名（改动清单见 [REBRAND.md](REBRAND.md)）
- 感谢 LocalSend 原作者 [Tien Do Nam](https://github.com/Tienisto) 与社区贡献者的出色工作

## 目录说明

| 路径 | 内容 |
|---|---|
| [REBRAND.md](REBRAND.md) | 相对上游的全部改动清单 |
| [INSTALL.md](INSTALL.md) | 构建与安装说明、签名信息 |
| [UPSTREAM_SYNC.md](UPSTREAM_SYNC.md) | 跟进上游新版本的操作手册 |
| `app/` | Flutter 主应用（Windows / Android） |
| `apply_rebrand.sh` | 品牌改造脚本（在 `E:\ZCode\4\`，配合 UPSTREAM_SYNC.md 使用） |

## 构建（本机）

```cmd
E:\ZCode\4\build_all.cmd
```

产物输出到 `E:\ZCode\4\dist\`（Windows 安装程序 + 便携 zip + 安卓 APK）。

## 许可证

本项目遵循上游的 [Apache License 2.0](LICENSE)。
