import 'package:flutter/material.dart';
import 'tools/crypto_tool.dart';
import 'tools/base64_tool.dart';
import 'tools/image_compress_tool.dart';
import 'tools/network_tool.dart';
import 'tools/json_formatter.dart';
import 'tools/timestamp_tool.dart';
import 'tools/color_tool.dart';
import 'tools/qr_tool.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _gridController;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _gridController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _gridController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _gridController.dispose();
    super.dispose();
  }

  final List<ToolItem> _tools = [
    ToolItem(
      title: 'Crypto',
      subtitle: 'Encrypt & Decrypt',
      icon: Icons.lock_outline,
      color: const Color(0xFF6750A4),
      screen: const CryptoTool(),
    ),
    ToolItem(
      title: 'Base64',
      subtitle: 'Encode & Decode',
      icon: Icons.swap_horiz,
      color: const Color(0xFF4CAF50),
      screen: const Base64Tool(),
    ),
    ToolItem(
      title: 'Image',
      subtitle: 'Compress Images',
      icon: Icons.image_outlined,
      color: const Color(0xFFFF9800),
      screen: const ImageCompressTool(),
    ),
    ToolItem(
      title: 'Network',
      subtitle: 'Test Connection',
      icon: Icons.network_check_outlined,
      color: const Color(0xFF2196F3),
      screen: const NetworkTool(),
    ),
    ToolItem(
      title: 'JSON',
      subtitle: 'Format & Validate',
      icon: Icons.data_object,
      color: const Color(0xFF9C27B0),
      screen: const JsonFormatter(),
    ),
    ToolItem(
      title: 'Timestamp',
      subtitle: 'Convert Time',
      icon: Icons.access_time,
      color: const Color(0xFFE91E63),
      screen: const TimestampTool(),
    ),
    ToolItem(
      title: 'Colors',
      subtitle: 'Picker & Converter',
      icon: Icons.colorize,
      color: const Color(0xFF00BCD4),
      screen: const ColorTool(),
    ),
    ToolItem(
      title: 'QR Code',
      subtitle: 'Generate & Scan',
      icon: Icons.qr_code,
      color: const Color(0xFF795548),
      screen: const QrTool(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: AnimatedBuilder(
            animation: _headerController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _headerController,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.3),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _headerController,
                    curve: Curves.easeOut,
                  )),
                  child: _buildHeader(isDark),
                ),
              );
            },
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final delay = index * 0.08;
                final animation = Tween<double>(begin: 0, end: 1).animate(
                  CurvedAnimation(
                    parent: _gridController,
                    curve: Interval(
                      delay.clamp(0, 0.7),
                      (delay + 0.3).clamp(0.3, 1.0),
                      curve: Curves.easeOut,
                    ),
                  ),
                );
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(animation),
                    child: _ToolCard(
                      tool: _tools[index],
                      onTap: () => _openTool(_tools[index].screen),
                    ),
                  ),
                );
              },
              childCount: _tools.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF4A4458), const Color(0xFF332D41)]
              : [const Color(0xFF6750A4), const Color(0xFF7B61B5)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isDark ? const Color(0xFF6750A4) : const Color(0xFF6750A4))
                .withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.developer_mode,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DevToolkit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'v1.0.0',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'All-in-one developer utilities for everyday tasks',
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChip('Encryption'),
              _buildChip('Networking'),
              _buildChip('Encoding'),
              _buildChip('GitHub'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _openTool(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}

class ToolItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget screen;

  ToolItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.screen,
  });
}

class _ToolCard extends StatelessWidget {
  final ToolItem tool;
  final VoidCallback onTap;

  const _ToolCard({required this.tool, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                tool.color.withOpacity(isDark ? 0.15 : 0.08),
                (isDark ? const Color(0xFF2B2930) : Colors.white),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: tool.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    tool.icon,
                    color: tool.color,
                    size: 24,
                  ),
                ),
                const Spacer(),
                Text(
                  tool.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tool.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
