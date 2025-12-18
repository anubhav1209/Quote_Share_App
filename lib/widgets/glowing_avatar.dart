import 'package:flutter/material.dart';
import 'dart:io';

class GlowingAvatar extends StatefulWidget {
  final String? imagePath;
  final double size;

  const GlowingAvatar({super.key, this.imagePath, this.size = 64});

  @override
  State<GlowingAvatar> createState() => _GlowingAvatarState();
}

class _GlowingAvatarState extends State<GlowingAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 5.0,
      end: 15.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withValues(alpha: 0.6),
                blurRadius: _animation.value,
                spreadRadius: _animation.value / 2,
              ),
              BoxShadow(
                color: Colors.purple.withValues(alpha: 0.4),
                blurRadius: _animation.value * 1.5,
                spreadRadius: _animation.value,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: widget.size / 2,
            backgroundColor: Colors.grey[300],
            backgroundImage:
                widget.imagePath != null && File(widget.imagePath!).existsSync()
                ? FileImage(File(widget.imagePath!))
                : null,
            child: widget.imagePath == null
                ? Icon(
                    Icons.person,
                    size: widget.size * 0.6,
                    color: Colors.grey[600],
                  )
                : null,
          ),
        );
      },
    );
  }
}
