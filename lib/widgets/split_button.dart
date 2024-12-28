import 'package:flutter/material.dart';

class SplitButton extends StatelessWidget {
  final String label;
  final Future<void> Function() onPressed;
  final List<PopupMenuItem> menuItems;
  final double height;

  const SplitButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.menuItems,
    this.height = 32,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main button part
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                    topRight: Radius.zero,
                    bottomRight: Radius.zero,
                  ),
                ),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
            ),
            // Dropdown button part
            ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size(36, height),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.zero,
                    bottomLeft: Radius.zero,
                    topRight: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                ),
              ),
              child: PopupMenuButton(
                itemBuilder: (context) => menuItems,
                position: PopupMenuPosition.under,
                offset: const Offset(0, 8),
                child: Container(
                  height: height,
                  width: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: const Icon(
                    Icons.arrow_drop_down,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}