# XingSend 构建与安装说明

## 产物位置

构建完成后统一下载/复制到 `E:\ZCode\4\dist\`：

| 文件 | 用途 |
|---|---|
| `XingSend-<版本>.apk` | 安卓安装包（通用 APK，含全部 ABI） |
| `xingsend-portable-<版本>.zip` | Windows 便携版（解压即用） |
| `XingSend-<版本>-setup.exe` | Windows 安装程序（Inno Setup） |

## 签名信息（务必妥善保管）

- keystore：`app/android/xingsend.jks`
- 别名：`xingsend`
- 密码（store/key 相同）：`xingsend-2026`
- **异地备份：`E:\dev\keys\xingsend\`**（含 xingsend.jks 副本和密码说明.txt，已验证可用）
- 以后升级安装必须使用同一 keystore 签名，否则安卓会拒绝覆盖安装。

## 一键构建

```
E:\ZCode\4\build_all.cmd            出齐三件套（Windows 安装程序 + 便携 zip + APK）
E:\ZCode\4\build_all.cmd /install   构建后顺便把 APK 装到已连接的手机
```

脚本会自动：pub get → 构建 Windows（含 CL=/utf-8）→ 构建 APK → 组装 payload → 打 zip →
打安装程序（版本号自动从 app/pubspec.yaml 读取）→ 复制产物到 dist。
注意：脚本开头会关闭正在运行的 XingSend（构建需要覆盖其文件），且文件本身必须保持纯 ASCII
（cmd 按 GBK 解析批处理，UTF-8 中文注释会破坏命令解析）。

## 重新构建步骤

> 本机构建统一使用 Flutter 3.41.9（`E:\dev\flutter-3.41.9\bin\flutter`），与仓库固定版本一致；
> 系统里另有 Flutter 3.47.1（E:\flutter），构建本项目时不要使用（其要求 Gradle≥8.14/Kotlin≥2.2.20，与项目配置冲突）。

### 安卓 APK

```bash
cd localsend
E:\dev\flutter-3.41.9\bin\flutter pub get
cd app
E:\dev\flutter-3.41.9\bin\flutter build apk --release
# 产物: build/app/outputs/flutter-apk/app-release.apk (约 122MB, 通用含4种ABI)
```

签名配置在 `app/android/key.properties`，其中 `storeFile=../xingsend.jks` 相对于 `app/android/app/` 目录解析。

### Windows（exe + 安装程序）

前提：
- 已开启 Windows 开发者模式（符号链接权限；flutter 插件构建必需）
- 中文系统下 MSVC 会把插件源码的 UTF-8 告警当错误（C4819+C2220），必须给编译器加 /utf-8

```bat
cd localsend\app
set CL=/utf-8
E:\dev\flutter-3.41.9\bin\flutter build windows --release
# 产物: build\windows\x64\runner\Release\xingsend.exe

:: 组装 payload：Release 内容 + app\assets\packaging\logo.ico + support\build\windows\x64\*.dll
:: 便携版：payload 打 zip
:: 安装程序：
"C:\Users\jason\AppData\Local\Programs\Inno Setup 6\ISCC.exe" /DPayloadDir=<payload目录> /DResultDir=E:\ZCode\4\dist /DSkipSignTool /DSkipMsixHelper support\scripts\compile_windows_exe-inno.iss
```

`/DSkipSignTool` 跳过官方代码签名（自用无需），`/DSkipMsixHelper` 跳过商店辅助组件。
本机 Inno Setup 位置：`C:\Users\jason\AppData\Local\Programs\Inno Setup 6\ISCC.exe`

## 环境要求（本机已满足）

- Flutter 3.41.9（仓库固定版本；本机 3.47.1 已验证可用）+ Dart workspace
- Rust（仓库 rust-toolchain.toml 固定 1.97.1，rustup 自动切换）
- Windows：VS C++ 工具集 + Windows SDK（本机 VS 2026 BuildTools）
- Android：SDK（E:\dev\android-sdk）、NDK、JDK 17+
- 国内网络：pub/flutter 镜像已全局配置（flutter-io.cn）；GitHub 依赖见 REBRAND.md 本地路径方案

## 与官方 LocalSend 的关系

- 包名/安装 ID 不同（安卓 com.xingsend.app，Windows 独立 AppId），可与官方 LocalSend 同时安装、互不干扰
- 传输协议与官方完全兼容，同一局域网内 XingSend 与 LocalSend 可互相发现并传文件
