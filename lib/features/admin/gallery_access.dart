import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/i18n/l10n.dart';
import '../../data/gallery/gallery_providers.dart';

class GalleryAccess extends ConsumerStatefulWidget {
  const GalleryAccess({super.key, required this.child, this.adminOnly = false});
  final Widget child;
  final bool adminOnly;
  @override
  ConsumerState<GalleryAccess> createState() => _GalleryAccessState();
}

class _GalleryAccessState extends ConsumerState<GalleryAccess> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  bool _showPassword = false;
  String? _error;
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(galleryRepositoryProvider)!
          .client
          .auth
          .signInWithPassword(
            email: _email.text.trim(),
            password: _password.text,
          );
      _password.clear();
      ref.invalidate(galleryRoleProvider);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Sign-in failed. Check your details and connection.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(langProvider);
    String t(String s) => trS(lang, s);
    final repository = ref.watch(galleryRepositoryProvider);
    if (repository == null) {
      return widget.adminOnly
          ? Center(child: Text(t('Cloud setup is needed before signing in.')))
          : widget.child;
    }
    ref.watch(galleryAuthProvider);
    final role = ref.watch(galleryRoleProvider);
    if (role.isLoading) return const Center(child: CircularProgressIndicator());
    final allowed = widget.adminOnly
        ? role.value == 'admin'
        : role.value != null;
    if (!role.hasError && allowed) return widget.child;
    final signedIn = repository.client.auth.currentUser != null;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.lock_outline, size: 40),
              const SizedBox(height: 16),
              Text(
                t(
                  widget.adminOnly ? 'Your album desk' : 'Family album sign-in',
                ),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              if (signedIn) ...[
                Text(
                  t(
                    role.hasError
                        ? 'Could not connect. Please retry.'
                        : 'This account does not have access.',
                  ),
                ),
                TextButton(
                  onPressed: () => ref.invalidate(galleryRoleProvider),
                  child: Text(t('Retry')),
                ),
                TextButton(
                  onPressed: () async {
                    await repository.client.auth.signOut();
                  },
                  child: Text(t('Sign out')),
                ),
              ] else ...[
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: InputDecoration(labelText: t('Email')),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _password,
                  obscureText: !_showPassword,
                  autofillHints: const [AutofillHints.password],
                  decoration: InputDecoration(
                    labelText: t('Password'),
                    suffixIcon: IconButton(
                      tooltip: t(
                        _showPassword ? 'Hide password' : 'Show password',
                      ),
                      icon: Icon(
                        _showPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _showPassword = !_showPassword),
                    ),
                  ),
                  onSubmitted: (_) {
                    if (!_busy) _signIn();
                  },
                ),
                const SizedBox(height: 16),
                if (_error != null)
                  Text(t(_error!), style: const TextStyle(color: Colors.red)),
                FilledButton(
                  onPressed: _busy ? null : _signIn,
                  child: Text(t(_busy ? 'Signing in…' : 'Sign in')),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
