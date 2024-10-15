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
      return
        GetBuilder<HomeController>(
          builder:(controller) {
            return Container(
            height: 700.h,
            decoration: const BoxDecoration(
                color: AppColor.blackSecondary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                )),
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
                        icon: AppIcons.iconCross,onTap: (){Get.back();},),
                     AppConstant.sortBy.toText(color: AppColor.whitePrimary,fontFamily: AppStyle.gothamMedium,fontSize: 36),
                      30.width,
                    ],
                  ),
                  50.height,
                  SortItem(
                    iconData: Icons.grid_view_sharp,
                      onTap: (){
                        controller.setSortBy("Grid");
                        Get.back();
                      },
                      title: AppConstant.gridView,
                      isActive: controller.sortBy == "Grid" ? true :false,
                  ),
                  SortItem(
                    iconData: Icons.view_list_rounded,
                      onTap: (){
                      controller.setSortBy("List");
                      Get.back();
                      },
                      title:  AppConstant.listView,
                      isActive: controller.sortBy == "List" ? true :false,
                  )
                ],
              ).paddingSymmetric(horizontal: 40.w, vertical: 40.h),
            ),
                  );
          }
        );
    },
  );
}
class SortItem extends StatelessWidget {
  const SortItem({super.key,required this.onTap,required this.title,required this.isActive,required this.iconData});

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
              Icon(iconData,color: AppColor.whitePrimary,),
              20.width,
              title.toText(color: AppColor.whitePrimary,fontFamily: AppStyle.gothamRegular,fontSize: 28),
            ],
          ),
           CustomRadio(isActive: isActive, onTap: onTap)
        ],
      ).paddingAll(28.h),
    ).paddingOnly(bottom: 10.h).onPress(onTap);
  }
}

