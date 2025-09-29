import 'package:flutter/material.dart';
import 'package:gameparrot/theme.dart';

class TicTacToeCell extends StatelessWidget {
  final int index;
  final String symbol;
  final VoidCallback onTap;
  final bool isPlayable;
  const TicTacToeCell({
    super.key,
    required this.index,
    required this.symbol,
    required this.onTap,
    required this.isPlayable,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = symbol.isEmpty && isPlayable;
    // Determine fill color for symbol (X = red, O = black)
    final Color? fillColor = symbol == 'X'
        ? Colors.red
        : symbol == 'O'
        ? Colors.black
        : null;
    const double glyphSize = 72; // Bigger symbols
    const double outlineWidth = 5.0; // White outline thickness
    return MouseRegion(
      onEnter: (_) => {},
      child: InkWell(
        onTap: enabled ? onTap : null,
        splashColor: Colors.white10,
        highlightColor: Colors.white10,
        hoverColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: enabled
                  ? Colors.white.withValues(alpha: 0.25)
                  : Colors.white.withValues(alpha: 0.05),
              width: 1.4,
            ),
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: enabled ? 0.10 : 0.02),
                Colors.white.withValues(alpha: enabled ? 0.18 : 0.04),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              if (enabled)
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.30),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                  spreadRadius: 1,
                ),
            ],
          ),
          child: Center(
            child: AnimatedScale(
              duration: const Duration(milliseconds: 220),
              scale: symbol.isEmpty ? 0.0 : 1.0,
              curve: Curves.easeOutBack,
              child: symbol.isEmpty
                  ? const SizedBox.shrink()
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outline stroke
                        Text(
                          symbol,
                          style: TextStyle(
                            fontSize: glyphSize,
                            fontWeight: FontWeight.w800,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = outlineWidth
                              ..color = Colors.white,
                          ),
                        ),
                        // Fill
                        Text(
                          symbol,
                          style: TextStyle(
                            fontSize: glyphSize,
                            fontWeight: FontWeight.w800,
                            color: fillColor,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
