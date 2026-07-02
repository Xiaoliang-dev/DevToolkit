import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../github_screen.dart';

class CodeViewerScreen extends StatefulWidget {
  final GitHubRepo repo;
  final String filePath;
  final String fileName;

  const CodeViewerScreen({
    super.key,
    required this.repo,
    required this.filePath,
    required this.fileName,
  });

  @override
  State<CodeViewerScreen> createState() => _CodeViewerScreenState();
}

class _CodeViewerScreenState extends State<CodeViewerScreen> {
  String _content = '';
  bool _isLoading = true;
  bool _showLineNumbers = true;
  double _fontSize = 14;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final sampleCode = _getSampleCode(widget.fileName);
    setState(() {
      _content = sampleCode;
      _isLoading = false;
    });
  }

  String _getSampleCode(String fileName) {
    if (fileName.endsWith('.dart')) {
      return _dartSample;
    } else if (fileName.endsWith('.yaml')) {
      return _yamlSample;
    } else if (fileName.endsWith('.md')) {
      return _mdSample;
    } else {
      return _genericSample;
    }
  }

  static const String _dartSample =
      "import 'package:flutter/material.dart';\n"
      "import 'package:flutter/services.dart';\n\n"
      "class DevToolkitApp extends StatelessWidget {\n"
      "  const DevToolkitApp({super.key});\n\n"
      "  @override\n"
      "  Widget build(BuildContext context) {\n"
      "    return MaterialApp(\n"
      "      title: 'DevToolkit',\n"
      "      debugShowCheckedModeBanner: false,\n"
      "      theme: ThemeData(\n"
      "        useMaterial3: true,\n"
      "        colorScheme: ColorScheme.fromSeed(\n"
      "          seedColor: const Color(0xFF6750A4),\n"
      "        ),\n"
      "      ),\n"
      "      home: const MainScreen(),\n"
      "    );\n"
      "  }\n"
      "}\n\n"
      "class MainScreen extends StatefulWidget {\n"
      "  const MainScreen({super.key});\n\n"
      "  @override\n"
      "  State<MainScreen> createState() => _MainScreenState();\n"
      "}\n\n"
      "class _MainScreenState extends State<MainScreen> {\n"
      "  int _currentIndex = 0;\n\n"
      "  @override\n"
      "  Widget build(BuildContext context) {\n"
      "    return Scaffold(\n"
      "      body: Center(\n"
      "        child: Text('Welcome to DevToolkit!'),\n"
      "      ),\n"
      "    );\n"
      "  }\n"
      "}";

  static const String _yamlSample =
      "name: devtoolkit\n"
      "description: All-in-one developer utility app\n\n"
      "version: 1.0.0+1\n\n"
      "environment:\n"
      "  sdk: ^3.5.0\n\n"
      "dependencies:\n"
      "  flutter:\n"
      "    sdk: flutter\n"
      "  crypto: ^3.0.6\n"
      "  encrypt: ^5.0.3\n"
      "  dio: ^5.8.0\n"
      "  url_launcher: ^6.3.1\n"
      "  shared_preferences: ^2.5.3\n"
      "  flutter_markdown: ^0.7.7\n"
      "  file_picker: ^10.1.2\n"
      "  path_provider: ^2.1.5\n\n"
      "dev_dependencies:\n"
      "  flutter_test:\n"
      "    sdk: flutter\n"
      "  flutter_lints: ^4.0.0\n\n"
      "flutter:\n"
      "  uses-material-design: true";

  static const String _mdSample =
      "# DevToolkit\n\n"
      "A comprehensive all-platform developer utility app built with Flutter.\n\n"
      "## Features\n\n"
      "- **Encryption & Decryption** - AES, RSA, MD5, SHA\n"
      "- **Base64 Tool** - Encode/Decode with URL-safe option\n"
      "- **Image Compression** - Compress and optimize images\n"
      "- **Network Tools** - Ping, Port Scanner, DNS Lookup\n"
      "- **JSON Formatter** - Format, validate, and minify JSON\n"
      "- **Timestamp Converter** - Convert between formats\n"
      "- **Color Tool** - Color picker and converter\n"
      "- **QR Code** - Generate QR codes\n"
      "- **GitHub Client** - Browse repos, view code, pull/push\n\n"
      "## Getting Started\n\n"
      "```bash\n"
      "flutter pub get\n"
      "flutter run\n"
      "```\n\n"
      "## License\n\n"
      "MIT License";

  static const String _genericSample =
      "// File viewer\n"
      "// Repository: demo\n\n"
      "// This is a sample file content for demonstration purposes.\n"
      "// In a real implementation, this would fetch the actual\n"
      "// file content from the GitHub API.\n\n"
      "// You can view, copy, and analyze code directly in this viewer.\n"
      "// Syntax highlighting is provided for common languages including:\n"
      "// - Dart, YAML, Markdown, JSON\n"
      "// - JavaScript/TypeScript, Python, Java\n"
      "// - And more...\n\n"
      "// Features:\n"
      "// - Line numbers toggle\n"
      "// - Font size adjustment\n"
      "// - Copy to clipboard\n"
      "// - Share code snippets";

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.fileName),
            Text(
              "${widget.repo.owner}/${widget.repo.name}",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _copyCode,
            tooltip: 'Copy',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareCode,
            tooltip: 'Share',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'toggle_lines':
                  setState(() => _showLineNumbers = !_showLineNumbers);
                  break;
                case 'increase_font':
                  setState(() => _fontSize = (_fontSize + 2).clamp(10, 32));
                  break;
                case 'decrease_font':
                  setState(() => _fontSize = (_fontSize - 2).clamp(10, 32));
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_lines',
                child: Row(
                  children: [
                    Icon(_showLineNumbers ? Icons.check_box : Icons.check_box_outline_blank),
                    const SizedBox(width: 8),
                    const Text('Line Numbers'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'increase_font',
                child: Row(
                  children: [
                    Icon(Icons.text_increase),
                    SizedBox(width: 8),
                    Text('Increase Font'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'decrease_font',
                child: Row(
                  children: [
                    Icon(Icons.text_decrease),
                    SizedBox(width: 8),
                    Text('Decrease Font'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildCodeView(isDark),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildCodeView(bool isDark) {
    final lines = _content.split('\n');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_showLineNumbers)
          Container(
            padding: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: lines.asMap().entries.map((entry) {
                return Text(
                  "${entry.key + 1}",
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: _fontSize,
                    color: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
                  ),
                );
              }).toList(),
            ),
          ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: lines.map((line) {
            return _buildHighlightedLine(line, isDark);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildHighlightedLine(String line, bool isDark) {
    final spans = _highlightLine(line, isDark);

    return RichText(
      text: TextSpan(
        children: spans,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: _fontSize,
          color: isDark ? const Color(0xFFD4D4D4) : const Color(0xFF333333),
        ),
      ),
    );
  }

  List<TextSpan> _highlightLine(String line, bool isDark) {
    final spans = <TextSpan>[];
    final patterns = _getSyntaxPatterns(isDark);

    var remaining = line;
    while (remaining.isNotEmpty) {
      TextSpan? bestMatch;
      var bestLength = 0;

      for (final pattern in patterns) {
        final match = pattern.regex.firstMatch(remaining);
        if (match != null && match.start == 0 && match.group(0)!.length > bestLength) {
          bestLength = match.group(0)!.length;
          bestMatch = TextSpan(
            text: match.group(0),
            style: TextStyle(color: pattern.color),
          );
        }
      }

      if (bestMatch != null) {
        spans.add(bestMatch);
        remaining = remaining.substring(bestLength);
      } else {
        spans.add(TextSpan(text: remaining[0]));
        remaining = remaining.substring(1);
      }
    }

    return spans;
  }

  List<HighlightPattern> _getSyntaxPatterns(bool isDark) {
    final keywords = [
      'import', 'class', 'extends', 'with', 'implements',
      'void', 'return', 'if', 'else', 'for', 'while',
      'final', 'const', 'var', 'static', 'await', 'async',
      'try', 'catch', 'throw', 'new', 'this', 'super',
      'true', 'false', 'null', 'break', 'continue',
      'int', 'String', 'double', 'bool', 'List', 'Map',
      'override', 'required', 'Widget', 'BuildContext',
      'StatelessWidget', 'StatefulWidget', 'setState',
      'build', 'initState', 'dispose', 'context',
    ];

    final keywordPattern = keywords.join('|');
    final stringPattern = "'(?:[^'\\\\]|\\\\.)*'";

    return [
      HighlightPattern(
        RegExp(r'//.*$'),
        isDark ? const Color(0xFF6A9955) : const Color(0xFF008000),
      ),
      HighlightPattern(
        RegExp(stringPattern),
        isDark ? const Color(0xFFCE9178) : const Color(0xFFA31515),
      ),
      HighlightPattern(
        RegExp(r'\b($keywordPattern)\b'),
        isDark ? const Color(0xFF569CD6) : const Color(0xFF0000FF),
      ),
      HighlightPattern(
        RegExp(r'\b\d+\.?\d*\b'),
        isDark ? const Color(0xFFB5CEA8) : const Color(0xFF098658),
      ),
      HighlightPattern(
        RegExp(r'\b\w+(?=\()'),
        isDark ? const Color(0xFFDCDCAA) : const Color(0xFF795E26),
      ),
      HighlightPattern(
        RegExp(r'@\w+'),
        isDark ? const Color(0xFF4EC9B0) : const Color(0xFF267F99),
      ),
    ];
  }

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: _content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Code copied to clipboard')),
    );
  }

  void _shareCode() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Shared: ${widget.fileName}')),
    );
  }
}

class HighlightPattern {
  final RegExp regex;
  final Color color;

  HighlightPattern(this.regex, this.color);
}
