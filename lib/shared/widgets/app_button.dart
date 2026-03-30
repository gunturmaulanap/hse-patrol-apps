import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final bool isDanger;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return GFButton(
      onPressed: isLoading ? null : onPressed,
      text: isLoading ? 'Memproses...' : label,
      textStyle: TextStyle(
        fontWeight: FontWeight.bold, 
        fontSize: 16, 
        color: isSecondary ? Colors.teal.shade800 : Colors.white,
      ),
      color: isSecondary 
          ? GFColors.LIGHT 
          : (isDanger ? GFColors.DANGER : Colors.teal.shade700),
      type: isSecondary ? GFButtonType.outline : GFButtonType.solid,
      shape: GFButtonShape.pills,
      size: GFSize.LARGE,
      fullWidthButton: true,
      elevation: isSecondary ? 0 : 4,
      icon: isLoading 
         ? SizedBox(
             width: 20, 
             height: 20, 
             child: CircularProgressIndicator(
               color: isSecondary ? Colors.teal.shade800 : Colors.white, 
               strokeWidth: 2,
             ),
           ) 
         : null,
    );
  }
}
