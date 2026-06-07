# 🎬 Show — Recording Canvas

> Zero dependencies, single file. Paste images, drag text, overlay a camera, record to MP4. One HTML file or a native macOS app. No install, no build, no Electron.

Built for content creators who need a clean, distraction-free canvas for demos, tutorials, and short-form video.

[中文文档](#-show--录播画布-1)

### ✨ Features

| Category | Detail |
|----------|--------|
| 🎥 **Recording** | MP4 via WebCodecs + mp4-muxer, WebM fallback. Mouse cursor captured. |
| 📷 **Camera PiP** | Glass-border vignette overlay. Draggable, resizable, auto-start. Size persisted. |
| 📐 **Presets** | 抖音 9:16 · 小红书 3:4 · 视频号 6:7 · 横屏 16:9 · Free mode. Dropdown switch. |
| 🖼️ **Paste & Drag** | Cmd+V paste images/text. Drag & drop files. Smart sizing relative to canvas. |
| 🎨 **Backgrounds** | Solid colors, gradients, custom picker. Body sync — no black borders in recording. |
| ✋ **Draggable Toolbar** | Grab the toolbar background and move it anywhere. |
| ↩️ **Undo** | Cmd+Z restores deleted items. |
| 🖱️ **Cursor** | Mouse pointer visible in recordings. |

### 🚀 Quick Start

**Browser (dev):**
```bash
cd ~/ai/show && python3 -m http.server 8420
# Open http://localhost:8420
```

**Native macOS app (1.5s build):**
```bash
cd ~/ai/show/ShowObjC && bash build.sh && open Show.app
```

Outputs to `~/Desktop/Show.app`.

### 🏗 Architecture

```
index.html          # Full app — HTML / CSS / JS in one file (~2000 lines)
mp4-muxer.mjs       # MP4 muxer (local bundle, no CDN)
ShowObjC/
  main.m            # ObjC WKWebView wrapper (~170 lines)
  build.sh          # clang compile + codesign
  Info.plist        # Camera / mic permissions
  Show.app/         # Built output
```

- **Recording pipeline**: `getDisplayMedia` → `VideoEncoder` (H.264) / `AudioEncoder` (AAC) → `mp4-muxer` → MP4 blob → native save or download
- **Canvas items**: `.canvas-item` divs, drag, 8-point resize handles, z-index stacking
- **Camera**: `getUserMedia` → `<video>`, floating PiP, radial-gradient vignette

### ⌨️ Shortcuts

| Key | Action |
|-----|--------|
| `Cmd+V` | Paste image / text |
| `Delete / Backspace` | Delete selected item |
| `Cmd+Z` | Undo delete |
| `Esc` | Deselect |

### 📦 Tech Stack

- **Zero npm dependencies**, no node_modules
- Browser: HTML5 native APIs (WebCodecs / MediaRecorder / getDisplayMedia / Clipboard)
- Native: ObjC + clang + WKWebView (no Swift, no Electron)
- Build: `clang -fobjc-arc`, < 2 seconds

### 📄 License

Standard [MIT License](https://opensource.org/license/mit). Free to use, modify, distribute, and commercialize.

> Copyright (c) 2025 Maxon

---

# 🎬 Show — 录播画布

> 零依赖、单文件。粘贴图片、拖拽文字、叠加小镜头，直接录制 MP4。一个 HTML 文件搞定，也有原生 macOS 应用。

Show 是为内容创作者打造的录播工具：干净、无干扰的画布，适合做 demo、教程、短视频录制。

[↑ English](#-show--recording-canvas)

### ✨ 功能

| 分类 | 详情 |
|------|------|
| 🎥 **录制** | MP4（WebCodecs + mp4-muxer），WebM 回退。录制鼠标光标。 |
| 📷 **小镜头** | 玻璃边框羽化叠加。可拖拽、缩放、自动开启，尺寸跨会话记住。 |
| 📐 **预设比例** | 抖音 9:16 · 小红书 3:4 · 视频号 6:7 · 横屏 16:9 · 自适应。下拉切换。 |
| 🖼️ **粘贴拖拽** | Cmd+V 粘贴剪贴板图片/文字。拖拽文件到画布。智能缩放适配画布比例。 |
| 🎨 **背景** | 纯色、渐变、取色器。body 背景同步，录屏无黑边。 |
| ✋ **工具栏拖拽** | 拖工具栏空白区域，自由移动位置。 |
| ↩️ **撤销** | Cmd+Z 恢复删除的素材。 |
| 🖱️ **鼠标光标** | 录制时鼠标指针可见。 |

### 🚀 快速开始

**浏览器（开发调试）：**
```bash
cd ~/ai/show && python3 -m http.server 8420
# 打开 http://localhost:8420
```

**原生 macOS 应用（1.5 秒构建）：**
```bash
cd ~/ai/show/ShowObjC && bash build.sh && open Show.app
```

构建产物自动输出到桌面 `~/Desktop/Show.app`。

### 🏗 架构

```
index.html          # 全部应用 — HTML / CSS / JS 一个文件（~2000 行）
mp4-muxer.mjs       # MP4 混流器（本地 bundle，不走 CDN）
ShowObjC/
  main.m            # ObjC WKWebView 壳（~170 行）
  build.sh          # clang 编译 + 签名
  Info.plist        # 摄像头 / 麦克风权限
  Show.app/         # 构建产物
```

- **录制管线**：`getDisplayMedia` → `VideoEncoder` (H.264) / `AudioEncoder` (AAC) → `mp4-muxer` → MP4 blob → 原生保存或浏览器下载
- **画布素材**：`.canvas-item` div，支持拖拽、8 点缩放、z-index 层叠
- **摄像头**：`getUserMedia` → `<video>`，浮动小镜头，径向渐变羽化

### ⌨️ 快捷键

| 按键 | 操作 |
|------|------|
| `Cmd+V` | 粘贴图片 / 文字 |
| `Delete / Backspace` | 删除选中素材 |
| `Cmd+Z` | 撤销删除 |
| `Esc` | 取消选中 |

### 📦 技术栈

- **零 npm 依赖**，无 node_modules
- 浏览器：HTML5 原生 API（WebCodecs / MediaRecorder / getDisplayMedia / Clipboard）
- 原生：ObjC + clang + WKWebView（不用 Swift，不用 Electron）
- 构建：`clang -fobjc-arc`，< 2 秒

### 📄 开源协议

标准 [MIT 开源协议](https://opensource.org/license/mit)。自由使用、修改、分发、商用，保留版权声明即可。

> Copyright (c) 2025 Maxon
