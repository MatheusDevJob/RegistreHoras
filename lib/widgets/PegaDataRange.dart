import 'package:flutter/material.dart';

class PegaDataRange extends StatefulWidget {
  final Widget body;
  final Function(DateTime, DateTime) funcao;
  const PegaDataRange({super.key, required this.body, required this.funcao});

  @override
  State<PegaDataRange> createState() => _PegaDataRangeState();
}

class _PegaDataRangeState extends State<PegaDataRange> {
  Future<void> pickDateRange() async {
    DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedRange != null) widget.funcao(pickedRange.start, pickedRange.end);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: pickDateRange,
      child: widget.body,
    );
  }
}
