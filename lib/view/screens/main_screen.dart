import 'package:coqui/controller/home_controller.dart';
import 'package:coqui/helper/database_helper.dart';
import 'package:coqui/helper/debouncer.dart';
import 'package:coqui/main.dart';
import 'package:coqui/services/dropbox_services.dart';
import 'package:coqui/utils/colors.dart';
import 'package:coqui/utils/icons.dart';
import 'package:coqui/utils/style.dart';
import 'package:coqui/view/screens/book_grid_view.dart';
import 'package:coqui/view/screens/book_list_view.dart';
import 'package:coqui/view/screens/pdf_reader_screen.dart';
import 'package:coqui/view/shimmers/book_grid_shimmer.dart';
import 'package:coqui/view/shimmers/book_list_shimmer.dart';
import 'package:coqui/view/widgets/button_icon.dart';
import 'package:coqui/view/widgets/custom_text_field.dart';
import 'package:coqui/view/widgets/extention/int_extension.dart';
import 'package:coqui/view/widgets/extention/string_extension.dart';
import 'package:coqui/view/widgets/extention/widget_extension.dart';
import 'package:coqui/view/widgets/filter_bottomsheet.dart';
import 'package:coqui/view/widgets/no_data_found.dart';
import 'package:dropbox_client/dropbox_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

import 'package:get/get.dart';

import '../widgets/sort_bottomsheet.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  DatabaseHelper db = DatabaseHelper();
  DropboxService dropboxService = DropboxService();
  HomeController homeController = Get.put(HomeController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Debouncer debouncer = Debouncer(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    homeController.clearData();
    homeController.fetchAllFiles();
   // homeController.getServices();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppColor.defaultStatusBar,
      child: GetBuilder(
          init: HomeController(),
          builder: (context) {
            return Scaffold(
              key: _scaffoldKey,
              backgroundColor: AppColor.blackSecondary,
              appBar: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: AppColor.blackPrimary,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(icon: const Icon(Icons.sync),
                        onPressed: (){
                         homeController.getServices();
                        }),
                      homeController.isSearching?
                      CustomTextField(
                          width: 2300.w,
                          hintText: "Search",
                          fillColor: AppColor.whitePrimary,
                          controller: homeController.searchController,
                          onChanged: (value){
                            debouncer.run((){
                              homeController.fetchSearchFiles();
                            });
                          },
                          suffixIcon: ButtonIcon(
                            color: AppColor.blackPrimary,
                            icon: AppIcons.iconCross,
                            onTap: (){
                                homeController.setSearching();
                            },
                          ),
                      ): const SizedBox(),
                      Row(
                        children: [
                          IconButton(
                           icon: const Icon(Icons.search),
                            onPressed: (){
                              homeController.setSearching();
                            },),
                          IconButton(
                          icon: const Icon(Icons.filter_alt_outlined),
                            onPressed: (){
                            filterBottomSheet();
                          },),
                          IconButton(
                             icon: const Icon(Icons.sort),
                            onPressed: (){
                              sortBottomSheet();
                            },),
                        ],
                      )

                    ],
                  )

              ),
              floatingActionButton: FloatingActionButton(
                onPressed: (){
                  homeController.fetchAllFiles();
                  //db.clearDatabase();setState(() {});
                  },
              ),
              body: homeController.isLoading == true ?
              (homeController.sortBy == "Grid"? const BookGridShimmer() :const BookListShimmer()):
                  homeController.files.isEmpty?
                      const NoDataFound(icon: AppIcons.iconBook, title: "No Books Found"):
                  Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: homeController.sortBy == "Grid"?
                      BookGridView(homeController: homeController):
                      BookListView(homeController: homeController),

              )

            );
          }),
    );
  }
}
