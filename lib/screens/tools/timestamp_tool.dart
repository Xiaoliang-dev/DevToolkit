import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class TimestampTool extends StatefulWidget {
  const TimestampTool({super.key});

  @override
  State<TimestampTool> createState() => _TimestampToolState();
}

class _TimestampToolState extends State<TimestampTool> {
  final TextEditingController _timestampController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  bool _isMilliseconds = true;
  DateTime? _convertedDate;
  String _formattedOutput = '';

  @override
  void initState() {
    super.initState();
    _setCurrent();
  }

  @override
  void dispose() {
    _timestampController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timestamp Converter'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCurrentTimeCard(),
            const SizedBox(height: 16),
            _buildTimestampToDate(),
            const SizedBox(height: 16),
            _buildDateToTimestamp(),
            const SizedBox(height: 16),
            if (_formattedOutput.isNotEmpty) _buildFormattedOutput(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTimeCard() {
    final now = DateTime.now();
    final ms = now.millisecondsSinceEpoch;
    final s = now.millisecondsSinceEpoch ~/ 1000;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.access_time, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Current Time',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  onPressed: _setCurrent,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const Divider(),
            _buildTimeRow('Milliseconds:', ms.toString()),
            const SizedBox(height: 8),
            _buildTimeRow('Seconds:', s.toString()),
            const SizedBox(height: 8),
            _buildTimeRow('ISO 8601:', now.toIso8601String()),
            const SizedBox(height: 8),
            _buildTimeRow('Local:', DateFormat('yyyy-MM-dd HH:mm:ss').format(now)),
            const SizedBox(height: 8),
            _buildTimeRow('UTC:', DateFormat('yyyy-MM-dd HH:mm:ss').format(now.toUtc())),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRow(String label, String value) {
    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: value));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label copied')),
        );
      },
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Icon(Icons.copy, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildTimestampToDate() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Timestamp → Date',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _timestampController,
                    decoration: const InputDecoration(
                      hintText: 'Enter timestamp',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('ms')),
                    ButtonSegment(value: false, label: Text('s')),
                  ],
                  selected: {_isMilliseconds},
                  onSelectionChanged: (set) {
                    setState(() => _isMilliseconds = set.first);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _convertTimestamp,
              icon: const Icon(Icons.calendar_today),
              label: const Text('Convert'),
            ),
            if (_convertedDate != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDateRow('Local', _convertedDate!),
                    _buildDateRow('UTC', _convertedDate!.toUtc()),
                    _buildDateRow('ISO 8601', _convertedDate!, iso: true),
                    _buildDateRow('Relative', _convertedDate!, relative: true),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateRow(String label, DateTime date, {bool iso = false, bool relative = false}) {
    String value;
    if (iso) {
      value = date.toIso8601String();
    } else if (relative) {
      value = _getRelativeTime(date);
    } else {
      value = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(date);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () {
          Clipboard.setData(ClipboardData(text: value));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$label copied')),
          );
        },
        child: Row(
          children: [
            Text(
              '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
            const Icon(Icons.copy, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildDateToTimestamp() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date → Timestamp',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      hintText: 'YYYY-MM-DD HH:mm:ss',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _pickDateTime,
                  icon: const Icon(Icons.calendar_month),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _convertDate,
              icon: const Icon(Icons.schedule),
              label: const Text('Convert'),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormattedOutput() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Common Formats',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(_formattedOutput),
          ],
        ),
      ),
    );
  }

  void _setCurrent() {
    final now = DateTime.now();
    _timestampController.text = now.millisecondsSinceEpoch.toString();
    _dateController.text = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    setState(() {});
  }

  void _convertTimestamp() {
    try {
      final ts = int.parse(_timestampController.text.trim());
      final date = DateTime.fromMillisecondsSinceEpoch(
        _isMilliseconds ? ts : ts * 1000,
      );
      setState(() {
        _convertedDate = date;
        _formattedOutput = _generateFormats(date);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid timestamp: $e')),
      );
    }
  }

  void _convertDate() {
    try {
      final input = _dateController.text.trim();
      DateTime date;

      // Try multiple formats
      final formats = [
        DateFormat('yyyy-MM-dd HH:mm:ss'),
        DateFormat('yyyy-MM-dd'),
        DateFormat('yyyy/MM/dd HH:mm:ss'),
        DateFormat('dd-MM-yyyy HH:mm:ss'),
        DateFormat('MM-dd-yyyy HH:mm:ss'),
      ];

      var parsed = false;
      for (final fmt in formats) {
        try {
          date = fmt.parse(input);
          parsed = true;
          setState(() {
            _timestampController.text = date.millisecondsSinceEpoch.toString();
            _convertedDate = date;
            _formattedOutput = _generateFormats(date);
          });
          break;
        } catch (_) {
          continue;
        }
      }

      if (!parsed) {
        throw const FormatException('Unrecognized date format');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid date: $e')),
      );
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    if (!context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;
    if (!context.mounted) return;

    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    _dateController.text = DateFormat('yyyy-MM-dd HH:mm:ss').format(dt);
  }

  String _generateFormats(DateTime date) {
    final formats = {
      'RFC 2822': DateFormat('EEE, dd MMM yyyy HH:mm:ss Z').format(date),
      'RFC 3339': date.toIso8601String(),
      'HTTP Header': DateFormat('EEE, dd MMM yyyy HH:mm:ss \'GMT\'').format(date.toUtc()),
      'SQL': DateFormat('yyyy-MM-dd HH:mm:ss').format(date),
      'Unix Seconds': (date.millisecondsSinceEpoch ~/ 1000).toString(),
      'Unix Milliseconds': date.millisecondsSinceEpoch.toString(),
    };

    return formats.entries.map((e) => '${e.key}: ${e.value}').join('\n');
  }

  String _getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    if (diff.inDays < 365) return '${diff.inDays ~/ 30}mo ago';
    return '${diff.inDays ~/ 365}y ago';
  }
}
