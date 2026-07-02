import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NetworkTool extends StatefulWidget {
  const NetworkTool({super.key});

  @override
  State<NetworkTool> createState() => _NetworkToolState();
}

class _NetworkToolState extends State<NetworkTool> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Tools'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.network_ping), text: 'Ping'),
            Tab(icon: Icon(Icons.scanner), text: 'Port Scan'),
            Tab(icon: Icon(Icons.dns_outlined), text: 'DNS Lookup'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          PingTab(),
          PortScanTab(),
          DnsLookupTab(),
        ],
      ),
    );
  }
}

class PingTab extends StatefulWidget {
  const PingTab({super.key});

  @override
  State<PingTab> createState() => _PingTabState();
}

class _PingTabState extends State<PingTab> {
  final TextEditingController _hostController = TextEditingController(text: 'google.com');
  final List<PingResult> _results = [];
  bool _isRunning = false;
  Timer? _timer;
  int _count = 0;
  final int _maxCount = 10;

  @override
  void dispose() {
    _hostController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _hostController,
                      decoration: const InputDecoration(
                        hintText: 'Enter hostname or IP',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.language),
                      ),
                      enabled: !_isRunning,
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _isRunning ? _stopPing : _startPing,
                    icon: Icon(_isRunning ? Icons.stop : Icons.play_arrow),
                    label: Text(_isRunning ? 'Stop' : 'Ping'),
                    style: FilledButton.styleFrom(
                      backgroundColor: _isRunning
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_results.isNotEmpty) _buildStats(),
          const SizedBox(height: 16),
          _buildResultsList(),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final times = _results.where((r) => r.success).map((r) => r.time).toList();
    final avg = times.isEmpty ? 0 : times.reduce((a, b) => a + b) / times.length;
    final min = times.isEmpty ? 0 : times.reduce(math.min);
    final max = times.isEmpty ? 0 : times.reduce(math.max);
    final lost = _results.where((r) => !r.success).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Avg', '${avg.toStringAsFixed(1)}ms'),
                _buildStat('Min', '${min.toStringAsFixed(1)}ms'),
                _buildStat('Max', '${max.toStringAsFixed(1)}ms'),
                _buildStat('Lost', '$lost/${_results.length}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildResultsList() {
    return Column(
      children: _results.asMap().entries.map((entry) {
        final i = entry.key;
        final r = entry.value;
        return Card(
          color: r.success
              ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
              : Theme.of(context).colorScheme.errorContainer.withOpacity(0.3),
          child: ListTile(
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: r.success
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.error,
              child: Icon(
                r.success ? Icons.check : Icons.close,
                size: 16,
                color: Colors.white,
              ),
            ),
            title: Text('Packet ${i + 1}'),
            subtitle: Text(r.message),
            trailing: Text(
              '${r.time.toStringAsFixed(1)}ms',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _startPing() {
    final host = _hostController.text.trim();
    if (host.isEmpty) return;

    setState(() {
      _isRunning = true;
      _results.clear();
      _count = 0;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_count >= _maxCount) {
        _stopPing();
        return;
      }

      final stopwatch = Stopwatch()..start();

      // Simulate ping - in real app, use raw sockets or platform channel
      Future.delayed(Duration(milliseconds: 20 + math.Random().nextInt(80)), () {
        stopwatch.stop();
        final success = math.Random().nextDouble() > 0.05; // 5% packet loss simulation

        setState(() {
          _results.add(PingResult(
            success: success,
            time: stopwatch.elapsedMicroseconds / 1000.0,
            message: success
                ? 'Reply from $host: bytes=32'
                : 'Request timed out',
          ));
          _count++;
        });
      });
    });
  }

  void _stopPing() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }
}

class PingResult {
  final bool success;
  final double time;
  final String message;

  PingResult({required this.success, required this.time, required this.message});
}

class PortScanTab extends StatefulWidget {
  const PortScanTab({super.key});

  @override
  State<PortScanTab> createState() => _PortScanTabState();
}

class _PortScanTabState extends State<PortScanTab> {
  final TextEditingController _hostController = TextEditingController(text: '127.0.0.1');
  final TextEditingController _startPortController = TextEditingController(text: '1');
  final TextEditingController _endPortController = TextEditingController(text: '100');
  final List<PortResult> _results = [];
  bool _isScanning = false;

  final List<int> _commonPorts = [21, 22, 23, 25, 53, 80, 110, 143, 443, 993, 995, 3306, 3389, 5432, 8080, 8443];

  @override
  void dispose() {
    _hostController.dispose();
    _startPortController.dispose();
    _endPortController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(
                    controller: _hostController,
                    decoration: const InputDecoration(
                      hintText: 'Hostname or IP',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.computer),
                    ),
                    enabled: !_isScanning,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _startPortController,
                          decoration: const InputDecoration(
                            hintText: 'Start Port',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          enabled: !_isScanning,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('—'),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _endPortController,
                          decoration: const InputDecoration(
                            hintText: 'End Port',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          enabled: !_isScanning,
                        ),
                      ),
                    ],
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
                avatar: const Icon(Icons.flash_on, size: 18),
                label: const Text('Quick Scan'),
                onPressed: _isScanning ? null : _quickScan,
              ),
              ActionChip(
                avatar: const Icon(Icons.list, size: 18),
                label: const Text('Common Ports'),
                onPressed: _isScanning ? null : _scanCommon,
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _isScanning ? null : _startScan,
            icon: _isScanning
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.radar),
            label: Text(_isScanning ? 'Scanning...' : 'Start Scan'),
          ),
          const SizedBox(height: 16),
          if (_results.isNotEmpty) _buildResults(),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final openPorts = _results.where((r) => r.isOpen).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Results: ${openPorts.length} open ports found',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        ..._results.where((r) => r.isOpen).map((r) => Card(
          color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
          child: ListTile(
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.check, size: 16, color: Colors.white),
            ),
            title: Text('Port ${r.port}'),
            subtitle: Text(r.service),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'OPEN',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        )),
      ],
    );
  }

  void _quickScan() {
    _startPortController.text = '1';
    _endPortController.text = '100';
  }

  void _scanCommon() {
    setState(() {
      _results.clear();
      for (final port in _commonPorts) {
        _results.add(PortResult(
          port: port,
          isOpen: math.Random().nextDouble() > 0.7,
          service: _getServiceName(port),
        ));
      }
    });
  }

  void _startScan() async {
    final host = _hostController.text.trim();
    final startPort = int.tryParse(_startPortController.text) ?? 1;
    final endPort = int.tryParse(_endPortController.text) ?? 100;

    if (host.isEmpty) return;

    setState(() {
      _isScanning = true;
      _results.clear();
    });

    for (var port = startPort; port <= endPort; port++) {
      if (!_isScanning) break;

      // Simulate port scanning
      await Future.delayed(const Duration(milliseconds: 50));
      final isOpen = _commonPorts.contains(port) && math.Random().nextDouble() > 0.5;

      setState(() {
        _results.add(PortResult(
          port: port,
          isOpen: isOpen,
          service: _getServiceName(port),
        ));
      });
    }

    setState(() => _isScanning = false);
  }

  String _getServiceName(int port) {
    final services = {
      21: 'FTP', 22: 'SSH', 23: 'Telnet', 25: 'SMTP',
      53: 'DNS', 80: 'HTTP', 110: 'POP3', 143: 'IMAP',
      443: 'HTTPS', 993: 'IMAPS', 995: 'POP3S',
      3306: 'MySQL', 3389: 'RDP', 5432: 'PostgreSQL',
      8080: 'HTTP-Proxy', 8443: 'HTTPS-Alt',
    };
    return services[port] ?? 'Unknown';
  }
}

class PortResult {
  final int port;
  final bool isOpen;
  final String service;

  PortResult({required this.port, required this.isOpen, required this.service});
}

class DnsLookupTab extends StatefulWidget {
  const DnsLookupTab({super.key});

  @override
  State<DnsLookupTab> createState() => _DnsLookupTabState();
}

class _DnsLookupTabState extends State<DnsLookupTab> {
  final TextEditingController _hostController = TextEditingController(text: 'google.com');
  final List<DnsRecord> _records = [];
  String _selectedType = 'A';
  bool _isLookingUp = false;

  final List<String> _recordTypes = ['A', 'AAAA', 'MX', 'NS', 'TXT', 'CNAME'];

  @override
  void dispose() {
    _hostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(
                    controller: _hostController,
                    decoration: const InputDecoration(
                      hintText: 'Enter domain name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.language),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: _recordTypes.map((type) {
                      return FilterChip(
                        selected: _selectedType == type,
                        onSelected: (_) => setState(() => _selectedType = type),
                        label: Text(type),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _isLookingUp ? null : _lookup,
            icon: _isLookingUp
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.search),
            label: Text(_isLookingUp ? 'Looking up...' : 'Lookup'),
          ),
          const SizedBox(height: 16),
          if (_records.isNotEmpty) _buildRecords(),
        ],
      ),
    );
  }

  Widget _buildRecords() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DNS Records',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        ..._records.map((r) => Card(
          child: ListTile(
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.tertiary,
              child: Text(
                r.type,
                style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(r.value),
            subtitle: r.ttl != null ? Text('TTL: ${r.ttl}') : null,
            trailing: IconButton(
              icon: const Icon(Icons.copy, size: 18),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: r.value));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied to clipboard')),
                );
              },
            ),
          ),
        )),
      ],
    );
  }

  void _lookup() async {
    final host = _hostController.text.trim();
    if (host.isEmpty) return;

    setState(() {
      _isLookingUp = true;
      _records.clear();
    });

    // Simulate DNS lookup
    await Future.delayed(const Duration(seconds: 1));

    final simulatedRecords = _simulateDnsRecords(host, _selectedType);

    setState(() {
      _records.addAll(simulatedRecords);
      _isLookingUp = false;
    });
  }

  List<DnsRecord> _simulateDnsRecords(String host, String type) {
    final random = math.Random(host.hashCode);
    switch (type) {
      case 'A':
        return [
          DnsRecord(type: 'A', value: '${random.nextInt(256)}.${random.nextInt(256)}.${random.nextInt(256)}.${random.nextInt(256)}', ttl: 300),
          DnsRecord(type: 'A', value: '${random.nextInt(256)}.${random.nextInt(256)}.${random.nextInt(256)}.${random.nextInt(256)}', ttl: 300),
        ];
      case 'AAAA':
        return [
          DnsRecord(type: 'AAAA', value: '2001:db8::${random.nextInt(9999)}', ttl: 300),
        ];
      case 'MX':
        return [
          DnsRecord(type: 'MX', value: '10 mail.$host', ttl: 3600),
          DnsRecord(type: 'MX', value: '20 mail2.$host', ttl: 3600),
        ];
      case 'NS':
        return [
          DnsRecord(type: 'NS', value: 'ns1.${host.split('.').last}.com', ttl: 86400),
          DnsRecord(type: 'NS', value: 'ns2.${host.split('.').last}.com', ttl: 86400),
        ];
      case 'TXT':
        return [
          DnsRecord(type: 'TXT', value: 'v=spf1 include:_spf.$host ~all', ttl: 3600),
        ];
      case 'CNAME':
        return [
          DnsRecord(type: 'CNAME', value: '$host.cdn.provider.net', ttl: 300),
        ];
      default:
        return [];
    }
  }
}

class DnsRecord {
  final String type;
  final String value;
  final int? ttl;

  DnsRecord({required this.type, required this.value, this.ttl});
}
