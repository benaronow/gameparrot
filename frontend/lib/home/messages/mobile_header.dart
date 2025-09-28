import 'package:flutter/material.dart';
import 'package:gameparrot/providers/users_provider.dart';
import 'package:provider/provider.dart';
import '../../widgets/widgets.dart';

class MobileHeader extends StatelessWidget {
  final VoidCallback close;
  const MobileHeader({super.key, required this.close});

  @override
  Widget build(BuildContext context) {
    final friend = Provider.of<UsersProvider>(context).selectedFriend;

    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 30, left: 16, right: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withValues(alpha: .8),
            Colors.black.withValues(alpha: .4),
            Colors.white.withValues(alpha: 0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SizedBox(
        height: 50, // Set explicit height to prevent expansion
        child: Stack(
          children: [
            // Back button positioned on the left
            Align(
              alignment: Alignment.centerLeft,
              child: StyledIconButton(
                icon: Icons.arrow_back,
                iconColor: Colors.white,
                size: 40,
                onPressed: close,
              ),
            ),
            // Email centered in the entire component
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 60,
                ), // Account for button space
                child: Text(
                  friend?.email ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        offset: Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
