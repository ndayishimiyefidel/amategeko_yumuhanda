import 'package:flutter/material.dart';

class OptionTile extends StatefulWidget {
  final String description, correctAnswer, optionSelected;
  final String option;

  OptionTile(
      {required this.optionSelected,
      required this.option,
      required this.correctAnswer,
      required this.description});

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
              width: 35,
              height: 35,
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
              child: Text(
                widget.option,
                style: TextStyle(
                  color: widget.optionSelected == widget.description
                      ? widget.optionSelected == widget.correctAnswer
                          ? Colors.green.withOpacity(0.7)
                          : Colors.red
                      : Colors.grey,
                  fontSize: widget.optionSelected == widget.description
                      ? widget.optionSelected == widget.correctAnswer
                          ? 20
                          : 18
                      : 16,
                ),
              )
              // IconButton(
              //   iconSize: 35,
              //   padding: const EdgeInsets.only(bottom: 30),
              //   icon: widget.option,
              //   color: widget.optionSelected == widget.description
              //       ? widget.optionSelected == widget.correctAnswer
              //           ? Colors.green.withOpacity(0.7)
              //           : Colors.red
              //       : Colors.grey,
              //   onPressed: () {},
              // ),
              ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              widget.description,
              style: TextStyle(
                fontSize: widget.optionSelected == widget.description
                    ? widget.optionSelected == widget.correctAnswer
                        ? 20
                        : 18
                    : 16,
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
