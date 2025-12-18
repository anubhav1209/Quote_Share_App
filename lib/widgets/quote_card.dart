import 'package:flutter/material.dart';
import 'glowing_avatar.dart';
import 'date_badge.dart';

class QuoteCard extends StatelessWidget {
  final String quoteText;
  final String userName;
  final String? userPhotoPath;
  final String date;
  final bool showDate;
  final Color? backgroundColor;
  final String? backgroundImage;
  final GlobalKey? repaintKey;

  const QuoteCard({
    super.key,
    required this.quoteText,
    required this.userName,
    this.userPhotoPath,
    required this.date,
    this.showDate = true,
    this.backgroundColor,
    this.backgroundImage,
    this.repaintKey,
  });

  @override
  Widget build(BuildContext context) {
    Widget quoteWidget = Container(
      width: double.infinity,
      height: 600,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.black,
        image: backgroundImage != null
            ? DecorationImage(
                image: AssetImage(backgroundImage!),
                fit: BoxFit.cover,
              )
            : null,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Gradient overlay for better text readability
          if (backgroundImage != null)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),

          // Quote text in center
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                quoteText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Date badge (top-left)
          if (showDate)
            Positioned(left: 16, top: 16, child: DateBadge(date: date)),

          // User photo (bottom-left with glow)
          if (userName.isNotEmpty)
            Positioned(
              left: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GlowingAvatar(imagePath: userPhotoPath, size: 64),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );

    // Wrap with RepaintBoundary if key is provided (for image capture)
    if (repaintKey != null) {
      return RepaintBoundary(key: repaintKey, child: quoteWidget);
    }

    return quoteWidget;
  }
}
