import 'package:coqui/controller/home_controller.dart';
import 'package:coqui/helper/database_helper.dart';
import 'package:coqui/helper/debouncer.dart';
import 'package:coqui/main.dart';
import 'package:coqui/services/dropbox_services.dart';
import 'package:coqui/utils/colors.dart';
import 'package:coqui/utils/icons.dart';
import 'package:coqui/utils/style.dart';
import 'package:coqui/view/screens/pdf_reader_screen.dart';
import 'package:coqui/view/shimmers/book_grid_shimmer.dart';
import 'package:coqui/view/widgets/button_icon.dart';
import 'package:coqui/view/widgets/custom_text_field.dart';
import 'package:coqui/view/widgets/extention/int_extension.dart';
import 'package:coqui/view/widgets/extention/string_extension.dart';
import 'package:coqui/view/widgets/extention/widget_extension.dart';
import 'package:coqui/view/widgets/filter_bottomsheet.dart';
import 'package:coqui/view/widgets/no_data_found.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

import 'package:get/get.dart';

class BookListView extends StatelessWidget {
  const BookListView({super.key,required this.homeController});
  final HomeController homeController;
  @override
  Widget build(BuildContext context) {
    return  ListView.builder(
        itemCount:  homeController.files.length,
        shrinkWrap: true,
        itemBuilder: (context,index){
          final file = homeController.files[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PDFReaderScreen(filePath: file.filePath ?? " ",fileName:file.title ?? " "),
                ),
              );
            },
            child: Container(
              height: 500.h,
              width: double.infinity,
              color: AppColor.blackPrimary,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 400.w,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColor.blackSecondary,
                      image: const DecorationImage(image: AssetImage(AppIcons.iconBook)),
                      border: Border.all(
                          color: AppColor.redPrimary,width: 0.2),
                    ),
                    child: file.thumbnailPath == null ? const SizedBox() : Image.memory(
                      file.thumbnailPath!,
                      fit: BoxFit.cover,
                    ),

                  ),
                  SizedBox(
                    width: 2400.w,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 2050.w,
                              child: (file.title ?? " ").toText(
                                  color: AppColor.whitePrimary,
                                  fontSize: 26,
                                  maxLine: 2,
                                  fontFamily: AppStyle.gothamMedium
                              ),),
                            Icon(
                              size: 50.h,
                              Icons.check_circle_outline_outlined,
                              color: AppColor.greenPrimary,)
                          ],
                        ),


                        10.height,
                        (file.author ?? " ").toText(
                            color: AppColor.whitePrimary,
                            fontSize: 22,
                            maxLine: 2,
                            fontFamily: AppStyle.gothamRegular
                        ),

                        30.height,
                        (file.description ?? " ").toText(
                            color: AppColor.whitePrimary,
                            fontSize: 22,
                            fontFamily: AppStyle.gothamRegular,
                            maxLine: 10
                        ),

                      ],
                    ).paddingAll(20.h),
                  )
                ],
              ),
            ).paddingOnly(bottom: 25.h),
          );
        }
    );
  }
}
