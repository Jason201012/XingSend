# XingSend 改名清单（相对上游 LocalSend 的全部改动）

本仓库基于 [LocalSend](https://github.com/localsend/localsend) v1.18.2（main 分支，2026-10 克隆）改名而来。
上游使用 Apache-2.0 许可证，本项目自用合规；LICENSE 文件保留。协议、端口 53317、传输逻辑未做任何改动，
因此与官方 LocalSend 客户端仍然互通。

## 1. 应用名（所有语言界面显示 XingSend）

- `app/assets/i18n/*.json`：所有 `LocalSend` 字样 → `XingSend`（含 5 个本地化品牌名：bn/fa/hi/ml/ta）
- 已执行 `dart run slang` 重新生成 `app/lib/gen/strings*.g.dart`
- `packages/core/assets/web/*.html`：链接分享（via link）的浏览器页面（download/upload/403）
  的标题、页头、noscript 提示 → XingSend。注意 `/api/localsend/v2` 是协议路径，保持不变；
  这些 HTML 由 Rust 核心内嵌（include），改动后需重新构建两端

## 2. Dart 硬编码字符串

| 文件 | 改动 |
|---|---|
| `app/lib/config/init_error.dart` | 错误弹窗标题/版本文案 → XingSend |
| `app/lib/pages/home_page.dart` | 侧边栏标题 → XingSend |
| `app/lib/util/native/context_menu_helper.dart` | 「发送到」快捷方式文件名 LocalSend.lnk → XingSend.lnk |
| `app/lib/provider/persistence_provider.dart` | 设置文件路径 `%APPDATA%\LocalSend\` → `%APPDATA%\XingSend\` |
| `app/lib/pages/troubleshoot_page.dart` | 防火墙规则名建议 → XingSend |
| `app/lib/widget/local_send_logo.dart` | logo 旁文字 → XingSend |
| `app/lib/util/native/autostart_helper.dart` | 开机自启注册表值名 → XingSend |

未改动的内部标识（不影响使用）：`LocalSendApp`/`LocalSendLogo` 类名、Kotlin method channel 名、
macOS channel case 名、`org.localsend` 遗留迁移路径。

## 3. Android

- `app/android/app/build.gradle`：`applicationId` → `com.xingsend.app`（namespace 保持 `org.localsend.localsend_app`，避免搬移 Kotlin 源码）
- `app/android/app/src/main/AndroidManifest.xml`：两处 `android:label` → XingSend
- `app/android/app/src/debug/AndroidManifest.xml`：label → XingSend Debug
- 签名：`app/android/xingsend.jks`（未提交 git）+ `app/android/key.properties`
- 图标：`mipmap-*/ic_launcher*.png`、`ic_launcher_foreground/monochrome/quicktile_foreground`、`drawable/banner.png`、
  `values/ic_launcher_background.xml`（#FFFFFF → #17173B）

## 4. Windows

- `app/windows/CMakeLists.txt`：`BINARY_NAME` → `xingsend`（exe 名 xingsend.exe）；
  删除了 msix helper 的 install(FILES) 规则（自建包不做商店组件，否则 install 阶段因缺少 msix 文件而失败）
- `app/windows/runner/Runner.rc`：FileDescription/InternalName/OriginalFilename/ProductName/LegalCopyright → XingSend
- `app/windows/runner/main.cpp`：窗口标题 `window.Create(L"XingSend")`
- `support/scripts/compile_windows_exe-inno.iss`：MyAppName/MyAppPublisher → XingSend，
  MyAppExeName → xingsend.exe，AppId → 新 GUID `d3b869ac-8999-45ad-bd60-cbd2646bc97d`（与官方安装器并存），
  OutputBaseFilename → XingSend
- 图标：`app/windows/runner/resources/app_icon.ico`、`app/assets/packaging/logo.ico`、`app/assets/img/logo*`（托盘/侧边栏/关于页）

## 5. 依赖来源（重要：同步上游时需还原）

`app/pubspec.yaml` 的 `dependency_overrides` 中 3 个 GitHub git 依赖改为本地路径
（国内访问 GitHub 不稳定；本地内容与上游锁定的提交完全一致）：

| 包 | 上游 git 声明（同步上游时还原） | 本地路径 |
|---|---|---|
| device_apps 2.2.0 | github.com/Tienisto/device_apps.git @ 5dc7956d | E:/ZCode/gitdeps/device_apps-src |
| pasteboard 0.3.0 | github.com/Seidko/flutter-plugins.git @ 58748dae (packages/pasteboard) | E:/ZCode/gitdeps/flutter-plugins-58748dae.../packages/pasteboard |
| permission_handler_windows 0.1.2 | github.com/localsend/permission_handler_windows_noop.git @ 2dadd8af | E:/ZCode/gitdeps/permission-src |

另外在 workspace 根 pubspec.yaml 的 `dependency_overrides` 里加了 `flutter_rust_bridge: 2.12.0`：
上游 lock 的 frb Dart 包是 2.13.0，但提交的 frb_generated.dart 是 2.12.0 生成的（Rust 侧也钉死 =2.12.0），
版本守卫会抛 "codegen version (2.12.0) should be the same as runtime version (2.13.0)" 导致 Rust 库无法初始化、
两端服务全部起不来（症状：界面能开但搜不到设备/无法传输）。同步上游后若上游已自洽可移除此 override。

## 6. 构建配置微调（同步上游时注意）

- `app/android/gradle/wrapper/gradle-wrapper.properties`：distributionUrl 改为腾讯云镜像
  （https://mirrors.cloud.tencent.com/gradle/gradle-8.13-all.zip），版本不变（8.13），仅换下载源
- 中文 Windows 构建需 `set CL=/utf-8`（环境变量，非仓库改动）+ 开发者模式，详见 INSTALL.md

## 7. 图标再生成脚本

`E:/ZCode/4/gen_icons.py`（Python + Pillow）：深蓝→紫罗兰渐变圆角方块 + 白色四角星 + 伴星。
修改设计后重跑即可重新生成全部图标产物。

## 8. 运行环境要点（2026-10-24 排查"启动了但不能用"的结论）

1. **两端服务起不来的根因**是上面的 frb 版本不一致，修复后端口 53317 正常监听。
2. **Windows 防火墙**：已添加入站放行规则 `XingSend TCP` / `XingSend UDP`（端口 53317，与安装路径无关）。
3. **PC 广播走错网卡**：本机有 Hyper-V 虚拟网卡（172.28.224.1），多播广播默认从它发出，手机收不到。
   已在 `%APPDATA%\XingSend\settings.json` 写入 `"flutter.ls_network_blacklist": ["172.28.*.*"]`
   （IP 过滤按段通配，`*` = 一段不含点的字符；也可在 设置→网络 里改）。
4. **v2 发现是按需触发的**：应用启动后不会自动广播，打开"附近设备"列表/点刷新/发起发送时才会发广播并互相确认。
5. **与官方 LocalSend 并存**：两者都用 53317 端口，**不要同时运行**（后启动的会绑定失败）。
   手机上官方版（org.localsend.localsend_app）还装着，注意别同时开。
6. **MIUI/小米手机**：后台应用可能被省电策略冻结，导致服务掉线。建议在 系统设置→应用管理→XingSend→省电策略 设为"无限制"，并允许自启动。
7. 官方 LocalSend 的设置（含接收历史）会被 XingSend 自动迁移（`_windowsLegacyFile` 迁移逻辑）。

## 9. 已知未改项

- `app/windows/localsend_app.exe.manifest`：上游遗留文件，不再被 install 规则引用，无影响
- 应用内「支持/捐赠」入口仍指向 LocalSend 原作者（作为对上游的致谢保留）
- 关于页链接仍指向 localsend.org / GitHub
