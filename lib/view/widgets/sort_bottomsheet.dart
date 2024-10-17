import 'package:coqui/controller/home_controller.dart';
import 'package:coqui/main.dart';
import 'package:coqui/utils/icons.dart';
import 'package:coqui/utils/style.dart';
import 'package:coqui/view/widgets/custom_radio.dart';
import 'package:coqui/view/widgets/extention/int_extension.dart';
import 'package:coqui/view/widgets/extention/string_extension.dart';
import 'package:coqui/view/widgets/extention/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';
import '../../utils/constant.dart';
import 'button_icon.dart';

sortBottomSheet() {
  return showModalBottomSheet(
    backgroundColor: Colors.transparent,
    context: navKey.currentContext!,
    builder: (BuildContext context) {
      return GetBuilder<HomeController>(builder: (controller) {
        return Container(
          height: 1500.h,
          decoration: const BoxDecoration(
            color: AppColor.blackSecondary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ButtonIcon(
                      height: 90.h,
                      width: 90.h,
                      icon: AppIcons.iconCross,
                      onTap: () {
                        Get.back();
                      },
                    ),
                    AppConstant.sortBy.toText(
                      color: AppColor.whitePrimary,
                      fontFamily: AppStyle.gothamMedium,
                      fontSize: 36,
                    ),
                    30.width,
                  ],
                ),
                50.height,

                // Sort by Author
                SortItem(
                  title: "Author",
                  iconData: Icons.person,
                  onTap: () {
                    controller.setSelectedSort("author");
                    Get.back();
                  },
                  isActive: controller.selectedSort == "author",
                ),

                // Sort by Book Title
                SortItem(
                  title: "Book Title",
                  iconData: Icons.book,
                  onTap: () {
                    controller.setSelectedSort("title");
                    Get.back();
                  },
                  isActive: controller.selectedSort == "title",
                ),

                // Sort by Date Published
                SortItem(
                  title: "Date Published",
                  iconData: Icons.date_range,
                  onTap: () {
                    controller.setSelectedSort("datePublished");
                    Get.back();
                  },
                  isActive: controller.selectedSort == "datePublished",
                ),

                // Sort by Date Downloaded
                SortItem(
                  title: "Date Downloaded",
                  iconData: Icons.download,
                  onTap: () {
                    controller.setSelectedSort("dateDownloaded");
                    Get.back();
                  },
                  isActive: controller.selectedSort == "dateDownloaded",
                ),

                SortItem(
                  title: "Ascending",
                  iconData: Icons.arrow_upward,
                  onTap: () {
                    controller.setSelectedSort("ascending");
                    Get.back();
                  },
                  isActive: controller.selectedSort == "ascending",
                ),
                SortItem(
                  title: "Descending",
                  iconData: Icons.arrow_downward,
                  onTap: () {
                    controller.setSelectedSort("descending");
                    Get.back();
                  },
                  isActive: controller.selectedSort == "descending",
                ),
              ],
            ).paddingSymmetric(horizontal: 40.w, vertical: 40.h),
          ),
        );
      });
    },
  );
}

class SortItem extends StatelessWidget {
  const SortItem({
    super.key,
    required this.onTap,
    required this.title,
    required this.isActive,
    required this.iconData,
  });

  final String title;
  final VoidCallback onTap;
  final bool isActive;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120.h,
      color: AppColor.blackPrimary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                iconData,
                color: AppColor.whitePrimary,
              ),
              20.width,
              title.toText(
                color: AppColor.whitePrimary,
                fontFamily: AppStyle.gothamRegular,
                fontSize: 28,
              ),
            ],
          ),
          CustomRadio(isActive: isActive, onTap: onTap)
        ],
      ).paddingAll(28.h),
    ).paddingOnly(bottom: 10.h).onPress(onTap);
  }
}
