import 'dart:ffi';

import 'package:coqui/helper/connection_checker.dart';
import 'package:coqui/helper/database_helper.dart';
import 'package:coqui/helper/shared_preferences.dart';
import 'package:coqui/models/file_model.dart';
import 'package:coqui/services/dropbox_services.dart';
import 'package:coqui/view/widgets/custom_snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  DatabaseHelper databaseHelper = DatabaseHelper();
  DropboxService dropboxService = DropboxService();

  String selectedFiler = "all"; // Default to showing all books
  String selectedSort = "ascending"; // Default sort order

  // Set the selected filter (read/unread/all)
  void setSelectedFilter(String filter) {
    selectedFiler = filter;
    update();
    fetchAllFiles();
  }

  // Set the selected sort option (ascending/descending)
  void setSelectedSort(String sort) {
    selectedSort = sort;
    update();
    fetchAllFiles();
  }

  TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  setSearching() {
    isSearching = !isSearching;
    if (isSearching == false) {
      searchController.clear();
      fetchAllFiles();
    }
    update();
  }

  clearData() {
    selectedFiler = "all";
    selectedSort = "ascending";
    searchController.clear();
    update();
  }

  bool isLoading = false;
  setLoading(bool loading) {
    isLoading = loading;
    update();
  }

  Future<void> getServices() async {
    final hasInternet = await checkInternet();
    if (!hasInternet) return;
    setLoading(true);
    bool? isAuthorized = await SharedPref.getUserAuthorization;
    try {
      bool? initialize = await dropboxService.initDropbox();
      if (initialize == true) {
        ///Check before submit
        ///isAuthorized != true
        if (isAuthorized != true) {
          final status = await dropboxService.authorize();
          if (status == true) {
            SharedPref.storeUserAuthorization(true);
            //This statement is not working fine will check the issue in the plugin used
            String? token = await dropboxService.getAccessToken();
            await SharedPref.storeAccessToken(token);
            await authenticateWithAccessTokenAndSync();
          }
        } else {
          await authenticateWithAccessTokenAndSync();
        }
        setLoading(false);
      } else {
        setLoading(false);
      }
    } catch (e) {
      setLoading(false);
      SharedPref.storeUserAuthorization(false);
      showToast(
          message: "Something Went Wrong. Please try again later",
          isError: true);
    }
  }

  Future<void> authenticateWithAccessTokenAndSync() async {
    String? token =
        'sl.B--k1uplvyrTtu4bdd6yLe9or5KCqeZ38U12HDuCrkWnnlrsqvw6_Crzcy1qHuyGyHojAnwW8sxUBW59bRHFYTWghtkTBuJVlGgDPYcH470UPhJlZDE4_Tps6_5V-JnxKC0qnk4ti5rbEd_fhr4sAqA';
    //await SharedPref.getAccessToken;
    try {
      if (token != null) {
        final authorizedWithToken =
            await dropboxService.authorizeWithAccessToken(token);
        if (authorizedWithToken == true) {
          SharedPref.storeUserAuthorization(true);
          await dropboxService.syncDropboxFiles();
          await fetchAllFiles();
        } else {
          SharedPref.storeUserAuthorization(false);
          showToast(
              message: "Authorization Error : Please Authorized with Dropbox",
              isError: true);
        }
      } else {
        SharedPref.storeUserAuthorization(false);
        showToast(
            message: "Authorization Error : Please Authorized with Dropbox",
            isError: true);
      }
    } catch (e) {
      SharedPref.storeUserAuthorization(false);
      showToast(
          message: "$e Authorization Error : Please Authorized with Dropbox",
          isError: true);
    }
  }

  List<FileModel> files = [];

  Future<void> fetchAllFiles() async {
    files = [];

    // Fetch files with the selected filter and sorting
    files = await databaseHelper.fetchFilesFromDatabase(
      filterByStatus: selectedFiler, // Filter by read/unread/all
      sortOrder: selectedSort, // Ascending or Descending
    );
    update(); // Update the UI with the fetched data
  }

  Future<void> fetchSearchFiles() async {
    files = [];
    // Fetch files with the search text, selected filter, and selected sort order
    files = await databaseHelper.fetchSearchFilesFromDatabase(
      searchText: searchController.text,
      filterByStatus: selectedFiler, // Filter by read/unread/all
      sortOrder: selectedSort, // Ascending or Descending
    );
    update(); // Update the UI with the fetched data
  }
}
