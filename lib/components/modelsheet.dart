import 'package:flutter/material.dart';

class ModalSheet extends StatelessWidget {
  final Widget? child;
  final double? height;
  final bool isDismissible;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const ModalSheet({
    super.key,
    this.child,
    this.height,
    this.isDismissible = true,
    this.backgroundColor,
    this.borderRadius,
  });

  Future<T?> show<T>(BuildContext context) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      isScrollControlled: true,
      backgroundColor: backgroundColor ?? Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ??
            const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: height ?? MediaQuery.of(context).size.height * 0.5,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Content
            Expanded(
              child: child ?? const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => show(context),
      child: child ?? const SizedBox(),
    );
  }
}