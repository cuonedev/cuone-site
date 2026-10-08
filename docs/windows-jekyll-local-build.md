# Windows 本地预览与构建记录

本站（Jekyll + Chirpy）在 Windows 原生环境下搭建本地预览、解决 native gem 编译问题的记录。**本文档仅作内部参考，`docs/` 已在 `_config.yml` 的 `exclude` 中，不会发布到站点。**

结论：Windows 原生可行，不需要 WSL / Docker。

## 一、环境

- OS：Windows
- Ruby：3.4.11 `x64-mingw-ucrt`，安装目录 `C:\Ruby34-x64`
- MSYS2：随 DevKit 安装，位于 `C:\Ruby34-x64\msys64`
- 项目：`E:\cuone\cuone-site`

## 二、安装 Ruby（一次性）

1. 下载 RubyInstaller **带 DevKit** 版本（GitHub 直连慢，用镜像）：
   - `https://mirror.nju.edu.cn/github-release/oneclick/rubyinstaller2/`
   - 选 `RubyInstaller-3.4.11-1` 目录下的 `rubyinstaller-devkit-3.4.11-1-x64.exe`
2. 静默安装（**需要管理员权限**）：
   ```powershell
   rubyinstaller-devkit-3.4.11-1-x64.exe /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /DIR=C:\Ruby34-x64 /TASKS=modifypath,assocfiles
   ```
3. 初始化 MSYS2 工具链（**必须管理员运行，否则 pacman 写密钥环失败**）：
   ```powershell
   C:\Ruby34-x64\bin\ridk.cmd install 3
   ```
   成功标志：末行 `Install MSYS2 and MINGW development toolchain succeeded`

## 三、安装依赖

1. 配置国内 gem 镜像（写入 `.bundle/config`，该文件被 gitignore，**换机器需重设**）：
   ```powershell
   cd E:\cuone\cuone-site
   bundle config set --local mirror.https://rubygems.org https://mirrors.tuna.tsinghua.edu.cn/rubygems/
   ```
2. `bundle install`（见下一节的 native 扩展坑）

## 四、关键坑：eventmachine 原生扩展编译失败

### 现象

`bundle install` 在装 `eventmachine 1.2.7` 时报错（它由 `jekyll → em-websocket` 间接引入）：

```
compiling binder.cpp
make: g++: Permission denied
make: *** [Makefile:243：binder.o] 错误 127
```

用 shim 绕过 `Permission denied` 后，又变成：

```
g++.exe: fatal error: cannot execute 'cc1plus': CreateProcess: No such file or directory
```

### 根因

- mkmf 生成的 `Makefile` 里 `CXX = g++ -std=gnu++11`，即调用 PATH 里的 `g++`。
- MSYS2 的 `C:\Ruby34-x64\msys64\ucrt64\bin\g++.exe` **在 Windows 下无法被直接启动**（系统报“访问 %1 被 %2 阻止”一类错误），而同目录的 `x86_64-w64-mingw32-g++.exe` 可以正常运行。
- 因此 `make` 调 `g++` 失败；换成能跑的编译器后，还需让它能找到 `cc1plus`（位于 `msys64\ucrt64\lib\gcc\x86_64-w64-mingw32\16.2.0\`）。

### 解决：用 RUBYOPT 覆盖 CXX

仓库内已提供 `docs/cxx.rb`（换机器时按新安装路径调整其中的 Ruby 目录）：

```ruby
require 'rbconfig'

gxx = 'C:/Ruby34-x64/msys64/ucrt64/bin/x86_64-w64-mingw32-g++.exe -std=gnu++11'
RbConfig::CONFIG['CXX'] = gxx
RbConfig::MAKEFILE_CONFIG['CXX'] = gxx
```

安装时让 mkmf 生成带完整路径的 `CXX`：

```powershell
$env:Path = "C:\Ruby34-x64\msys64\ucrt64\bin;C:\Ruby34-x64\msys64\usr\bin;" + $env:Path
$env:RUBYOPT = "-rE:/cuone/cuone-site/docs/cxx.rb"
cd E:\cuone\cuone-site
bundle install
```

成功标志：`Bundle complete! 4 Gemfile dependencies, 45 gems now installed.`

> 说明：之前尝试过复制 `g++`、用 `gppshim` 目录、从 PowerShell 直接跑 make 等，均不必要。**最终只需 ucrt64/usr 的 bin 在 PATH + `RUBYOPT` 覆盖 CXX**。

## 五、日常使用

```powershell
cd E:\cuone\cuone-site
bundle exec jekyll serve --drafts
```

- 访问 `http://127.0.0.1:4000/`
- `--drafts` 才会预览 `_drafts/` 草稿；**GitHub Actions 发布构建不得带该参数**
- 改文件自动重建（`--livereload` 可自动刷新浏览器）

## 六、还原当前服务（可选）

停止后台服务：

```powershell
Get-NetTCPConnection -LocalPort 4000 -State Listen | ForEach-Object { Stop-Process -Id $_.OwningProcess -Force }
```

## 七、换到另一台 Windows 的清单

- [ ] 安装 RubyInstaller DevKit 版 + `ridk install 3`（管理员）
- [ ] 确认 `docs/cxx.rb` 里的 Ruby 目录与新机器一致（不一致就改）
- [ ] 配置 gem 镜像（`.bundle/config` 未入库）
- [ ] 用第五节命令 `bundle install`
- [ ] `bundle exec jekyll serve --drafts` 验证

## 八、样式自定义说明

- 自定义样式入口：`assets/css/jekyll-theme-chirpy.scss`（同名覆盖主题文件，未内联整个主题）。
- 文件顶部两段 `@use` 必须与主题保持一致，否则主题样式整体丢失；自定义内容追加到末尾。
- 改颜色优先覆盖 `:root[data-bs-theme='light'] / ['dark']` 的 CSS 变量；改尺寸/字体用 `@use 'abstracts/variables' with (...)`。
