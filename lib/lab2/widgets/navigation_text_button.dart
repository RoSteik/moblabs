import 'package:flutter/material.dart';


class NavigationTextButton extends StatelessWidget {
  final String text;
  final Widget destinationPage;
  const NavigationTextButton({required this.text, required this.destinationPage,
    super.key,});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (context) => destinationPage),
        );
      },
      child: Text(text),
    );
  }
}
