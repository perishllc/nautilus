import 'package:flutter/material.dart';
import 'package:wallet_flutter/appstate_container.dart';
import 'package:wallet_flutter/styles.dart';
import 'package:wallet_flutter/ui/widgets/buttons.dart';

const Color primaryColor = Color(0xFFF67952);
const Color bgColor = Color(0xFFFBFBFD);

const double defaultPadding = 16.0;
const double defaultBorderRadius = 12.0;

class UseCard extends StatelessWidget {
  const UseCard({
    Key? key,
    this.image,
    this.icon,
    required this.title,
    required this.onPress,
  }) : super(key: key);
  final String? image;
  final String title;
  final IconData? icon;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPress,
      style: TextButton.styleFrom(
        backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppButton.BORDER_RADIUS)),
        // foregroundColor: StateContainer.of(context).curTheme.background40,
        padding: EdgeInsets.zero,
      ),
      child: Container(
        width: image != null ? 150 : 100,
        padding: const EdgeInsets.all(defaultPadding / 2),
        // decoration: BoxDecoration(
        //   color: StateContainer.of(context).curTheme.backgroundDark,
        //   borderRadius: BorderRadius.all(Radius.circular(defaultBorderRadius)),
        // ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: StateContainer.of(context).curTheme.background,
                borderRadius: const BorderRadius.all(Radius.circular(defaultBorderRadius)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: image != null ? Image.asset(
                image!,
                height: 132,
              ) : icon != null ? Icon(
                icon,
                size: 64,
                color: StateContainer.of(context).curTheme.primary,
              ) : null,
            ),
            const SizedBox(height: defaultPadding / 2),
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppStyles.textStyleButtonTextOutline(context).copyWith(
                      color: StateContainer.of(context).curTheme.text,
                      fontSize: AppFontSizes.small,
                    ),
                  ),
                ),
                const SizedBox(width: defaultPadding / 4),
              ],
            )
          ],
        ),
      ),
    );
  }
}
