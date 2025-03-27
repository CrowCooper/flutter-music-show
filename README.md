# Flutter 音乐乐谱播放器

一个基于 Flutter 的音乐乐谱播放器，支持 MusicXML、MXL 文件的渲染和 MP3 音频播放。

## 功能特点

- 支持 MusicXML 和 MXL 文件的渲染显示
- 支持 MP3 音频文件的播放
- 自动同步乐谱光标位置
- 支持音乐文件列表管理
- 美观的用户界面
- 支持播放控制（播放/暂停/上一首/下一首）
- 支持进度条拖动控制

## 技术栈

- Flutter
- WebView (用于渲染乐谱)
- OpenSheetMusicDisplay (乐谱渲染库)
- AudioPlayers (音频播放)

## 安装和运行

1. 确保已安装 Flutter 开发环境
2. 克隆项目：
   ```bash
   git clone https://github.com/CrowCooper/flutter-music-show.git
   ```
3. 进入项目目录：
   ```bash
   cd flutter-music-show
   ```
4. 安装依赖：
   ```bash
   flutter pub get
   ```
5. 运行项目：
   ```bash
   flutter run
   ```

## 使用说明

1. 点击右上角的音乐图标选择音乐文件
2. 使用底部控制栏控制音乐播放
3. 支持 MIDI 和 MusicXML 文件
4. 对于 MIDI 和 MXL 文件，会自动寻找对应的 MP3 音频
5. 可以通过刷新按钮更新音乐列表

## 目录结构

```
lib/
  ├── screens/           # 界面相关代码
  ├── services/          # 服务相关代码
  ├── assets/           
  │   ├── html/         # HTML 模板文件
  │   ├── js/           # JavaScript 文件
  │   ├── audios/       # 音频文件
  │   └── examples/     # 示例文件
  └── main.dart         # 入口文件
```

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT License