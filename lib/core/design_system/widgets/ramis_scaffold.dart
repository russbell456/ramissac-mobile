import 'package:flutter/material.dart';

import '../ramis_spacing.dart';
import 'ramis_app_bar.dart';

class RamisScaffold extends StatelessWidget {
  const RamisScaffold({
    required this.body,
    this.title,
    this.appBar,
    this.actions,
    this.leading,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.safeArea = true,
    this.useScreenPadding = false,
    this.resizeToAvoidBottomInset = true,
    this.backgroundColor,
    super.key,
  });

  final Widget body;
  final String? title;
  final PreferredSizeWidget? appBar;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool safeArea;
  final bool useScreenPadding;
  final bool resizeToAvoidBottomInset;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    Widget content = body;
    if (useScreenPadding) {
      content = Padding(padding: RamisSpacing.screenPadding, child: content);
    }
    if (safeArea) content = SafeArea(child: content);

    return Scaffold(
      appBar: appBar ??
          (title == null
              ? null
              : RamisAppBar(
                  title: title!,
                  actions: actions,
                  leading: leading,
                  showBackButton: leading == null && Navigator.canPop(context),
                )),
      body: content,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      backgroundColor: backgroundColor,
    );
  }
}
