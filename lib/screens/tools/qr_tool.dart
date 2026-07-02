import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QrTool extends StatefulWidget {
  const QrTool({super.key});

  @override
  State<QrTool> createState() => _QrToolState();
}

class _QrToolState extends State<QrTool> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _scanResultController = TextEditingController();
  bool _generateErrorCorrection = true;
  int _qrSize = 200;
  List<List<bool>>? _qrMatrix;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _textController.addListener(() {
      if (_textController.text.isNotEmpty) {
        _generateQr();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    _scanResultController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Tool'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.qr_code), text: 'Generate'),
            Tab(icon: Icon(Icons.qr_code_scanner), text: 'Decode'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGenerateTab(),
          _buildDecodeTab(),
        ],
      ),
    );
  }

  Widget _buildGenerateTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Text / URL',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _textController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Enter text, URL, or any data...',
                      border: const OutlineInputBorder(),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: _pasteText,
                            icon: const Icon(Icons.content_paste, size: 20),
                          ),
                          IconButton(
                            onPressed: () => _textController.clear(),
                            icon: const Icon(Icons.clear, size: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(
                avatar: const Icon(Icons.wifi, size: 16),
                label: const Text('WiFi'),
                onPressed: () => _textController.text = 'WIFI:S:MyNetwork;T:WPA;P:password;;',
              ),
              ActionChip(
                avatar: const Icon(Icons.contact_phone, size: 16),
                label: const Text('vCard'),
                onPressed: () => _textController.text = 'BEGIN:VCARD\nVERSION:3.0\nFN:John Doe\nTEL:+1234567890\nEMAIL:john@example.com\nEND:VCARD',
              ),
              ActionChip(
                avatar: const Icon(Icons.web, size: 16),
                label: const Text('URL'),
                onPressed: () => _textController.text = 'https://github.com',
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_qrMatrix != null) _buildQrDisplay(),
        ],
      ),
    );
  }

  Widget _buildQrDisplay() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'QR Code',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: CustomPaint(
                  size: Size(_qrSize.toDouble(), _qrSize.toDouble()),
                  painter: QrPainter(_qrMatrix!),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: _copyQrData,
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Copy Data'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecodeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.qr_code_scanner, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'QR Code Decoder',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Paste QR code data or scan result to decode',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'QR Data',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _scanResultController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Paste decoded QR data...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This will parse WiFi configs, vCards, URLs, etc.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _decodeQrData,
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Parse Content'),
          ),
          const SizedBox(height: 16),
          _buildParsedResult(),
        ],
      ),
    );
  }

  Widget _buildParsedResult() {
    final data = _scanResultController.text;
    if (data.isEmpty) return const SizedBox.shrink();

    String title = 'Raw Data';
    List<Widget> details = [];

    if (data.startsWith('WIFI:')) {
      title = 'WiFi Configuration';
      final ssid = _extractWifiValue(data, 'S');
      final password = _extractWifiValue(data, 'P');
      final type = _extractWifiValue(data, 'T');
      details = [
        _buildDetailRow('Network (SSID)', ssid),
        _buildDetailRow('Password', password, isPassword: true),
        _buildDetailRow('Security', type),
      ];
    } else if (data.startsWith('BEGIN:VCARD')) {
      title = 'Contact Card (vCard)';
      final name = _extractVcardValue(data, 'FN');
      final tel = _extractVcardValue(data, 'TEL');
      final email = _extractVcardValue(data, 'EMAIL');
      details = [
        _buildDetailRow('Name', name),
        _buildDetailRow('Phone', tel),
        _buildDetailRow('Email', email),
      ];
    } else if (data.startsWith('http://') || data.startsWith('https://')) {
      title = 'URL';
      details = [
        _buildDetailRow('Link', data),
      ];
    } else {
      details = [
        _buildDetailRow('Content', data),
      ];
    }

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(),
            ...details,
            if (data.startsWith('http://') || data.startsWith('https://'))
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('Open Link'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              isPassword ? '••••••••' : value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label copied')),
              );
            },
          ),
        ],
      ),
    );
  }

  String _extractWifiValue(String data, String key) {
    final regex = RegExp('$key:([^;]*)');
    final match = regex.firstMatch(data);
    return match?.group(1) ?? '';
  }

  String _extractVcardValue(String data, String key) {
    final regex = RegExp('$key[:;]([^\\n]*)', caseSensitive: false);
    final match = regex.firstMatch(data);
    return match?.group(1) ?? '';
  }

  void _generateQr() {
    final text = _textController.text;
    if (text.isEmpty) {
      setState(() => _qrMatrix = null);
      return;
    }

    // Generate a simulated QR matrix
    final size = _calculateQrSize(text);
    final matrix = _generateSimulatedQr(text, size);

    setState(() {
      _qrMatrix = matrix;
    });
  }

  int _calculateQrSize(String text) {
    final length = text.length;
    if (length < 25) return 21;
    if (length < 50) return 25;
    if (length < 100) return 29;
    if (length < 200) return 33;
    return 37;
  }

  List<List<bool>> _generateSimulatedQr(String text, int size) {
    final random = math.Random(text.hashCode);
    final matrix = List.generate(size, (_) => List.generate(size, (_) => false));

    // Position detection patterns (corners)
    _drawPositionPattern(matrix, 0, 0);
    _drawPositionPattern(matrix, 0, size - 7);
    _drawPositionPattern(matrix, size - 7, 0);

    // Timing patterns
    for (var i = 8; i < size - 8; i++) {
      matrix[6][i] = i % 2 == 0;
      matrix[i][6] = i % 2 == 0;
    }

    // Fill data area with pseudo-random pattern based on text
    for (var row = 0; row < size; row++) {
      for (var col = 0; col < size; col++) {
        if (!matrix[row][col]) {
          // Skip function patterns
          if ((row < 9 && col < 9) ||
              (row < 9 && col >= size - 8) ||
              (row >= size - 8 && col < 9) ||
              row == 6 || col == 6) {
            continue;
          }
          matrix[row][col] = random.nextBool();
        }
      }
    }

    return matrix;
  }

  void _drawPositionPattern(List<List<bool>> matrix, int row, int col) {
    final size = matrix.length;
    for (var r = row; r < math.min(row + 7, size); r++) {
      for (var c = col; c < math.min(col + 7, size); c++) {
        final dr = r - row;
        final dc = c - col;
        // Outer square
        if (dr == 0 || dr == 6 || dc == 0 || dc == 6) {
          matrix[r][c] = true;
        }
        // Inner square
        else if (dr >= 2 && dr <= 4 && dc >= 2 && dc <= 4) {
          matrix[r][c] = true;
        }
      }
    }
  }

  void _pasteText() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      _textController.text = data!.text!;
    }
  }

  void _copyQrData() {
    final text = _textController.text;
    if (text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR data copied')),
      );
    }
  }

  void _decodeQrData() {
    setState(() {});
  }
}

class QrPainter extends CustomPainter {
  final List<List<bool>> matrix;

  QrPainter(this.matrix);

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / matrix.length;
    final paint = Paint()..color = Colors.black;

    for (var row = 0; row < matrix.length; row++) {
      for (var col = 0; col < matrix[row].length; col++) {
        if (matrix[row][col]) {
          canvas.drawRect(
            Rect.fromLTWH(
              col * cellSize,
              row * cellSize,
              cellSize - 0.5,
              cellSize - 0.5,
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
