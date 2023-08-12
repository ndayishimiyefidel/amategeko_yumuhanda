import 'package:flutter/material.dart';

class OptionModifiedTile extends StatefulWidget {
  final String description, correctAnswer, optionSelected;
  final Icon option;

  const OptionModifiedTile(
      {super.key,
      required this.optionSelected,
      required this.option,
      required this.correctAnswer,
      required this.description});

  @override
  State<OptionModifiedTile> createState() => _OptionModifiedTileState();
}

class _OptionModifiedTileState extends State<OptionModifiedTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(
                  color: widget.description == widget.optionSelected
                      ? widget.optionSelected == widget.correctAnswer
                          ? Colors.green.withOpacity(0.7)
                          : Colors.red.withOpacity(0.7)
                      : Colors.grey,
                  width: 1.4),
              borderRadius: BorderRadius.circular(30),
            ),
            alignment: Alignment.center,
            child: IconButton(
              iconSize: 35,
              padding: const EdgeInsets.only(bottom: 30),
              icon: widget.option,
              color: widget.optionSelected == widget.description
                  ? widget.optionSelected == widget.correctAnswer
                      ? Colors.green.withOpacity(0.7)
                      : Colors.red
                  : Colors.grey,
              onPressed: () {},
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
