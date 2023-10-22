import 'package:flutter/material.dart';

class QuestionTile extends StatefulWidget {
  final String option, description, correctAnswer, optionSelcted;
  const QuestionTile(
      {super.key, required this.option,
      required this.description,
      required this.correctAnswer,
      required this.optionSelcted});
  @override
  _QuestionTileState createState() => _QuestionTileState();
}

class _QuestionTileState extends State<QuestionTile> {
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
              color: widget.description == widget.optionSelcted
                  ? Colors.green.withOpacity(0.7)
                  : Colors.white,
              border: Border.all(
                color: widget.description == widget.optionSelcted
                    ? Colors.green.withOpacity(0.7)
                    : Colors.grey,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            alignment: Alignment.center,
            child: Text(
              widget.option,
              style: TextStyle(
                color: widget.description == widget.optionSelcted
                    ? widget.optionSelcted == widget.correctAnswer
                        ? Colors.white
                        : Colors.white
                    : Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            widget.description,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2)
        ],
      ),
    );
  }
}
