import 'dart:convert';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImageCompressTool extends StatefulWidget {
  const ImageCompressTool({super.key});

  @override
  State<ImageCompressTool> createState() => _ImageCompressToolState();
}

class _ImageCompressToolState extends State<ImageCompressTool> {
  final TextEditingController _base64Input = TextEditingController();
  Uint8List? _originalBytes;
  Uint8List? _compressedBytes;
  double _quality = 80;
  double _maxWidth = 1024;
  int _originalSize = 0;
  int _compressedSize = 0;
  bool _isProcessing = false;

  @override
  void dispose() {
    _base64Input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Compression'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputCard(),
            const SizedBox(height: 16),
            _buildControlsCard(),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _isProcessing ? null : _compress,
              icon: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.compress),
              label: Text(_isProcessing ? 'Compressing...' : 'Compress Image'),
            ),
            if (_originalBytes != null) ...[
              const SizedBox(height: 16),
              _buildComparisonCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Image Input',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _loadSample,
                  icon: const Icon(Icons.image, size: 18),
                  label: const Text('Sample'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _base64Input,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Paste Base64 image data or data URL...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Supports: Base64 string, Data URL (data:image/...), or use sample',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Compression Settings',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.high_quality_outlined, size: 20),
                const SizedBox(width: 8),
                Text('Quality: ${_quality.toInt()}%'),
                Expanded(
                  child: Slider(
                    value: _quality,
                    min: 1,
                    max: 100,
                    divisions: 99,
                    onChanged: (value) => setState(() => _quality = value),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.width_normal, size: 20),
                const SizedBox(width: 8),
                Text('Max Width: ${_maxWidth.toInt()}px'),
                Expanded(
                  child: Slider(
                    value: _maxWidth,
                    min: 64,
                    max: 4096,
                    divisions: 63,
                    onChanged: (value) => setState(() => _maxWidth = value),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonCard() {
    final savings = _originalSize > 0
        ? ((_originalSize - _compressedSize) / _originalSize * 100).toStringAsFixed(1)
        : '0';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Result',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildImagePreview(
                    'Original',
                    _originalBytes,
                    _originalSize,
                    Colors.grey,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.arrow_forward,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildImagePreview(
                    'Compressed',
                    _compressedBytes,
                    _compressedSize,
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat('Original', _formatSize(_originalSize)),
                  _buildStat('Compressed', _formatSize(_compressedSize)),
                  _buildStat('Savings', '$savings%'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _copyCompressedBase64,
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Copy Base64'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(String label, Uint8List? bytes, int size, Color accentColor) {
    return Column(
      children: [
        Container(
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: accentColor.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: bytes != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    bytes,
                    fit: BoxFit.contain,
                  ),
                )
              : const Center(child: Icon(Icons.image_not_supported)),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(
          _formatSize(size),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }

  void _loadSample() {
    // Create a simple colored square as sample
    final samplePixels = Uint8List(256 * 256 * 4);
    for (var y = 0; y < 256; y++) {
      for (var x = 0; x < 256; x++) {
        final i = (y * 256 + x) * 4;
        samplePixels[i] = (x + y) % 256;     // R
        samplePixels[i + 1] = x % 256;       // G
        samplePixels[i + 2] = y % 256;       // B
        samplePixels[i + 3] = 255;           // A
      }
    }

    // Create a simple PNG-like structure (simplified BMP for demo)
    final bmp = _createBMP(samplePixels, 256, 256);
    _base64Input.text = base64Encode(bmp);
    setState(() {
      _originalBytes = bmp;
      _originalSize = bmp.length;
    });
  }

  Uint8List _createBMP(Uint8List pixels, int width, int height) {
    final rowSize = (width * 3 + 3) & ~3;
    final imageSize = rowSize * height;
    final fileSize = 54 + imageSize;

    final bmp = Uint8List(fileSize);
    final bd = ByteData.sublistView(bmp);

    // BMP Header
    bd.setUint8(0, 0x42); // 'B'
    bd.setUint8(1, 0x4D); // 'M'
    bd.setUint32(2, fileSize, Endian.little);
    bd.setUint32(6, 0, Endian.little);
    bd.setUint32(10, 54, Endian.little);

    // DIB Header
    bd.setUint32(14, 40, Endian.little);
    bd.setInt32(18, width, Endian.little);
    bd.setInt32(22, height, Endian.little);
    bd.setUint16(26, 1, Endian.little);
    bd.setUint16(28, 24, Endian.little);
    bd.setUint32(30, 0, Endian.little);
    bd.setUint32(34, imageSize, Endian.little);
    bd.setUint32(38, 2835, Endian.little);
    bd.setUint32(42, 2835, Endian.little);
    bd.setUint32(46, 0, Endian.little);
    bd.setUint32(50, 0, Endian.little);

    // Pixel data (BGR format, bottom-up)
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final srcIdx = ((height - 1 - y) * width + x) * 4;
        final dstIdx = 54 + y * rowSize + x * 3;
        if (dstIdx + 2 < fileSize) {
          bmp[dstIdx] = pixels[srcIdx + 2];     // B
          bmp[dstIdx + 1] = pixels[srcIdx + 1]; // G
          bmp[dstIdx + 2] = pixels[srcIdx];     // R
        }
      }
    }

    return bmp;
  }

  void _compress() {
    setState(() => _isProcessing = true);

    Future.delayed(const Duration(milliseconds: 100), () {
      try {
        String data = _base64Input.text.trim();
        if (data.isEmpty) {
          _showError('Please enter image data');
          setState(() => _isProcessing = false);
          return;
        }

        if (data.contains(',')) {
          data = data.split(',')[1];
        }

        final bytes = base64Decode(data);
        _originalBytes = bytes;
        _originalSize = bytes.length;

        // Simulate compression by reducing quality
        final quality = _quality / 100;
        final targetBytes = math.max(1, (bytes.length * quality).toInt());

        // Simple compression simulation - in real app, use proper image codec
        final compressed = _simulateCompression(bytes, targetBytes);

        setState(() {
          _compressedBytes = compressed;
          _compressedSize = compressed.length;
          _isProcessing = false;
        });
      } catch (e) {
        _showError('Compression failed: $e');
        setState(() => _isProcessing = false);
      }
    });
  }

  Uint8List _simulateCompression(Uint8List original, int targetSize) {
    if (original.length <= targetSize) return original;

    // Simple downsampling simulation
    final result = Uint8List(targetSize);
    final step = original.length / targetSize;

    for (var i = 0; i < targetSize; i++) {
      final srcIdx = (i * step).toInt().clamp(0, original.length - 1);
      result[i] = original[srcIdx];
    }

    return result;
  }

  void _copyCompressedBase64() {
    if (_compressedBytes != null) {
      final b64 = base64Encode(_compressedBytes!);
      Clipboard.setData(ClipboardData(text: b64));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compressed Base64 copied')),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
