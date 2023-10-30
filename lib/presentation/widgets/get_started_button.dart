// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class GetStartedButton extends StatefulWidget {
  final Function onTap;
  final Function onAnimatinoEnd;
  final double elementsOpacity;
  final String buttonText; // New variable to hold the text
  final IconData iconData; // New variable to hold the icon
  final Color buttonColor; // New variable to hold the button's background color

  const GetStartedButton({
    super.key,
    required this.onTap,
    required this.onAnimatinoEnd,
    required this.elementsOpacity,
    required this.buttonText, // Required text for the button
    required this.iconData, // Required icon for the button
    required this.buttonColor, // Required background color for the button
  });

  @override
  State<GetStartedButton> createState() => _GetStartedButtonState();
}

class _GetStartedButtonState extends State<GetStartedButton> {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300),
      tween: Tween(begin: 1, end: widget.elementsOpacity),
      onEnd: () async {
        widget.onAnimatinoEnd();
      },
      builder: (_, value, __) => GestureDetector(
        onTap: () {
          widget.onTap(); // Call the onTap callback function when tapped
        },
        child: Opacity(
          opacity: value,
          child: Container(
            width: 230,
            height: 75,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: widget.buttonColor, // Use the provided button color
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.iconData, // Use the provided icon
                  color: Colors.white,
                  size: 26,
                ),
                SizedBox(width: 15),
                Text(
                  widget.buttonText, // Use the provided text
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: 19,
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
