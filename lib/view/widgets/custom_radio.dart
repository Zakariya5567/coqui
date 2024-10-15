import 'package:coqui/view/widgets/extention/int_extension.dart';
import 'package:coqui/view/widgets/extention/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';

class CustomRadio extends StatelessWidget {
  const CustomRadio(
      {super.key,
        required this.isActive,
        this.radioActiveColor,
        required this.onTap,
        this.radioSize});

  final VoidCallback onTap;
  final bool isActive;
  final Color? radioActiveColor;
  final double? radioSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: radioSize ?? 50.h,
      width: radioSize ?? 50.h,
      decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: radioActiveColor ?? AppColor.greenPrimary),
      ),
      child: Container(
        height: 50.h,
        width: 50.h,
        decoration: BoxDecoration(
          color: isActive == true
              ? (radioActiveColor ?? AppColor.greenPrimary)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
      ).paddingAll(2.0),
    ).onPress(onTap);
  }
}

class CustomRadioWithoutTap extends StatelessWidget {
  const CustomRadioWithoutTap(
      {super.key,
        required this.isActive,
        this.radioActiveColor,
        this.radioSize});

  final bool isActive;
  final Color? radioActiveColor;
  final double? radioSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: radioSize ?? 20.h,
      width: radioSize ?? 20.h,
      decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: radioActiveColor ?? AppColor.greenPrimary),
      ),
      child: Container(
        height: 20.h,
        width: 20.h,
        decoration: BoxDecoration(
          color: isActive == true
              ? (radioActiveColor ?? AppColor.greenPrimary)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
      ).paddingAll(2.0),
    );
  }
}