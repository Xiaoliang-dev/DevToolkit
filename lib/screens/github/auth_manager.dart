import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GitHubAuthScreen extends StatefulWidget {
  const GitHubAuthScreen({super.key});

  @override
  State<GitHubAuthScreen> createState() => _GitHubAuthScreenState();
}

class _GitHubAuthScreenState extends State<GitHubAuthScreen> {
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool _obscureToken = true;

  @override
  void dispose() {
    _tokenController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('GitHub Sign In'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
              child: Column(
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Authentication',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your GitHub Personal Access Token to access your repositories',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How to get a token:',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 12),
                    _buildStep(1, 'Go to GitHub Settings > Developer settings'),
                    _buildStep(2, 'Select Personal access tokens > Tokens (classic)'),
                    _buildStep(3, 'Click "Generate new token"'),
                    _buildStep(4, 'Select scopes: repo, read:user'),
                    _buildStep(5, 'Copy and paste the token below'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'GitHub Username',
                hintText: 'your-username',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _tokenController,
              obscureText: _obscureToken,
              decoration: InputDecoration(
                labelText: 'Personal Access Token',
                hintText: 'ghp_xxxxxxxxxxxxxxxx',
                prefixIcon: const Icon(Icons.vpn_key_outlined),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscureToken ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscureToken = !_obscureToken),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _signIn,
              icon: const Icon(Icons.login),
              label: const Text('Sign In'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Cancel'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }

  void _signIn() {
    final token = _tokenController.text.trim();
    final username = _usernameController.text.trim();

    if (token.isEmpty || username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both username and token')),
      );
      return;
    }

    Navigator.pop(context, {
      'token': token,
      'username': username,
    });
  }
}
