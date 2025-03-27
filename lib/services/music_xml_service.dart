import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;

class MusicXmlService {
  static const String _DEFAULT_XML = '''<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE score-partwise PUBLIC \"-//Recordare//DTD MusicXML 3.1 Partwise//EN\" \"http://www.musicxml.org/dtds/partwise.dtd\">
<score-partwise version=\"3.1\">
  <part-list>
    <score-part id=\"P1\">
      <part-name>Music</part-name>
    </score-part>
  </part-list>
  <part id=\"P1\">
    <measure number=\"1\">
      <attributes>
        <divisions>1</divisions>
        <key>
          <fifths>0</fifths>
        </key>
        <time>
          <beats>4</beats>
          <beat-type>4</beat-type>
        </time>
        <clef>
          <sign>G</sign>
          <line>2</line>
        </clef>
      </attributes>
      <note>
        <pitch>
          <step>C</step>
          <octave>4</octave>
        </pitch>
        <duration>4</duration>
        <type>whole</type>
      </note>
    </measure>
  </part>
</score-partwise>''';

  Future<String> loadMusicXmlFromAsset(String filePath) async {
    try {
      print('尝试加载音乐文件: $filePath');
      
      // 检查文件是否存在
      if (filePath.startsWith('/')) {
        // 绝对路径
        final file = File(filePath);
        if (await file.exists()) {
          print('从绝对路径加载: $filePath');
          final content = await file.readAsBytes();
          
          // 如果是MXL文件，需要解压缩
          if (filePath.toLowerCase().endsWith('.mxl')) {
            return await _extractMusicXmlFromMxl(content);
          }
          
          return String.fromCharCodes(content);
        }
      } else if (filePath.startsWith('assets/')) {
        // Flutter资源
        try {
          final data = await rootBundle.load(filePath);
          final bytes = data.buffer.asUint8List();
          
          // 如果是MXL文件，需要解压缩
          if (filePath.toLowerCase().endsWith('.mxl')) {
            return await _extractMusicXmlFromMxl(bytes);
          }
          
          return String.fromCharCodes(bytes);
        } catch (e) {
          print('从Flutter资源加载失败: $e');
        }
      } else {
        // 相对路径
        try {
          // 1. 尝试从应用文档目录加载
          final docDir = await getApplicationDocumentsDirectory();
          final docFile = File('${docDir.path}/$filePath');
          
          if (await docFile.exists()) {
            final content = await docFile.readAsBytes();
            
            // 如果是MXL文件，需要解压缩
            if (filePath.toLowerCase().endsWith('.mxl')) {
              return await _extractMusicXmlFromMxl(content);
            }
            
            return String.fromCharCodes(content);
          }
          
          // 2. 尝试从当前目录加载
          final currentFile = File(filePath);
          if (await currentFile.exists()) {
            final content = await currentFile.readAsBytes();
            
            // 如果是MXL文件，需要解压缩
            if (filePath.toLowerCase().endsWith('.mxl')) {
              return await _extractMusicXmlFromMxl(content);
            }
            
            return String.fromCharCodes(content);
          }
          
          // 3. 尝试从assets加载
          final assetPath = 'assets/examples/${path.basename(filePath)}';
          final data = await rootBundle.load(assetPath);
          final bytes = data.buffer.asUint8List();
          
          // 如果是MXL文件，需要解压缩
          if (filePath.toLowerCase().endsWith('.mxl')) {
            return await _extractMusicXmlFromMxl(bytes);
          }
          
          return String.fromCharCodes(bytes);
        } catch (e) {
          print('加载文件失败: $e');
        }
      }
      
      print('所有加载尝试失败，使用默认MusicXML');
      return _DEFAULT_XML;
    } catch (e) {
      print('加载MusicXML时出错: $e');
      return _DEFAULT_XML;
    }
  }
  
  Future<String> _extractMusicXmlFromMxl(List<int> bytes) async {
    try {
      // 解压缩MXL文件
      final archive = ZipDecoder().decodeBytes(bytes);
      
      // 查找container.xml文件
      final containerFile = archive.findFile('META-INF/container.xml');
      if (containerFile != null) {
        final containerContent = String.fromCharCodes(containerFile.content);
        
        // 解析container.xml以获取主MusicXML文件路径
        final rootfileMatch = RegExp(r'<rootfile.*?full-path=\"(.*?)\"').firstMatch(containerContent);
        if (rootfileMatch != null) {
          final mainFile = archive.findFile(rootfileMatch.group(1)!);
          if (mainFile != null) {
            return String.fromCharCodes(mainFile.content);
          }
        }
      }
      
      // 如果找不到container.xml，尝试直接查找.musicxml文件
      for (final file in archive.files) {
        if (file.name.toLowerCase().endsWith('.musicxml')) {
          return String.fromCharCodes(file.content);
        }
      }
      
      throw Exception('在MXL文件中找不到有效的MusicXML内容');
    } catch (e) {
      print('解压MXL文件时出错: $e');
      rethrow;
    }
  }
  
  Future<List<String>> listMusicXmlAssets() async {
    try {
      List<String> files = [];
      
      // 从应用文档目录获取文件
      final docDir = await getApplicationDocumentsDirectory();
      final docDirFiles = await Directory(docDir.path).list().toList();
      
      for (var entity in docDirFiles) {
        if (entity is File) {
          String ext = path.extension(entity.path).toLowerCase();
          if (['.xml', '.musicxml', '.mxl', '.mid', '.midi'].contains(ext)) {
            files.add(entity.path);
          }
        }
      }
      
      return files;
    } catch (e) {
      print('列出音乐文件时出错: $e');
      return [];
    }
  }
}
