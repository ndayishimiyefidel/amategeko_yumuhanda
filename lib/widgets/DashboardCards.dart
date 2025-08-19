import 'package:flutter/material.dart';
import '../utils/constants.dart';

class DashboardCard extends StatelessWidget {
  final String name;
  final String imgpath;
  final bool isDisabled;

  const DashboardCard({
    Key? key,
    required this.name,
    required this.imgpath,
    this.isDisabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Container(
      padding: const EdgeInsets.all(10), // reduced padding
      height: height * 0.13, // smaller height
      width: width * 0.26, // smaller width for more cards per row
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18), // slightly less rounded
        gradient: LinearGradient(
          colors: isDisabled
              ? [
                  Colors.grey.withValues(alpha: 0.10),
                  Colors.grey.withValues(alpha: 0.18),
                ]
              : [
                  kPrimaryColor.withValues(alpha: 0.10),
                  kPrimaryLightColor.withValues(alpha: 0.18),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: isDisabled
                ? Colors.grey.withValues(alpha: 0.08)
                : kPrimaryColor.withValues(alpha: 0.08),
            offset: const Offset(0, 4),
            blurRadius: 12, // less blur
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDisabled
                  ? Colors.grey.withValues(alpha: 0.10)
                  : kPrimaryColor.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(6), // smaller icon padding
            child: Image.asset(
              "assets/$imgpath",
              width: 28, // smaller icon
              height: 28,
              fit: BoxFit.contain,
              color: isDisabled ? Colors.grey : null,
            ),
          ),
          const SizedBox(height: 6), // less spacing
          Flexible(
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13, // smaller font
                letterSpacing: 0.2,
                color: isDisabled ? Colors.grey : Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
