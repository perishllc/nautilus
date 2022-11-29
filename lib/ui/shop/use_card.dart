import 'package:flutter/material.dart';
import 'package:nautilus_wallet_flutter/appstate_container.dart';
import 'package:nautilus_wallet_flutter/styles.dart';

const Color primaryColor = Color(0xFFF67952);
const Color bgColor = Color(0xFFFBFBFD);

const double defaultPadding = 16.0;
const double defaultBorderRadius = 12.0;

class UseCard extends StatelessWidget {
  const UseCard({
    Key? key,
    required this.image,
    required this.title,
    required this.onPress,
  }) : super(key: key);
  final String image, title;
  final VoidCallback onPress;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        width: 154,
        padding: const EdgeInsets.all(defaultPadding / 2),
        decoration: BoxDecoration(
          color: StateContainer.of(context).curTheme.backgroundDark,
          borderRadius: BorderRadius.all(Radius.circular(defaultBorderRadius)),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: StateContainer.of(context).curTheme.background,
                borderRadius: const BorderRadius.all(Radius.circular(defaultBorderRadius)),
              ),
              child: Image.asset(
                image,
                height: 132,
              ),
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
