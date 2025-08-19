import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final VoidCallback? onMenuPressed;
  final Widget? trailingWidget;

  const ModernAppBar({
    Key? key,
    required this.title,
    this.subtitle,
    this.actions,
    this.onMenuPressed,
    this.trailingWidget,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: preferredSize,
      child: Container(
        decoration: BoxDecoration(
          color: kPrimaryColor,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
          boxShadow: [
            BoxShadow(
              color: kPrimaryColor.withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
            child: Row(
              children: [
                // Left section with menu and title
                Expanded(
                  child: Row(
                    children: [
                      if (onMenuPressed != null)
                        GestureDetector(
                          onTap: onMenuPressed,
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.menu,
                                color: kPrimaryColor, size: 28),
                          ),
                        ),
                      if (onMenuPressed != null) const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            if (subtitle != null)
                              Text(
                                subtitle!,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Right section with actions
                if (actions != null || trailingWidget != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (actions != null) ...actions!,
                      if (trailingWidget != null) ...[
                        const SizedBox(width: 8),
                        trailingWidget!,
                      ],
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
