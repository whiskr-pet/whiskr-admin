import 'package:flutter/material.dart';
import 'package:w_utils/color_helper/color_helper.dart';

class InventoryServicesScreen extends StatelessWidget {
  const InventoryServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _BuildBody());
  }
}

class _BuildBody extends StatelessWidget {
  const _BuildBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Column(children: [_BuildHeader()]),
    );
  }
}

class _BuildHeader extends StatelessWidget {
  const _BuildHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // todo - check type and show correct header
        Text('Inventory', style: theme.textTheme.headlineMedium!.copyWith(fontSize: 24)),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: headerInfoList.map((HeaderInventoryModelHelper e) => _BuildHeaderContainer(color: e.color, title: e.title, value: e.value)).toList(),
        ),
      ],
    );
  }
}

class _BuildHeaderContainer extends StatelessWidget {
  const _BuildHeaderContainer({this.value = 'XXX', this.title = 'total', this.color = Colors.lightGreen});

  final String value;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 340,
      height: 43,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: color),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold, color: ColorHelper.white.color),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: theme.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold, color: ColorHelper.white.color),
          ),
        ],
      ),
    );
  }
}

class HeaderInventoryModelHelper {
  HeaderInventoryModelHelper(this.color, this.title, this.value);

  final String value;
  final String title;
  final Color color;
}

List<HeaderInventoryModelHelper> headerInfoList = [
  HeaderInventoryModelHelper(Color.fromRGBO(152, 188, 109, 1), 'total', '123'),
  HeaderInventoryModelHelper(Color.fromRGBO(242, 163, 0, 1), 'low stock', '12'),
  HeaderInventoryModelHelper(Color.fromRGBO(236, 76, 14, 1), 'out of stock', '7'),
];
