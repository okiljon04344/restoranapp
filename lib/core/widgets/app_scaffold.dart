import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;

  /// Where the back button leads when there is nothing to pop (pages are
  /// reached with `context.go`, which replaces the stack).
  final String? fallbackLocation;
  final Widget? bottomNavigationBar;

  const AppScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.fallbackLocation,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = fallbackLocation;
    final canPop = context.canPop();
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: canPop || fallback != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () {
                  if (canPop) {
                    context.pop();
                  } else if (fallback != null) {
                    context.go(fallback);
                  }
                },
              )
            : null,
        actions: actions,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: child,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
