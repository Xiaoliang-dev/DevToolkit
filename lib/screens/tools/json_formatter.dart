import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class JsonFormatter extends StatefulWidget {
  const JsonFormatter({super.key});

  @override
  State<JsonFormatter> createState() => _JsonFormatterState();
}

class _JsonFormatterState extends State<JsonFormatter> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  String? _errorMessage;
  bool _sortKeys = false;

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JSON Formatter'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputCard(),
            const SizedBox(height: 16),
            _buildActions(),
            const SizedBox(height: 16),
            _buildOutputCard(),
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
                  'Input JSON',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _loadSample,
                  icon: const Icon(Icons.auto_fix_high, size: 18),
                  label: const Text('Sample'),
                ),
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
              maxLines: 10,
              decoration: InputDecoration(
                hintText: 'Paste your JSON here...',
                border: const OutlineInputBorder(),
                errorText: _errorMessage,
              ),
              onChanged: (_) => setState(() => _errorMessage = null),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        FilledButton.icon(
          onPressed: _format,
          icon: const Icon(Icons.auto_awesome),
          label: const Text('Format'),
        ),
        FilledButton.icon(
          onPressed: _minify,
          icon: const Icon(Icons.compress),
          label: const Text('Minify'),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        ),
        FilterChip(
          selected: _sortKeys,
          onSelected: (v) => setState(() => _sortKeys = v),
          label: const Text('Sort Keys'),
        ),
        OutlinedButton.icon(
          onPressed: _validate,
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Validate'),
        ),
      ],
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
                  'Formatted Output',
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
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: TextField(
                controller: _outputController,
                maxLines: 15,
                readOnly: true,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: const InputDecoration(
                  hintText: 'Formatted JSON will appear here...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _format() {
    try {
      final input = _inputController.text.trim();
      if (input.isEmpty) {
        setState(() => _errorMessage = 'Please enter JSON');
        return;
      }

      final json = jsonDecode(input);
      final encoder = JsonEncoder.withIndent('  ', _sortKeys ? _sort : null);
      _outputController.text = encoder.convert(json);
      setState(() => _errorMessage = null);
    } catch (e) {
      setState(() => _errorMessage = 'Invalid JSON: $e');
    }
  }

  void _minify() {
    try {
      final input = _inputController.text.trim();
      if (input.isEmpty) {
        setState(() => _errorMessage = 'Please enter JSON');
        return;
      }

      final json = jsonDecode(input);
      _outputController.text = jsonEncode(json);
      setState(() => _errorMessage = null);
    } catch (e) {
      setState(() => _errorMessage = 'Invalid JSON: $e');
    }
  }

  void _validate() {
    try {
      final input = _inputController.text.trim();
      if (input.isEmpty) {
        setState(() => _errorMessage = 'Please enter JSON');
        return;
      }

      jsonDecode(input);
      setState(() => _errorMessage = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Valid JSON!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _errorMessage = 'Invalid JSON: $e');
    }
  }

  dynamic _sort(dynamic value) {
    if (value is Map) {
      final sorted = Map<String, dynamic>.from(value);
      final entries = sorted.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
      return Map<String, dynamic>.fromEntries(entries);
    }
    return value;
  }

  void _loadSample() {
    _inputController.text = '''{
  "name": "DevToolkit",
  "version": "1.0.0",
  "platforms": ["Android", "iOS", "Web", "Desktop"],
  "features": {
    "crypto": true,
    "network": true,
    "github": true
  },
  "author": {
    "name": "Developer",
    "email": "dev@example.com"
  }
}''';
  }

  void _pasteInput() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      _inputController.text = data!.text!;
    }
  }

  void _copyOutput() {
    Clipboard.setData(ClipboardData(text: _outputController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }
}
