import 'package:flutter/material.dart';
import 'tools/crypto_tool.dart';
import 'tools/base64_tool.dart';
import 'tools/image_compress_tool.dart';
import 'tools/network_tool.dart';
import 'tools/json_formatter.dart';
import 'tools/timestamp_tool.dart';
import 'tools/color_tool.dart';
import 'tools/qr_tool.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  String _searchQuery = '';

  final List<ToolCategory> _categories = [
    ToolCategory(
      title: 'Cryptography',
      icon: Icons.security,
      color: const Color(0xFF6750A4),
      tools: [
        ToolInfo('Crypto', 'Encrypt & Decrypt (AES, RSA, Hash)', Icons.lock_outline, const CryptoTool()),
        ToolInfo('Base64', 'Encode & Decode', Icons.swap_horiz, const Base64Tool()),
      ],
    ),
    ToolCategory(
      title: 'Media',
      icon: Icons.image,
      color: const Color(0xFFFF9800),
      tools: [
        ToolInfo('Image Compress', 'Compress and optimize', Icons.image_outlined, const ImageCompressTool()),
        ToolInfo('QR Code', 'Generate & Decode', Icons.qr_code, const QrTool()),
      ],
    ),
    ToolCategory(
      title: 'Network',
      icon: Icons.network_check,
      color: const Color(0xFF2196F3),
      tools: [
        ToolInfo('Network Tools', 'Ping, Port Scan, DNS', Icons.network_check_outlined, const NetworkTool()),
      ],
    ),
    ToolCategory(
      title: 'Data',
      icon: Icons.data_object,
      color: const Color(0xFF9C27B0),
      tools: [
        ToolInfo('JSON Formatter', 'Format & Validate', Icons.data_object, const JsonFormatter()),
        ToolInfo('Timestamp', 'Convert Time', Icons.access_time, const TimestampTool()),
      ],
    ),
    ToolCategory(
      title: 'Design',
      icon: Icons.palette,
      color: const Color(0xFF00BCD4),
      tools: [
        ToolInfo('Color Tool', 'Picker & Converter', Icons.colorize, const ColorTool()),
      ],
    ),
  ];

  List<ToolInfo> get _filteredTools {
    if (_searchQuery.isEmpty) return [];
    final query = _searchQuery.toLowerCase();
    final allTools = _categories.expand((c) => c.tools).toList();
    return allTools.where((t) {
      return t.name.toLowerCase().contains(query) ||
          t.description.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBar(
              hintText: 'Search tools...',
              leading: const Icon(Icons.search),
              trailing: [
                if (_searchQuery.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _searchQuery = ''),
                  ),
              ],
              onChanged: (value) => setState(() => _searchQuery = value),
              backgroundColor: WidgetStateProperty.all(
                isDark ? const Color(0xFF2B2930) : Colors.white,
              ),
              elevation: WidgetStateProperty.all(0),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_searchQuery.isNotEmpty && _filteredTools.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList.builder(
              itemCount: _filteredTools.length,
              itemBuilder: (context, index) {
                final tool = _filteredTools[index];
                return _ToolListTile(
                  tool: tool,
                  onTap: () => _openTool(tool.screen),
                );
              },
            ),
          )
        else if (_searchQuery.isNotEmpty && _filteredTools.isEmpty)
          const SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No tools found'),
                ],
              ),
            ),
          )
        else
          ..._categories.map((category) {
            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              sliver: SliverToBoxAdapter(
                child: _CategorySection(
                  category: category,
                  onToolTap: _openTool,
                ),
              ),
            );
          }),
      ],
    );
  }

  void _openTool(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}

class ToolCategory {
  final String title;
  final IconData icon;
  final Color color;
  final List<ToolInfo> tools;

  ToolCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.tools,
  });
}

class ToolInfo {
  final String name;
  final String description;
  final IconData icon;
  final Widget screen;

  ToolInfo(this.name, this.description, this.icon, this.screen);
}

class _CategorySection extends StatelessWidget {
  final ToolCategory category;
  final Function(Widget) onToolTap;

  const _CategorySection({required this.category, required this.onToolTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                category.icon,
                color: category.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              category.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...category.tools.map((tool) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                tool.icon,
                color: category.color,
                size: 20,
              ),
            ),
            title: Text(tool.name),
            subtitle: Text(tool.description),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => onToolTap(tool.screen),
          ),
        )),
      ],
    );
  }
}

class _ToolListTile extends StatelessWidget {
  final ToolInfo tool;
  final VoidCallback onTap;

  const _ToolListTile({required this.tool, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(tool.icon),
        title: Text(tool.name),
        subtitle: Text(tool.description),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
