# C4-AI-project

C4-AI大赛暗影骑士王们队项目仓库。

## 项目简介

知学搭子是一款面向学习场景的 HarmonyOS / ArkTS 应用原型，围绕学习建议、错题分析、学习标签、搭子匹配和协同学习计划形成完整演示流程。

## 本地开发

1. 使用 DevEco Studio 打开项目根目录。
2. 确认已安装 HarmonyOS SDK `6.1.1(24)`。
3. 在 DevEco Studio 中执行 `Sync and Refresh Project`。
4. 配置本机签名后运行 `entry` 模块。

## 目录说明

- `AppScope/`：应用级配置与全局资源，例如应用名称、图标、包信息。
- `entry/`：主应用模块，页面源码、路由配置、模块配置都在这里。
- `entry/src/main/ets/pages/`：ArkTS 页面代码，当前演示流程的 6 个页面都在此目录。
- `entry/src/main/ets/models/`：ArkTS 数据类型定义，包括页面演示类型和学习服务类型。
- `entry/src/main/ets/data/`：DevEco 可直接编译的本地 Mock 数据。
- `entry/src/main/ets/services/`：本地学习服务逻辑，由原 Python 服务改写而来。
- `entry/src/main/resources/`：模块资源文件，例如颜色、图片、页面 profile。
- `backend/`：B 同学原始 Python 服务、说明文档和 JSON Mock 数据，作为后续接真实后端的参考。
- `hvigor/`、`hvigorfile.ts`：HarmonyOS / ArkUI-X 构建配置。
- `.arkui-x/`：ArkUI-X 生成的 Android / iOS 跨平台壳工程。
- `deliverables/`：项目交付物，例如页面草图图片等。
- `tools/`：辅助脚本。

## Git 提交约定

- Word 文档（`*.docx`）只作为本地资料保存，不提交到 GitHub。
- `oh_modules/`、`.hvigor/`、`.idea/`、`local.properties` 等本机依赖、缓存和 IDE 配置不提交。
- `.codex/`、`.agents/`、临时 skills 目录等 AI 工具配置不提交。
- 阶段性功能稳定后，再统一提交并推送到 GitHub。
