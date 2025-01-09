import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class MusicContainer extends StatefulWidget {
  final String title;
  final IconData icon;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;

  const MusicContainer({
    super.key,
    required this.title,
    required this.icon,
    required this.isFavorite,
    this.onTap,
    this.onFavoriteToggle,
  });

  @override
  State<MusicContainer> createState() => _MusicContainerState();
}

class _MusicContainerState extends State<MusicContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        elevation: 2,
        shadowColor: Colors.black12,
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.05),
                  Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Hero(
                  tag: 'music_icon_${widget.title}',
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: HugeIcon(
                      icon: widget.icon,
                      size: 32,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      if (widget.title.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Tap to view lyrics',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: widget.onFavoriteToggle,
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: child,
                      );
                    },
                    child: Icon(
                      widget.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      key: ValueKey(widget.isFavorite),
                      color: widget.isFavorite
                          ? Colors.red
                          : Colors.grey.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
