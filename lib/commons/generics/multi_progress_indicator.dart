import 'package:flutter/widgets.dart';
import 'package:gamico/commons/utilities/progress/progress_utility.dart';

class GamicoMultiProgressIndicator extends StatelessWidget {
  final List<GamicoProgressUtility> values;

  const GamicoMultiProgressIndicator({
    super.key,
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    final total = values.fold(0.0, (previousValue, element) {
      return element.value + previousValue;
    });

    final allNull = total == 0;

    return Row(
      children: values.map((progressUtility) {
        return Expanded(
          flex: allNull ? 1 : ((progressUtility.value / total) * 100).round(),
          child: Container(
            color: progressUtility.color,
          ),
        );
      }).toList(),
    );
  }
}
