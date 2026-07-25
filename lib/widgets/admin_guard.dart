import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/security/admin_action_policy.dart';
import '../models/app_user.dart';
import '../repositories/auth_repository.dart';

typedef AdminPermission = bool Function(AppUser user);

class AdminGuard extends StatelessWidget {
  final Widget child;
  final AdminPermission? permission;

  const AdminGuard({super.key, required this.child, this.permission});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isCheckingAuth) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = auth.currentUser;
        final allowed =
            const AdminActionPolicy().canAccessAdmin(user) &&
            (permission == null || permission!(user!));

        if (!allowed) {
          return Scaffold(
            appBar: AppBar(title: const Text('Доступ запрещён')),
            body: const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.gpp_bad_outlined, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'У вас нет прав для просмотра этого раздела.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return child;
      },
    );
  }
}
