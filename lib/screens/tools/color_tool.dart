import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ColorTool extends StatefulWidget {
  const ColorTool({super.key});

  @override
  State<ColorTool> createState() => _ColorToolState();
}

class _ColorToolState extends State<ColorTool> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  double _hue = 0.5;
  double _saturation = 0.8;
  double _value = 0.9;
  final TextEditingController _hexController = TextEditingController(text: '#6750A4');
  final TextEditingController _rgbController = TextEditingController();
  Color _currentColor = const Color(0xFF6750A4);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _updateFromColor(_currentColor);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _hexController.dispose();
    _rgbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Color Tools'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.colorize), text: 'Picker'),
            Tab(icon: Icon(Icons.palette_outlined), text: 'Converter'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPickerTab(),
          _buildConverterTab(),
        ],
      ),
    );
  }

  Widget _buildPickerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildColorPreview(),
          const SizedBox(height: 16),
          _buildHueSlider(),
          const SizedBox(height: 16),
          _buildSaturationSlider(),
          const SizedBox(height: 16),
          _buildValueSlider(),
          const SizedBox(height: 16),
          _buildColorValues(),
          const SizedBox(height: 16),
          _buildPalette(),
        ],
      ),
    );
  }

  Widget _buildConverterTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildColorPreview(),
          const SizedBox(height: 16),
          _buildHexInput(),
          const SizedBox(height: 16),
          _buildRgbInput(),
          const SizedBox(height: 16),
          _buildConversionTable(),
        ],
      ),
    );
  }

  Widget _buildColorPreview() {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_currentColor, _currentColor.withOpacity(0.7)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _colorToHex(_currentColor),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHueSlider() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hue: ${(_hue * 360).toStringAsFixed(0)}°'),
            const SizedBox(height: 8),
            Container(
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: const SweepGradient(
                  colors: [
                    Colors.red,
                    Colors.yellow,
                    Colors.green,
                    Colors.cyan,
                    Colors.blue,
                    Colors.purple,
                    Colors.red,
                  ],
                ),
              ),
            ),
            Slider(
              value: _hue,
              onChanged: (v) => setState(() {
                _hue = v;
                _updateColor();
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaturationSlider() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Saturation: ${(_saturation * 100).toStringAsFixed(0)}%'),
            const SizedBox(height: 8),
            Container(
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [
                    HSVColor.fromAHSV(1, _hue * 360, 0, _value).toColor(),
                    HSVColor.fromAHSV(1, _hue * 360, 1, _value).toColor(),
                  ],
                ),
              ),
            ),
            Slider(
              value: _saturation,
              onChanged: (v) => setState(() {
                _saturation = v;
                _updateColor();
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueSlider() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Value: ${(_value * 100).toStringAsFixed(0)}%'),
            const SizedBox(height: 8),
            Container(
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [
                    HSVColor.fromAHSV(1, _hue * 360, _saturation, 0).toColor(),
                    HSVColor.fromAHSV(1, _hue * 360, _saturation, 1).toColor(),
                  ],
                ),
              ),
            ),
            Slider(
              value: _value,
              onChanged: (v) => setState(() {
                _value = v;
                _updateColor();
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorValues() {
    final hsl = _rgbToHsl(
      _currentColor.red,
      _currentColor.green,
      _currentColor.blue,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildValueRow('HEX', _colorToHex(_currentColor)),
            _buildValueRow('RGB', '${_currentColor.red}, ${_currentColor.green}, ${_currentColor.blue}'),
            _buildValueRow('RGBA', '${_currentColor.red}, ${_currentColor.green}, ${_currentColor.blue}, ${_currentColor.alpha.toStringAsFixed(2)}'),
            _buildValueRow('HSL', '${hsl[0].toStringAsFixed(0)}, ${hsl[1].toStringAsFixed(0)}%, ${hsl[2].toStringAsFixed(0)}%'),
            _buildValueRow('HSV', '${(_hue * 360).toStringAsFixed(0)}, ${(_saturation * 100).toStringAsFixed(0)}%, ${(_value * 100).toStringAsFixed(0)}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildValueRow(String label, String value) {
    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: value));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label copied')),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            SizedBox(
              width: 60,
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
            const Icon(Icons.copy, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildPalette() {
    final baseHue = _hue * 360;
    final colors = [
      HSVColor.fromAHSV(1, baseHue, _saturation, _value).toColor(),
      HSVColor.fromAHSV(1, (baseHue + 30) % 360, _saturation, _value).toColor(),
      HSVColor.fromAHSV(1, (baseHue + 60) % 360, _saturation, _value).toColor(),
      HSVColor.fromAHSV(1, (baseHue + 120) % 360, _saturation, _value).toColor(),
      HSVColor.fromAHSV(1, (baseHue + 180) % 360, _saturation, _value).toColor(),
      HSVColor.fromAHSV(1, (baseHue + 240) % 360, _saturation, _value).toColor(),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Harmony Palette',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: colors.map((c) => Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _currentColor = c;
                      _updateFromColor(c);
                    });
                  },
                  child: Container(
                    height: 50,
                    color: c,
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHexInput() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'HEX Color',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _hexController,
                    decoration: const InputDecoration(
                      hintText: '#RRGGBB',
                      border: OutlineInputBorder(),
                      prefixText: '#',
                    ),
                    onChanged: (v) {
                      try {
                        final hex = v.replaceAll('#', '').trim();
                        if (hex.length == 6) {
                          final color = Color(int.parse('FF$hex', radix: 16));
                          setState(() {
                            _currentColor = color;
                            _updateSlidersFromColor(color);
                          });
                        }
                      } catch (_) {}
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _currentColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRgbInput() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RGB Color',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _rgbController,
              decoration: const InputDecoration(
                hintText: 'R, G, B  or  rgb(R, G, B)',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) {
                try {
                  final parts = v.replaceAll(RegExp(r'[^0-9,]'), '').split(',');
                  if (parts.length == 3) {
                    final r = int.parse(parts[0].trim());
                    final g = int.parse(parts[1].trim());
                    final b = int.parse(parts[2].trim());
                    final color = Color.fromRGBO(r, g, b, 1);
                    setState(() {
                      _currentColor = color;
                      _updateSlidersFromColor(color);
                    });
                  }
                } catch (_) {}
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversionTable() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'All Formats',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            _buildValueRow('Flutter', 'Color(0x${_colorToHex(_currentColor).replaceAll('#', 'FF')})'),
            _buildValueRow('CSS HEX', _colorToHex(_currentColor)),
            _buildValueRow('CSS RGB', 'rgb(${_currentColor.red}, ${_currentColor.green}, ${_currentColor.blue})'),
            _buildValueRow('CSS RGBA', 'rgba(${_currentColor.red}, ${_currentColor.green}, ${_currentColor.blue}, ${_currentColor.alpha.toStringAsFixed(2)})'),
            _buildValueRow('Android', '0x${_colorToHex(_currentColor).replaceAll('#', 'FF').toLowerCase()}'),
            _buildValueRow('Swift', 'UIColor(red: ${(_currentColor.red / 255).toStringAsFixed(3)}, green: ${(_currentColor.green / 255).toStringAsFixed(3)}, blue: ${(_currentColor.blue / 255).toStringAsFixed(3)}, alpha: 1.0)'),
          ],
        ),
      ),
    );
  }

  void _updateColor() {
    _currentColor = HSVColor.fromAHSV(1, _hue * 360, _saturation, _value).toColor();
    _hexController.text = _colorToHex(_currentColor);
    _rgbController.text = '${_currentColor.red}, ${_currentColor.green}, ${_currentColor.blue}';
  }

  void _updateFromColor(Color color) {
    _hexController.text = _colorToHex(color);
    _rgbController.text = '${color.red}, ${color.green}, ${color.blue}';
    _updateSlidersFromColor(color);
  }

  void _updateSlidersFromColor(Color color) {
    final hsv = HSVColor.fromColor(color);
    _hue = hsv.hue / 360;
    _saturation = hsv.saturation;
    _value = hsv.value;
  }

  String _colorToHex(Color color) {
    return '#${color.red.toRadixString(16).padLeft(2, '0')}${color.green.toRadixString(16).padLeft(2, '0')}${color.blue.toRadixString(16).padLeft(2, '0')}'.toUpperCase();
  }

  List<double> _rgbToHsl(int red, int green, int blue) {
    var r = red / 255.0;
    var g = green / 255.0;
    var b = blue / 255.0;

    final max = [r, g, b].reduce(math.max);
    final min = [r, g, b].reduce(math.min);
    var h = 0.0;
    var s = 0.0;
    final l = (max + min) / 2;

    if (max != min) {
      final d = max - min;
      s = l > 0.5 ? d / (2 - max - min) : d / (max + min);

      if (max == r) {
        h = (g - b) / d + (g < b ? 6 : 0);
      } else if (max == g) {
        h = (b - r) / d + 2;
      } else {
        h = (r - g) / d + 4;
      }
      h *= 60;
    }

    return [h, s * 100, l * 100];
  }
}
