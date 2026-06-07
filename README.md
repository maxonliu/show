# 🎬 Show — Recording Canvas · 录播画布

[English](#english) | [中文](#中文)

---

## English

**Show** is a zero-dependency, single-file recording canvas. Paste images, drag text, frame yourself with a camera overlay, and record directly to MP4 — all from one HTML file or a native macOS app. No install, no build, no Electron.

Built for content creators who need a clean, distraction-free canvas for demos, tutorials, and short-form video.

### ✨ Features

| Category | Detail |
|----------|--------|
| 🎥 **Recording** | MP4 via WebCodecs + mp4-muxer (Chrome), WebM fallback (Safari/WKWebView). Mouse cursor captured. |
| 📷 **Camera PiP** | Glass-border vignette overlay. Draggable, resizable, auto-start. Size remembered across sessions. |
| 📐 **Presets** | 抖音 9:16 · 小红书 3:4 · 视频号 6:7 · 横屏 16:9 · Free mode. One-click switch. |
| 🖼️ **Paste & Drag** | Cmd+V paste images/text from clipboard. Drag & drop files. Smart sizing relative to canvas. |
| 🎨 **Backgrounds** | Solid colors, gradients, custom color picker. Body sync so recording has no black borders. |
| ✋ **Drag Toolbar** | Grab the toolbar background and move it anywhere. |
| ↩️ **Undo** | Cmd+Z to restore deleted items. |

### 🚀 Quick Start

**Browser (instant):**
```bash
cd ~/ai/show && python3 -m http.server 8420
# Open http://localhost:8420
```

**Native macOS app (1.5s build):**
```bash
cd ~/ai/show/ShowObjC && bash build.sh && open Show.app
```

Zero dependencies. Single `index.html`. Native `.app` compiles ObjC + WKWebView with `clang` in under 2 seconds.

### 🏗 Architecture

```
index.html          # The entire app — HTML, CSS, JS in one file
mp4-muxer.mjs       # MP4 muxer (local bundle, no CDN)
ShowObjC/
  main.m            # ObjC WKWebView wrapper (170 lines)
  build.sh          # clang build + codesign
  Info.plist        # Camera/mic permissions
  Show.app/         # Built output
```

- **Recording**: `getDisplayMedia` → `VideoEncoder` (H.264) / `AudioEncoder` (AAC) → `mp4-muxer` → MP4 blob → native save or download
- **Items**: `.canvas-item` divs with drag, 8-point resize handles, z-index stacking
- **Camera**: `getUserMedia` → `<video>` in a floating `#camera-pip` div with radial-gradient vignette

### ⌨️ Shortcuts

| Key | Action |
|-----|--------|
| `Cmd+V` | Paste image / text |
| `Delete / Backspace` | Delete selected item |
| `Cmd+Z` | Undo delete |
| `Esc` | Deselect |

### 📦 Tech Stack

- **Zero npm dependencies.** No node_modules.
- **Browser**: HTML5 APIs (WebCodecs, MediaRecorder, getDisplayMedia, Clipboard)
- **Native**: ObjC + clang + WKWebView (no Swift, no Electron)

---

## 中文

**Show** 是一个零依赖、单文件的录播画布。粘贴图片、拖拽文字、叠加小镜头，直接录制 MP4——一个 HTML 文件或原生 macOS 应用搞定。无需安装，无需构建，无 Electron。

为内容创作者打造：干净、无干扰的画布，适合做 demo、教程、短视频录制。

### ✨ 功能

| 分类 | 详情 |
|------|------|
| 🎥 **录制** | MP4（WebCodecs + mp4-muxer），WebM 回退。录制鼠标光标。 |
| 📷 **小镜头** | 玻璃边框羽化叠加。可拖拽、缩放、自动开启。尺寸跨会话记住。 |
| 📐 **预设比例** | 抖音 9:16 · 小红书 3:4 · 视频号 6:7 · 横屏 16:9 · 自适应。一键切换。 |
| 🖼️ **粘贴拖拽** | Cmd+V 粘贴剪贴板图片/文字。拖拽文件到画布。智能缩放适配画布大小。 |
| 🎨 **背景** | 纯色、渐变、取色器。body 背景同步，录屏无黑边。 |
| ✋ **工具栏拖拽** | 拖动工具栏空白区域，自由移动位置。 |
| ↩️ **撤销** | Cmd+Z 恢复删除的素材。 |

### 🚀 快速开始

**浏览器（即开即用）：**
```bash
cd ~/ai/show && python3 -m http.server 8420
# 打开 http://localhost:8420
```

**原生 macOS 应用（1.5 秒构建）：**
```bash
cd ~/ai/show/ShowObjC && bash build.sh && open Show.app
```

零依赖。单个 `index.html`。原生 `.app` 用 ObjC + WKWebView + clang 编译，不到 2 秒。

### 🏗 架构

```
index.html          # 全部应用 — HTML / CSS / JS 一个文件
mp4-muxer.mjs       # MP4 混流器（本地 bundle，不走 CDN）
ShowObjC/
  main.m            # ObjC WKWebView 壳（170 行）
  build.sh          # clang 编译 + 签名
  Info.plist        # 摄像头/麦克风权限
  Show.app/         # 构建产物
```

- **录制管线**：`getDisplayMedia` → `VideoEncoder` (H.264) / `AudioEncoder` (AAC) → `mp4-muxer` → MP4 blob → 原生保存或浏览器下载
- **画布素材**：`.canvas-item` div，支持拖拽、8 点缩放、z-index 层叠
- **小镜头**：`getUserMedia` → `<video>`，浮动 `#camera-pip` div，径向渐变羽化

### ⌨️ 快捷键

| 按键 | 操作 |
|------|------|
| `Cmd+V` | 粘贴图片 / 文字 |
| `Delete / Backspace` | 删除选中素材 |
| `Cmd+Z` | 撤销删除 |
| `Esc` | 取消选中 |

### 📦 技术栈

- **零 npm 依赖。** 无 node_modules。
- **浏览器**：HTML5 原生 API（WebCodecs / MediaRecorder / getDisplayMedia / Clipboard）
- **原生**：ObjC + clang + WKWebView（不用 Swift，不用 Electron）

---

MIT
