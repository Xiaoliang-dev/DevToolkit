import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart' as crypto;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CryptoTool extends StatefulWidget {
  const CryptoTool({super.key});

  @override
  State<CryptoTool> createState() => _CryptoToolState();
}

class _CryptoToolState extends State<CryptoTool> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  String _selectedAlgorithm = 'AES-256-CBC';
  String _selectedHash = 'SHA-256';
  bool _showKey = false;

  final List<String> _algorithms = [
    'AES-256-CBC',
    'AES-128-CBC',
    'AES-256-ECB',
  ];

  final List<String> _hashAlgorithms = [
    'SHA-256',
    'SHA-1',
    'MD5',
    'SHA-512',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _inputController.dispose();
    _keyController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Encryption & Decryption'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.lock_outline), text: 'Encrypt / Decrypt'),
            Tab(icon: Icon(Icons.fingerprint), text: 'Hash'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEncryptTab(),
          _buildHashTab(),
        ],
      ),
    );
  }

  Widget _buildEncryptTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildAlgorithmSelector(),
          const SizedBox(height: 16),
          _buildKeyField(),
          const SizedBox(height: 16),
          _buildInputField(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _encrypt,
                  icon: const Icon(Icons.lock_outline),
                  label: const Text('Encrypt'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _decrypt,
                  icon: const Icon(Icons.lock_open_outlined),
                  label: const Text('Decrypt'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildOutputField(),
        ],
      ),
    );
  }

  Widget _buildHashTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHashAlgorithmSelector(),
          const SizedBox(height: 16),
          _buildInputField(),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _hash,
            icon: const Icon(Icons.fingerprint),
            label: const Text('Generate Hash'),
          ),
          const SizedBox(height: 16),
          _buildOutputField(),
          const SizedBox(height: 16),
          _buildHmacSection(),
        ],
      ),
    );
  }

  Widget _buildAlgorithmSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Algorithm',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _algorithms.map((algo) {
                final isSelected = _selectedAlgorithm == algo;
                return FilterChip(
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedAlgorithm = algo),
                  label: Text(algo),
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHashAlgorithmSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hash Algorithm',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _hashAlgorithms.map((algo) {
                final isSelected = _selectedHash == algo;
                return FilterChip(
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedHash = algo),
                  label: Text(algo),
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyField() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Key',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _generateKey,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Generate'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _keyController,
              obscureText: !_showKey,
              decoration: InputDecoration(
                hintText: 'Enter or generate encryption key',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_showKey ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _showKey = !_showKey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField() {
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
                  onPressed: () => _pasteToInput(),
                  icon: const Icon(Icons.content_paste, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _inputController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Enter text to encrypt/decrypt/hash...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutputField() {
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
              maxLines: 6,
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

  Widget _buildHmacSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'HMAC',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'HMAC combines a secret key with a hash function. Use the key field above for HMAC generation.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _generateHmac,
              icon: const Icon(Icons.vpn_key_outlined),
              label: const Text('Generate HMAC'),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.tertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _generateKey() {
    final random = Random.secure();
    final bytes = Uint8List(32);
    for (var i = 0; i < bytes.length; i++) {
      bytes[i] = random.nextInt(256);
    }
    final key = base64Encode(bytes);
    _keyController.text = key;
    setState(() {});
  }

  void _encrypt() {
    try {
      final input = _inputController.text;
      final key = _keyController.text;

      if (input.isEmpty || key.isEmpty) {
        _showError('Please enter both input and key');
        return;
      }

      final keyBytes = base64Decode(key.padRight(32, '=').substring(0, 32));
      final keyObj = encrypt.Key(Uint8List.fromList(keyBytes));
      final iv = encrypt.IV.fromLength(16);

      encrypt.Encrypter? encrypter;
      if (_selectedAlgorithm.contains('AES-256-CBC')) {
        encrypter = encrypt.Encrypter(encrypt.AES(keyObj, mode: encrypt.AESMode.cbc));
      } else if (_selectedAlgorithm.contains('AES-128-CBC')) {
        encrypter = encrypt.Encrypter(encrypt.AES(keyObj, mode: encrypt.AESMode.cbc));
      } else if (_selectedAlgorithm.contains('AES-256-ECB')) {
        encrypter = encrypt.Encrypter(encrypt.AES(keyObj, mode: encrypt.AESMode.ecb));
      }

      if (encrypter != null) {
        final encrypted = encrypter.encrypt(input, iv: iv);
        _outputController.text = '${base64Encode(iv.bytes)}:${encrypted.base64}';
      }
    } catch (e) {
      _showError('Encryption failed: $e');
    }
  }

  void _decrypt() {
    try {
      final input = _inputController.text;
      final key = _keyController.text;

      if (input.isEmpty || key.isEmpty) {
        _showError('Please enter both input and key');
        return;
      }

      final parts = input.split(':');
      if (parts.length != 2) {
        _showError('Invalid encrypted format. Expected IV:ciphertext');
        return;
      }

      final iv = encrypt.IV.fromBase64(parts[0]);
      final keyBytes = base64Decode(key.padRight(32, '=').substring(0, 32));
      final keyObj = encrypt.Key(Uint8List.fromList(keyBytes));

      encrypt.Encrypter? encrypter;
      if (_selectedAlgorithm.contains('AES-256-CBC')) {
        encrypter = encrypt.Encrypter(encrypt.AES(keyObj, mode: encrypt.AESMode.cbc));
      } else if (_selectedAlgorithm.contains('AES-128-CBC')) {
        encrypter = encrypt.Encrypter(encrypt.AES(keyObj, mode: encrypt.AESMode.cbc));
      } else if (_selectedAlgorithm.contains('AES-256-ECB')) {
        encrypter = encrypt.Encrypter(encrypt.AES(keyObj, mode: encrypt.AESMode.ecb));
      }

      if (encrypter != null) {
        final decrypted = encrypter.decrypt64(parts[1], iv: iv);
        _outputController.text = decrypted;
      }
    } catch (e) {
      _showError('Decryption failed: $e');
    }
  }

  void _hash() {
    try {
      final input = _inputController.text;
      if (input.isEmpty) {
        _showError('Please enter input text');
        return;
      }

      final bytes = utf8.encode(input);
      String hash;

      switch (_selectedHash) {
        case 'SHA-256':
          hash = crypto.sha256.convert(bytes).toString();
          break;
        case 'SHA-1':
          hash = crypto.sha1.convert(bytes).toString();
          break;
        case 'MD5':
          hash = crypto.md5.convert(bytes).toString();
          break;
        case 'SHA-512':
          hash = crypto.sha512.convert(bytes).toString();
          break;
        default:
          hash = crypto.sha256.convert(bytes).toString();
      }

      _outputController.text = hash;
    } catch (e) {
      _showError('Hash generation failed: $e');
    }
  }

  void _generateHmac() {
    try {
      final input = _inputController.text;
      final key = _keyController.text;

      if (input.isEmpty || key.isEmpty) {
        _showError('Please enter both input and key');
        return;
      }

      final keyBytes = utf8.encode(key);
      final messageBytes = utf8.encode(input);

      String hmac;
      switch (_selectedHash) {
        case 'SHA-256':
          hmac = crypto.Hmac(crypto.sha256, keyBytes).convert(messageBytes).toString();
          break;
        case 'SHA-1':
          hmac = crypto.Hmac(crypto.sha1, keyBytes).convert(messageBytes).toString();
          break;
        case 'MD5':
          hmac = crypto.Hmac(crypto.md5, keyBytes).convert(messageBytes).toString();
          break;
        case 'SHA-512':
          hmac = crypto.Hmac(crypto.sha512, keyBytes).convert(messageBytes).toString();
          break;
        default:
          hmac = crypto.Hmac(crypto.sha256, keyBytes).convert(messageBytes).toString();
      }

      _outputController.text = 'HMAC-$_selectedHash: $hmac';
    } catch (e) {
      _showError('HMAC generation failed: $e');
    }
  }

  void _pasteToInput() async {
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
