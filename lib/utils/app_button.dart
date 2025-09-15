import 'package:flutter/material.dart';

enum ButtonVariant { solid, outline }

enum ButtonType { primary, secondary, danger }

enum ButtonThemeMode { light, dark }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonVariant variant;
  final ButtonType type;
  final ButtonThemeMode themeMode;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = ButtonVariant.solid,
    this.type = ButtonType.primary,
    this.themeMode = ButtonThemeMode.light,
    this.fullWidth = false,
  });

  Color _getColor() {
    switch (type) {
      case ButtonType.primary:
        return Colors.blue;
      case ButtonType.secondary:
        return Colors.grey;
      case ButtonType.danger:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final isSolid = variant == ButtonVariant.solid;

    final textColor = isSolid
        ? Colors.white
        : (themeMode == ButtonThemeMode.dark ? Colors.white : color);

    final buttonChild = Text(
      text,
      style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
    );

    final ButtonStyle style = ButtonStyle(
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    final button = isSolid
        ? ElevatedButton(
            style: style.copyWith(
              backgroundColor: WidgetStateProperty.all(color),
              foregroundColor: WidgetStateProperty.all(textColor),
            ),
            onPressed: onPressed,
            child: buttonChild,
          )
        : OutlinedButton(
            style: style.copyWith(
              foregroundColor: WidgetStateProperty.all(textColor),
              side: WidgetStateProperty.all(BorderSide(color: color, width: 2)),
            ),
            onPressed: onPressed,
            child: buttonChild,
          );

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}
