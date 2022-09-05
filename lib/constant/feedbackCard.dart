import 'package:flutter/material.dart';

GestureDetector feedbackCard(String txt, VoidCallback onPressed,
    {selectedCard = false}) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: selectedCard
              ? Colors.blueAccent.withOpacity(0.6)
              : Colors.grey.withOpacity(0.2)),
      margin: EdgeInsets.symmetric(),
      child: Text(
        txt,
        style: TextStyle(
          color: selectedCard ? Colors.white.withOpacity(0.9) : Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
