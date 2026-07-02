import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Base64Tool extends StatefulWidget {
  const Base64Tool({super.key});

  @override
  State<Base64Tool> createState() => _Base64ToolState();
}

class _Base64ToolState extends State<Base64Tool> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  bool _isUrlSafe = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Base64 Tool'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.arrow_forward), text: 'Encode'),
            Tab(icon: Icon(Icons.arrow_back), text: 'Decode'),
            Tab(icon: Icon(Icons.image_outlined), text: 'Image'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEncodeTab(),
          _buildDecodeTab(),
          _buildImageTab(),
        ],
      ),
    );
  }

  Widget _buildEncodeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildOptionsCard(),
          const SizedBox(height: 16),
          _buildInputCard('Text to Encode'),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _encode,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Encode to Base64'),
          ),
          const SizedBox(height: 16),
          _buildOutputCard(),
        ],
      ),
    );
  }

  Widget _buildDecodeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildOptionsCard(),
          const SizedBox(height: 16),
          _buildInputCard('Base64 to Decode'),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _decode,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Decode from Base64'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 16),
          _buildOutputCard(),
        ],
      ),
    );
  }

  Widget _buildImageTab() {
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
                  const Icon(Icons.image_outlined, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    'Base64 Image Viewer',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Paste a Base64-encoded image to preview it',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildInputCard('Base64 Image Data'),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _previewImage,
            icon: const Icon(Icons.preview),
            label: const Text('Preview Image'),
          ),
          const SizedBox(height: 16),
          _buildImagePreview(),
        ],
      ),
    );
  }

  Widget _buildOptionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Text(
              'Options',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const Spacer(),
            FilterChip(
              selected: _isUrlSafe,
              onSelected: (value) => setState(() => _isUrlSafe = value),
              label: const Text('URL Safe'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard(String hint) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Input',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _inputController.clear(),
                  icon: const Icon(Icons.clear, size: 18),
                ),
                IconButton(
                  onPressed: _pasteInput,
                  icon: const Icon(Icons.content_paste, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _inputController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: hint,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutputCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Output',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                IconButton(
                  onPressed: _outputController.text.isEmpty ? null : _copyOutput,
                  icon: const Icon(Icons.copy, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _outputController,
              maxLines: 8,
              readOnly: true,
              decoration: const InputDecoration(
                hintText: 'Result will appear here...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _imagePreview;

  Widget _buildImagePreview() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _imagePreview ?? const SizedBox.shrink(),
    );
  }

  void _encode() {
    try {
      final input = _inputController.text;
      if (input.isEmpty) {
        _showError('Please enter text to encode');
        return;
      }

      String encoded;
      if (_isUrlSafe) {
        encoded = base64UrlEncode(utf8.encode(input));
      } else {
        encoded = base64Encode(utf8.encode(input));
      }

      _outputController.text = encoded;
    } catch (e) {
      _showError('Encoding failed: $e');
    }
  }

  void _decode() {
    try {
      final input = _inputController.text.replaceAll('\n', '').trim();
      if (input.isEmpty) {
        _showError('Please enter Base64 to decode');
        return;
      }

      String decoded;
      if (_isUrlSafe) {
        decoded = utf8.decode(base64Url.decode(input));
      } else {
        decoded = utf8.decode(base64Decode(input));
      }

      _outputController.text = decoded;
    } catch (e) {
      _showError('Decoding failed: $e');
    }
  }

  void _previewImage() {
    try {
      final input = _inputController.text.replaceAll('\n', '').trim();
      if (input.isEmpty) {
        _showError('Please enter Base64 image data');
        return;
      }

      String data = input;
      if (data.contains(',')) {
        data = data.split(',')[1];
      }

      final bytes = base64Decode(data);
      setState(() {
        _imagePreview = Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Image.memory(
                bytes,
                fit: BoxFit.contain,
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(bytes.length / 1024).toStringAsFixed(1)} KB',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${bytes.length} bytes',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      });
    } catch (e) {
      _showError('Invalid image data: $e');
    }
  }

  void _pasteInput() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      _inputController.text = data.text!;
    }
  }

  void _copyOutput() {
    Clipboard.setData(ClipboardData(text: _outputController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
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
