import 'package:coqui/view/widgets/extention/int_extension.dart';
import 'package:coqui/view/widgets/extention/widget_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../utils/colors.dart';
import '../../utils/icons.dart';

class BookListShimmer extends StatelessWidget {
  const BookListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap:  true,
        itemCount: 5,
        itemBuilder: (context,index){
          return
            Shimmer.fromColors(
              baseColor: AppColor.blackPrimary,
              highlightColor: AppColor.blackSecondary,
            child:
            Container(
             height: 500.h,
              width: double.infinity,
            color: AppColor.blackPrimary.withOpacity(0.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColor.blackSecondary,
                    image: const DecorationImage(image: AssetImage(AppIcons.iconBook)),
                    border: Border.all(
                        color: AppColor.redPrimary,width: 0.2),
                  ),
                  width: 400.w,
                  height: double.infinity,
                ),
                Container(
                  width: 2470.w,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      20.height,
                      Container(
                        width: 1400.w,
                        height: 50.h,
                        color: AppColor.blackSecondary,
                      ),

                      10.height,
                      Container(
                        width: 2400.w,
                        height: 50.h,
                        color: AppColor.blackSecondary,
                      ),
                      20.height,
                      Container(
                        width: 2400.w,
                        height: 50.h,
                        color: AppColor.blackSecondary,
                      ),
                      10.height,
                      Container(
                        width: 2400.w,
                        height: 50.h,
                        color: AppColor.blackSecondary,
                      ),
                      10.height,
                      Container(
                        width: 2400.w,
                        height: 50.h,
                        color: AppColor.blackSecondary,
                      ),
                      10.height,
                      Container(
                        width: 2400.w,
                        height: 50.h,
                        color: AppColor.blackSecondary,
                      ),
                      10.height,
                      Container(
                        width: 2400.w,
                        height: 50.h,
                        color: AppColor.blackSecondary,
                      ),

                    ],
                  ).paddingSymmetric(horizontal: 20.w),
                )
              ],
            ),
          ).paddingOnly(bottom: 20.h));
        }
    ).paddingAll(20.h);
  }
}

// class CustomerListShimmer extends StatelessWidget {
//   const CustomerListShimmer({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: ListView.builder(
//           padding: EdgeInsets.zero,
//           itemCount: 10,
//           shrinkWrap: true,
//           itemBuilder: (context, index) {
//             return Shimmer.fromColors(
//                 baseColor: AppColor.shimmerBaseColor,
//                 highlightColor: AppColor.shimmerHighlightColor,
//                 child: Container(
//                   height: 70.h,
//                   decoration: BoxDecoration(
//                       border: Border(
//                           bottom: BorderSide(
//                     color: AppColor.whitePrimary.withOpacity(0.5),
//                     width: 1.0,
//                   ))),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Container(
//                         height: 45.h,
//                         width: 45.h,
//                         alignment: Alignment.center,
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(10),
//                             color: AppColor.whitePrimary),
//                       ),
//                       5.width,
//                       SizedBox(
//                           height: 60.w,
//                           width: 130.w,
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Container(
//                                 height: 16.h,
//                                 width: 140.w,
//                                 color: AppColor.whitePrimary,
//                               ),
//                               5.height,
//                               Container(
//                                 height: 16.h,
//                                 width: 100.w,
//                                 color: AppColor.whitePrimary,
//                               ),
//                             ],
//                           )),
//                       10.width,
//                       SizedBox(
//                         width: 140.w,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             Container(
//                               height: 45.h,
//                               width: 45.h,
//                               alignment: Alignment.center,
//                               decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(10),
//                                   color: AppColor.whitePrimary),
//                             ),
//                             5.width,
//                             Container(
//                               height: 45.h,
//                               width: 45.h,
//                               alignment: Alignment.center,
//                               decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(10),
//                                   color: AppColor.whitePrimary),
//                             ),
//                           ],
//                         ),
//                       )
//                     ],
//                   ),
//                 ));
//           }).paddingSymmetric(horizontal: 16.w, vertical: 10.h),
//     );
//   }
// }
