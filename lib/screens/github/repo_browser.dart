import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'code_viewer.dart';
import '../github_screen.dart';

class RepoBrowserScreen extends StatefulWidget {
  final GitHubRepo repo;

  const RepoBrowserScreen({super.key, required this.repo});

  @override
  State<RepoBrowserScreen> createState() => _RepoBrowserScreenState();
}

class _RepoBrowserScreenState extends State<RepoBrowserScreen> {
  String _currentPath = '';
  final List<RepoItem> _items = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));

    final sampleItems = _currentPath.isEmpty
        ? [
            RepoItem(name: 'lib', type: 'dir', path: 'lib'),
            RepoItem(name: 'test', type: 'dir', path: 'test'),
            RepoItem(name: 'assets', type: 'dir', path: 'assets'),
            RepoItem(name: 'pubspec.yaml', type: 'file', path: 'pubspec.yaml', size: 2048),
            RepoItem(name: 'README.md', type: 'file', path: 'README.md', size: 4096),
            RepoItem(name: 'LICENSE', type: 'file', path: 'LICENSE', size: 1024),
            RepoItem(name: '.gitignore', type: 'file', path: '.gitignore', size: 512),
            RepoItem(name: 'analysis_options.yaml', type: 'file', path: 'analysis_options.yaml', size: 256),
          ]
        : _getSubItems(_currentPath);

    setState(() {
      _items.clear();
      _items.addAll(sampleItems);
      _isLoading = false;
    });
  }

  List<RepoItem> _getSubItems(String path) {
    final random = math.Random(path.hashCode);
    final files = [
      'main.dart', 'utils.dart', 'models.dart', 'api.dart',
      'widgets.dart', 'screens.dart', 'theme.dart', 'constants.dart',
    ];

    return files.map((f) => RepoItem(
      name: f,
      type: 'file',
      path: '$path/$f',
      size: random.nextInt(10000) + 500,
    )).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.repo.owner}/${widget.repo.name}'),
            if (_currentPath.isNotEmpty)
              Text(
                _currentPath,
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        leading: _currentPath.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.arrow_upward),
                onPressed: () {
                  final parts = _currentPath.split('/');
                  parts.removeLast();
                  setState(() {
                    _currentPath = parts.join('/');
                  });
                  _loadItems();
                },
              )
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return _RepoItemTile(
                  item: item,
                  onTap: () => _onItemTap(item),
                );
              },
            ),
    );
  }

  void _onItemTap(RepoItem item) {
    if (item.type == 'dir') {
      setState(() {
        _currentPath = item.path;
      });
      _loadItems();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CodeViewerScreen(
            repo: widget.repo,
            filePath: item.path,
            fileName: item.name,
          ),
        ),
      );
    }
  }
}

class RepoItem {
  final String name;
  final String type;
  final String path;
  final int? size;

  RepoItem({
    required this.name,
    required this.type,
    required this.path,
    this.size,
  });
}

class _RepoItemTile extends StatelessWidget {
  final RepoItem item;
  final VoidCallback onTap;

  const _RepoItemTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDir = item.type == 'dir';

    return ListTile(
      leading: Icon(
        isDir ? Icons.folder : _getFileIcon(item.name),
        color: isDir
            ? Colors.amber
            : Theme.of(context).colorScheme.primary,
      ),
      title: Text(item.name),
      subtitle: item.size != null
          ? Text(_formatSize(item.size!))
          : null,
      trailing: isDir
          ? const Icon(Icons.chevron_right)
          : null,
      onTap: onTap,
    );
  }

  IconData _getFileIcon(String name) {
    if (name.endsWith('.dart')) return Icons.flutter_dash;
    if (name.endsWith('.md')) return Icons.description;
    if (name.endsWith('.yaml') || name.endsWith('.yml')) return Icons.settings;
    if (name.endsWith('.json')) return Icons.data_object;
    if (name.endsWith('.png') || name.endsWith('.jpg') || name.endsWith('.svg')) {
      return Icons.image;
    }
    if (name.endsWith('.gitignore')) return Icons.hide_source;
    return Icons.insert_drive_file;
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }
}
