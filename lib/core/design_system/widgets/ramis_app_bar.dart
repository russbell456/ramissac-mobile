import 'package:flutter/material.dart';

class RamisAppBar extends StatelessWidget implements PreferredSizeWidget {
  const RamisAppBar({
    required this.title,
    this.showBackButton = false,
    this.leading,
    this.actions,
    this.logo,
    this.centerTitle = false,
    super.key,
  });

  final String title;
  final bool showBackButton;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? logo;
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (logo != null) ...[
            logo!,
            const SizedBox(width: 12),
          ],
          Flexible(child: Text(title, overflow: TextOverflow.ellipsis)),
        ],
      ),
      automaticallyImplyLeading: showBackButton,
      leading: leading,
      actions: actions,
      centerTitle: centerTitle,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
