import 'package:bike_buddy/constants.dart';
import 'package:flutter/material.dart';

class CustomExpansionPanel extends StatefulWidget {
  final String title;
  final Widget body;
  const CustomExpansionPanel(
      {super.key, required this.title, required this.body});

  @override
  State<CustomExpansionPanel> createState() => _CustomExpansionPanelState();
}

class _CustomExpansionPanelState extends State<CustomExpansionPanel>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    animation =
        CurvedAnimation(parent: animationController, curve: Curves.easeInOut);
  }

  void toggleExpanded() {
    setState(() {
      isExpanded = !isExpanded;
      if (isExpanded) {
        animationController.forward();
      } else {
        animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: toggleExpanded,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.insights,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(
                      width: 18,
                    ),
                    Text(
                      widget.title,
                      style: myTextStyle.copyWith(fontSize: 18),
                    ),
                  ],
                ),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
        SizeTransition(
          sizeFactor: animation,
          child: widget.body,
        ),
      ],
    );
  }
}
