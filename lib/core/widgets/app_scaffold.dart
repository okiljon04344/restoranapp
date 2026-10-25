import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final bool showBackButton;

  /// Centres the body and limits its width on wide screens.
  final double? maxContentWidth;

  const AppScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.showBackButton = true,
    this.maxContentWidth,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = maxContentWidth;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: showBackButton && context.canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => context.pop(),
              )
            : null,
        actions: actions,
      ),
      body: maxWidth == null
          ? child
          : Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: child,
              ),
            ),
    );
  }
}
