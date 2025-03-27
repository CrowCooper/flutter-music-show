import 'dart:async';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewService {
  WebViewController? _controller;
  final StreamController<void> _osmdInitializedController = StreamController<void>.broadcast();
  final StreamController<void> _musicXmlLoadedController = StreamController<void>.broadcast();
  
  Stream<void> get osmdInitializedStream => _osmdInitializedController.stream;
  Stream<void> get musicXmlLoadedStream => _musicXmlLoadedController.stream;
  
  Future<WebViewController> initWebView() async {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            print('WebView页面加载完成');
            _osmdInitializedController.add(null);
          },
        ),
      );
    
    // 加载本地HTML文件
    final htmlContent = await rootBundle.loadString('assets/html/osmd_viewer.html');
    await controller.loadHtmlString(htmlContent);
    
    _controller = controller;
    return controller;
  }
  
  Future<void> loadMusicXML(String content) async {
    if (_controller == null) {
      print('WebView未初始化');
      return;
    }
    
    try {
      // 使用JavaScript加载MusicXML内容
      await _controller!.runJavaScript('loadMusicXML(`$content`);');
      _musicXmlLoadedController.add(null);
    } catch (e) {
      print('加载MusicXML时出错: $e');
    }
  }
  
  Future<void> updateCursorPosition(int timestamp) async {
    if (_controller == null) return;
    
    try {
      await _controller!.runJavaScript('updateCursorPosition($timestamp);');
    } catch (e) {
      print('更新光标位置时出错: $e');
    }
  }
  
  void dispose() {
    _osmdInitializedController.close();
    _musicXmlLoadedController.close();
  }
}
