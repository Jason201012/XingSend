# 上游同步操作手册（如何跟进 LocalSend 新版本）

本仓库是 LocalSend 的私人改名版（XingSend）。当上游 [localsend/localsend](https://github.com/localsend/localsend)
发布新版本、你想跟进时，按本手册操作。核心思路是**整树替换法**：拿一份干净的上游检出，
用 `apply_rebrand.sh` 自动重做全部品牌改造，再整体替换本仓库源码。

## 准备（一次性）

- 品牌补丁脚本：`E:\ZCode\4\apply_rebrand.sh`（改名清单的机械化版本）
- 图标脚本：`E:\ZCode\4\gen_icons.py`（已参数化，`python gen_icons.py <目标目录>`）
- 一键构建：`E:\ZCode\4\build_all.cmd`
- 签名：`E:\dev\keys\xingsend\xingsend.jks`（或旧仓库 `app/android/` 下的原件）
- 依赖本地缓存：`E:\ZCode\gitdeps\`（device_apps / pasteboard / permission_handler_windows）

## 同步步骤

### 1. 获取上游新版本

```bash
# 直连不行就加镜像前缀 https://gh-proxy.com/
git clone --depth 1 -b vX.Y.Z https://github.com/localsend/localsend.git E:/ZCode/upstream-localsend
```

### 2. 应用品牌改造

```bash
bash E:/ZCode/4/apply_rebrand.sh /e/ZCode/upstream-localsend
```

脚本会自动完成：i18n 文案、Dart 硬编码、Android 包名与签名文件、Windows CMake/Runner/Inno
（含删除 msix 安装块）、网页模板、关于页重写（从旧仓库拷贝）、删除上游残留、图标全套重生成。

### 3. 依赖检查（唯一需要动脑的步骤）

对照 `app/pubspec.yaml` 与 `pubspec.lock`，检查三件事：

1. **flutter_rust_bridge 是否自洽**：比对上游 `Cargo.lock`/`Cargo.toml` 里 frb crate 版本
   与 `frb_generated.dart` 头部的 codegen 版本。一致 → 不需要我们的 override；仍不一致 →
   把根 `pubspec.yaml` 的 `dependency_overrides` 里 `flutter_rust_bridge: 2.12.0` 改成与生成代码一致的版本。
2. **3 个 git 依赖是否变化**：上游若换了提交/换回了 pub.dev 版本，更新 `app/pubspec.yaml`
   的 dependency_overrides（必要时重新跑 gitdeps 克隆流程，见 REBRAND.md 第 5 节）。
3. **新增/删除的 git 依赖**：同样进 overrides 处理。

### 4. 构建验证

```bash
cd E:/ZCode/4
cmd /c build_all.cmd
```

产物出来后：装 APK 到手机 + 装新 setup.exe，实测互传。

### 5. 整树替换本仓库

```bash
cd E:/ZCode/4/localsend
# 用改造后的上游树替换源码目录（保留本仓库的文档与 git 历史）
rm -rf app packages support server cli website fastlane pubspec.yaml pubspec.lock Cargo.toml Cargo.lock rust-toolchain.toml .fvmrc LICENSE CONTRIBUTING.md README.md CHANGELOG.md AGENTS.md CLAUDE.md CODE_SIGNING.md
cp -r E:/ZCode/upstream-localsend/{app,packages,support,server,cli,website,fastlane,pubspec.yaml,pubspec.lock,Cargo.toml,Cargo.lock,rust-toolchain.toml,.fvmrc,LICENSE,CONTRIBUTING.md,CHANGELOG.md,AGENTS.md,CLAUDE.md,CODE_SIGNING.md} .
git checkout -- README.md   # README 用我们自己的（见下）
# 恢复签名文件（整树替换会带入上游的空状态）
cp E:/dev/keys/xingsend/xingsend.jks app/android/
# key.properties 在 .gitignore 里不会被删，确认存在即可
git add -A && git commit -m "Sync upstream vX.Y.Z"
```

README.md 不用上游的（那是 LocalSend 的说明），保留本仓库自己的。
REBRAND.md / INSTALL.md / UPSTREAM_SYNC.md 是本仓库文档，不受影响。
替换后把 REBRAND.md 里的"基于版本"信息更新为新版本号。

## 注意事项

- **keystore 与 key.properties 永远不要被上游内容覆盖**（key.properties 已在 .gitignore）
- 上游若改了构建方式（比如不再用 Inno Setup / workspace 结构变化），REBRAND.md 里的
  对应章节要跟着更新，`apply_rebrand.sh` 的 sed 也要核对是否还匹配
- 上游大版本升级（Flutter 版本跳变）可能需要按其新要求装对应 Flutter
- 每次同步后先在本机构建验证，再推 GitHub
