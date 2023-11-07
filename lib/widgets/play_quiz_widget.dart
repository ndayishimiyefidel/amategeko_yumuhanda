import 'package:flutter/material.dart';

class OptionTile extends StatefulWidget {
  final String description, correctAnswer, optionSelected;
  final Icon option;
  final VoidCallback? onPressed; // Add this callback

  const OptionTile(
      {super.key,
      required this.optionSelected,
      required this.option,
      required this.correctAnswer,
      required this.description,
      this.onPressed,
      Color? backgroundColor});

  @override
  State<OptionTile> createState() => _OptionTileState();
}

class _OptionTileState extends State<OptionTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              border: Border.all(
                  color: widget.description == widget.optionSelected
                      ? widget.optionSelected == widget.correctAnswer
                          ? Colors.green.withOpacity(0.7)
                          : Colors.red.withOpacity(0.7)
                      : Colors.grey,
                  width: 1.4),
              borderRadius: BorderRadius.circular(5),
            ),
            alignment: Alignment.center,
            child: IconButton(
              iconSize: 20,
              padding: const EdgeInsets.only(bottom: 30),
              icon: widget.option,
              color: widget.optionSelected == widget.description
                  ? widget.optionSelected == widget.correctAnswer
                      ? Colors.green.withOpacity(0.7)
                      : Colors.red
                  : Colors.grey,
              onPressed: () {
                if (widget.onPressed != null) {
                  widget.onPressed!(); // Call the onPressed callback
                }
              },
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              widget.description,
              style: TextStyle(
                fontSize: 16,
                color: widget.optionSelected == widget.description
                    ? widget.optionSelected == widget.correctAnswer
                        ? Colors.green.withOpacity(0.7)
                        : Colors.red
                    : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
