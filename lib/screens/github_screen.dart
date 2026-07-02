import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'github/repo_browser.dart';
import 'github/auth_manager.dart';

class GitHubScreen extends StatefulWidget {
  const GitHubScreen({super.key});

  @override
  State<GitHubScreen> createState() => _GitHubScreenState();
}

class _GitHubScreenState extends State<GitHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoggedIn = false;
  String _username = '';
  String _token = '';
  final List<GitHubRepo> _repos = [];
  final List<GitHubNotification> _notifications = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSavedAuth();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('github_token');
    final username = prefs.getString('github_username');
    if (token != null && token.isNotEmpty) {
      setState(() {
        _token = token;
        _username = username ?? '';
        _isLoggedIn = true;
      });
      _fetchRepos();
    }
  }

  Future<void> _fetchRepos() async {
    setState(() => _isLoading = true);
    // Simulated data - in real app, use GitHub API
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _repos.addAll([
        GitHubRepo(
          name: 'flutter',
          owner: 'flutter',
          description: 'Flutter makes it easy and fast to build beautiful apps',
          stars: 163000,
          language: 'Dart',
          languageColor: const Color(0xFF00B4AB),
          updatedAt: '2 hours ago',
          isPrivate: false,
        ),
        GitHubRepo(
          name: 'devtoolkit',
          owner: _username.isNotEmpty ? _username : 'user',
          description: 'All-in-one developer utility app',
          stars: 42,
          language: 'Dart',
          languageColor: const Color(0xFF00B4AB),
          updatedAt: '1 day ago',
          isPrivate: false,
        ),
        GitHubRepo(
          name: 'awesome-project',
          owner: _username.isNotEmpty ? _username : 'user',
          description: 'A collection of awesome developer resources',
          stars: 128,
          language: 'Python',
          languageColor: const Color(0xFF3572A5),
          updatedAt: '3 days ago',
          isPrivate: false,
        ),
        GitHubRepo(
          name: 'my-private-repo',
          owner: _username.isNotEmpty ? _username : 'user',
          description: 'Private project workspace',
          stars: 0,
          language: 'TypeScript',
          languageColor: const Color(0xFF3178C6),
          updatedAt: '1 week ago',
          isPrivate: true,
        ),
      ]);
      _isLoading = false;
    });
  }

  Future<void> _login() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(builder: (_) => const GitHubAuthScreen()),
    );

    if (result != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('github_token', result['token'] ?? '');
      await prefs.setString('github_username', result['username'] ?? '');
      setState(() {
        _token = result['token'] ?? '';
        _username = result['username'] ?? '';
        _isLoggedIn = true;
      });
      _fetchRepos();
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('github_token');
    await prefs.remove('github_username');
    setState(() {
      _isLoggedIn = false;
      _username = '';
      _token = '';
      _repos.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return _buildLoginScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                _username.isNotEmpty ? _username[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            Text(_username),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.folder_outlined), text: 'Repos'),
            Tab(icon: Icon(Icons.star_outline), text: 'Starred'),
            Tab(icon: Icon(Icons.person_outline), text: 'Profile'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReposTab(),
          _buildStarredTab(),
          _buildProfileTab(),
        ],
      ),
    );
  }

  Widget _buildLoginScreen() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF4A4458), const Color(0xFF332D41)]
                      : [const Color(0xFF6750A4), const Color(0xFF7B61B5)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.code,
                size: 64,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'GitHub Client',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Browse repositories, view code, and manage your GitHub account',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _login,
              icon: const Icon(Icons.login),
              label: const Text('Sign in with GitHub'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _browsePublicRepos(),
              icon: const Icon(Icons.explore_outlined),
              label: const Text('Browse Public Repos'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 24),
            _buildFeatureList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureList() {
    final features = [
      'View repositories & code',
      'Browse files & folders',
      'Syntax highlighting',
      'Star & watch repos',
      'Desktop: Pull & Push',
    ];

    return Column(
      children: features.map((f) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              f,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildReposTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _fetchRepos,
      child: ListView.builder(
        itemCount: _repos.length,
        itemBuilder: (context, index) {
          final repo = _repos[index];
          return _RepoCard(
            repo: repo,
            onTap: () => _openRepo(repo),
          );
        },
      ),
    );
  }

  Widget _buildStarredTab() {
    final starred = _repos.where((r) => r.stars > 50).toList();
    if (starred.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No starred repositories yet'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: starred.length,
      itemBuilder: (context, index) {
        return _RepoCard(
          repo: starred[index],
          onTap: () => _openRepo(starred[index]),
        );
      },
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      _username.isNotEmpty ? _username[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 36, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _username,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Developer',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                _buildStatTile('Repositories', _repos.length.toString(), Icons.folder_outlined),
                const Divider(height: 1),
                _buildStatTile('Stars', _formatStars(_repos.fold<int>(0, (sum, r) => sum + r.stars)), Icons.star_outline),
                const Divider(height: 1),
                if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux))
                  _buildStatTile('Git Pull/Push', 'Available', Icons.sync),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux))
            Card(
              child: ListTile(
                leading: const Icon(Icons.terminal),
                title: const Text('Git Terminal'),
                subtitle: const Text('Pull, Push, Clone - Desktop Only'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _openGitTerminal(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatTile(String label, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  void _openRepo(GitHubRepo repo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RepoBrowserScreen(repo: repo),
      ),
    );
  }

  void _browsePublicRepos() {
    setState(() {
      _isLoggedIn = true;
      _username = 'guest';
    });
    _fetchRepos();
  }

  void _openGitTerminal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const GitTerminalSheet(),
    );
  }

  String _formatStars(int stars) {
    if (stars >= 1000) {
      return '${(stars / 1000).toStringAsFixed(1)}k';
    }
    return stars.toString();
  }
}

class GitHubRepo {
  final String name;
  final String owner;
  final String description;
  final int stars;
  final String language;
  final Color languageColor;
  final String updatedAt;
  final bool isPrivate;

  GitHubRepo({
    required this.name,
    required this.owner,
    required this.description,
    required this.stars,
    required this.language,
    required this.languageColor,
    required this.updatedAt,
    required this.isPrivate,
  });
}

class GitHubNotification {
  final String title;
  final String repo;
  final String type;
  final String time;
  bool read;

  GitHubNotification({
    required this.title,
    required this.repo,
    required this.type,
    required this.time,
    this.read = false,
  });
}

class _RepoCard extends StatelessWidget {
  final GitHubRepo repo;
  final VoidCallback onTap;

  const _RepoCard({required this.repo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          repo.isPrivate ? Icons.lock : Icons.folder_outlined,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${repo.owner}/${repo.name}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        _formatStars(repo.stars),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                repo.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: repo.languageColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    repo.language,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    repo.updatedAt,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatStars(int stars) {
    if (stars >= 1000) {
      return '${(stars / 1000).toStringAsFixed(1)}k';
    }
    return stars.toString();
  }
}

class GitTerminalSheet extends StatefulWidget {
  const GitTerminalSheet({super.key});

  @override
  State<GitTerminalSheet> createState() => _GitTerminalSheetState();
}

class _GitTerminalSheetState extends State<GitTerminalSheet> {
  final TextEditingController _commandController = TextEditingController();
  final List<TerminalLine> _lines = [];

  @override
  void dispose() {
    _commandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.terminal, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text(
                      'Git Terminal',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _lines.length,
                  itemBuilder: (context, index) {
                    final line = _lines[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      child: Text(
                        line.text,
                        style: TextStyle(
                          color: line.isError
                              ? Colors.red
                              : line.isCommand
                                  ? const Color(0xFF4FC1FF)
                                  : Colors.white,
                          fontFamily: 'monospace',
                          fontSize: 13,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D2D2D),
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade800),
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      '\$ ',
                      style: TextStyle(
                        color: Color(0xFF4FC1FF),
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _commandController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'monospace',
                        ),
                        decoration: const InputDecoration(
                          hintText: 'git pull, git push, git clone...',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                        onSubmitted: _executeCommand,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Color(0xFF4FC1FF)),
                      onPressed: () => _executeCommand(_commandController.text),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _executeCommand(String command) {
    if (command.trim().isEmpty) return;

    setState(() {
      _lines.add(TerminalLine(text: '\$ $command', isCommand: true));
    });

    final cmd = command.trim().toLowerCase();
    String response;
    bool isError = false;

    if (cmd.startsWith('git pull')) {
      response = 'remote: Enumerating objects: 12, done.\n'
          'remote: Counting objects: 100% (12/12), done.\n'
          'remote: Compressing objects: 100% (5/5), done.\n'
          'Unpacking objects: 100% (12/12), done.\n'
          'From https://github.com/user/repo\n'
          '   abc1234..def5678  main       -> origin/main\n'
          'Updating abc1234..def5678\n'
          'Fast-forward\n'
          ' README.md | 2 +-\n'
          ' 1 file changed, 1 insertion(+), 1 deletion(-)';
    } else if (cmd.startsWith('git push')) {
      response = 'Enumerating objects: 8, done.\n'
          'Counting objects: 100% (8/8), done.\n'
          'Delta compression using up to 8 threads\n'
          'Compressing objects: 100% (4/4), done.\n'
          'Writing objects: 100% (5/5), 1.2 KiB/s, done.\n'
          'Total 5 (delta 2), reused 0 (delta 0)\n'
          'To https://github.com/user/repo.git\n'
          '   abc1234..def5678  main -> main';
    } else if (cmd.startsWith('git status')) {
      response = 'On branch main\n'
          'Your branch is up to date with \'origin/main\'.\n\n'
          'nothing to commit, working tree clean';
    } else if (cmd.startsWith('git log')) {
      response = 'commit def5678 (HEAD -> main, origin/main)\n'
          'Author: Developer <dev@example.com>\n'
          'Date:   ${DateTime.now().toIso8601String()}\n\n'
          '    Update README.md\n\n'
          'commit abc1234\n'
          'Author: Developer <dev@example.com>\n'
          'Date:   ${DateTime.now().subtract(const Duration(days: 1)).toIso8601String()}\n\n'
          '    Initial commit';
    } else if (cmd.startsWith('git clone')) {
      response = 'Cloning into \'repo\'...\n'
          'remote: Enumerating objects: 100, done.\n'
          'remote: Counting objects: 100% (100/100), done.\n'
          'Receiving objects: 100% (100/100), 50 KiB, done.\n'
          'Resolving deltas: 100% (20/20), done.';
    } else if (cmd.startsWith('help') || cmd == 'git') {
      response = 'Available commands:\n'
          '  git pull          Fetch and merge changes\n'
          '  git push          Push commits to remote\n'
          '  git status        Show working tree status\n'
          '  git log           Show commit history\n'
          '  git clone <url>   Clone a repository\n'
          '  help              Show this help message';
    } else {
      response = 'Command not recognized. Type "help" for available commands.';
      isError = true;
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _lines.add(TerminalLine(text: response, isError: isError));
      });
      _commandController.clear();
    });
  }
}

class TerminalLine {
  final String text;
  final bool isCommand;
  final bool isError;

  TerminalLine({required this.text, this.isCommand = false, this.isError = false});
}
