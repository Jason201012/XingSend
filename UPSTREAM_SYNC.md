# 上游同步操作手册（如何跟进 LocalSend 新版本）

本仓库是 LocalSend 的私人改名版（XingSend）。当上游 [localsend/localsend](https://github.com/localsend/localsend)
发布新版本、你想跟进时，按本手册操作。

核心思路是**整树替换法**：拿一份干净的上游检出，用 `apply_rebrand.sh` 自动重做全部品牌改造，
再整体替换本仓库源码。最后打一个新 tag，CI 自动构建并发布 Release，网站下载链接自动跟随。

## 准备（一次性，都已在位）

- 品牌补丁脚本：`E:\ZCode\4\apply_rebrand.sh`
- 图标脚本：`E:\ZCode\4\gen_icons.py`（已参数化）
- 一键构建：`E:\ZCode\4\build_all.cmd`
- 签名：`E:\dev\keys\xingsend\xingsend.jks`（本仓库 `app/android/` 下也有原件）
- 供应商化依赖：本仓库 `third_party/`（3 个上游 git 依赖的固定版本副本）

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

脚本自动完成：i18n 文案、Dart 硬编码、Android 包名、Windows CMake/Runner/Inno（含删除 msix
安装块）、网页模板、关于页重写、上游残留清理、图标重生成、third_party 与 keystore 拷贝。

### 3. 依赖检查（唯一需要动脑的步骤）

1. **flutter_rust_bridge 是否自洽**：比对上游 `Cargo.lock`/`Cargo.toml` 的 frb crate 版本
   与 `frb_generated.dart` 头部的 codegen 版本。一致 → 删掉根 `pubspec.yaml` 里的
   `flutter_rust_bridge` override；不一致 → 把 override 改成与生成代码一致的版本。
2. **3 个供应商化依赖是否变化**：对比上游 `app/pubspec.yaml` 的 git 依赖声明。若上游换了
   提交或改回了 pub.dev 版本 → 用新版本替换 `third_party/` 下对应目录，pubspec 覆盖保持
   指向 `../third_party/*` 不变。
3. **上游新增的 git 依赖**：同样供应商化进 `third_party/` 并加覆盖。

### 4. 本地构建验证

```cmd
E:\ZCode\4\build_all.cmd
```

三件套出来后：APK 装到手机、setup.exe 覆盖安装到电脑，实测互传。

### 5. 整树替换本仓库

```bash
cd E:/ZCode/4/localsend
# 用改造后的上游树替换源码目录（third_party、文档、git 历史保留在本仓库）
rm -rf app packages support server cli pubspec.yaml pubspec.lock Cargo.toml Cargo.lock rust-toolchain.toml .fvmrc CONTRIBUTING.md CHANGELOG.md AGENTS.md CLAUDE.md CODE_SIGNING.md README.md
cp -r E:/ZCode/upstream-localsend/{app,packages,support,server,cli,pubspec.yaml,pubspec.lock,Cargo.toml,Cargo.lock,rust-toolchain.toml,.fvmrc,LICENSE,CONTRIBUTING.md,CHANGELOG.md,AGENTS.md,CLAUDE.md,CODE_SIGNING.md} .
cp -r E:/ZCode/upstream-localsend/third_party .   # 或保留本仓库的（见步骤 3）
git checkout -- README.md REBRAND.md INSTALL.md UPSTREAM_SYNC.md .github/workflows/release.yml .github/workflows/pages.yml
# 恢复签名与密钥配置（key.properties 在 .gitignore 里不会丢，确认存在即可）
cp E:/dev/keys/xingsend/xingsend.jks app/android/
git add -A && git commit -m "Sync upstream vX.Y.Z"
git push origin main
```

注意：`README.md` 用本仓库自己的；`REBRAND.md`/`INSTALL.md`/`UPSTREAM_SYNC.md` 是本仓库文档；
`.github/workflows/release.yml` 和 `pages.yml` 是我们自己的工作流，绝不能被上游版本覆盖。
替换后把 REBRAND.md 的"基于版本"更新为新版本号。

### 6. 发布新版本

```bash
git tag v<新版本号>
git push origin v<新版本号>
```

或到 Actions 页面点 **Release XingSend → Run workflow**。CI 自动构建三件套并发布 Release；
官网下载链接是 `releases/latest/download/无版本号文件名`，**自动跟随，无需改网站**。

## 注意事项

- **keystore 与 key.properties 永远不要被上游内容覆盖**（已在 .gitignore，替换后确认存在）
- 上游若改了构建方式（不再用 Inno Setup、workspace 结构变化等），REBRAND.md 对应章节和
  `apply_rebrand.sh` 的 sed 规则要跟着核对
- 上游大版本升级（Flutter 版本跳变）需要按其新要求装对应 Flutter（CI 用 subosito/flutter-action
  的 FLUTTER_VERSION 变量，改 release.yml 顶部即可）
- 每次同步先本地 build_all 验证，再推送 + 发版
- 如果上游某个版本发布的 frb 代码与 crate 自洽了，记得删掉 frb override（根 pubspec.yaml）
