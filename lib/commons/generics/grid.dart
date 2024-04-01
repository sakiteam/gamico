import 'dart:math';

import 'package:flutter/material.dart';

class GamicoGrid extends StatelessWidget {
  final int rows;
  final int cols;
  final List<Widget> children;
  final double rowsSpacing;
  final double colsSpacing;
  final EdgeInsets padding;

  const GamicoGrid({
    super.key,
    required this.rows,
    required this.cols,
    required this.children,
    this.rowsSpacing = 0,
    this.colsSpacing = 0,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final childrenLength = children.length;

    return Padding(
      padding: padding,
      child: Column(
        children: [
          for (int i = 0; i < rows; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == rows - 1 ? 0 : rowsSpacing),
              child: Row(
                children: () {
                  final sublist = children.sublist(
                      i * cols, min(i * cols + cols, childrenLength));
                  final sublistLength = sublist.length;
                  final List<Widget> finalList = [];

                  for (int j = 0; j < sublistLength; j++) {
                    finalList.add(
                      Padding(
                        padding: EdgeInsets.only(
                          right: j == sublistLength - 1 ? 0 : colsSpacing,
                        ),
                        child: sublist[j],
                      ),
                    );
                  }

                  return finalList;
                }(),
              ),
            ),
        ],
      ),
    );
  }
}
