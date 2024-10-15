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
  String selectedFiler = "Name";
  setSelectedFilter(String filter){
    selectedFiler = filter;
    update();
  }

  TextEditingController searchController = TextEditingController();
  bool isSearching = false;
   setSearching(){
     isSearching = !isSearching;
     if(isSearching == false){
       searchController.clear();
     }
     update();
  }

  String sortBy = "Grid";
  setSortBy(String sort){
    sortBy = sort;
    update();
  }

  clearData(){
     sortBy = "Grid";
     isSearching = false;
     selectedFiler = "Name";
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
    if(!hasInternet) return;
    setLoading(true);
    bool? isAuthorized = await SharedPref.getUserAuthorization;
    try{
      bool? initialize = await dropboxService.initDropbox();
      if (initialize == true) {
        ///Check before submit
        ///isAuthorized != true
       if(isAuthorized != true){
         final status = await dropboxService.authorize();
         if(status == true){
             SharedPref.storeUserAuthorization(true);
             //This statement is not working fine will check the issue in the plugin used
            String? token =  await dropboxService.getAccessToken();
            await SharedPref.storeAccessToken(token);
            await authenticateWithAccessTokenAndSync();
         }
       }else{
         await authenticateWithAccessTokenAndSync();
       }
        setLoading(false);
      } else {
        setLoading(false);
      }
    }catch(e){
      setLoading(false);
      SharedPref.storeUserAuthorization(false);
      showToast(message: "Something Went Wrong. Please try again later", isError: true);
    }
  }

  Future<void> authenticateWithAccessTokenAndSync()async{
    String? token = await SharedPref.getAccessToken;
    if(token != null){
    final authorizedWithToken = await dropboxService.authorizeWithAccessToken(token);
    if(authorizedWithToken == true){
      SharedPref.storeUserAuthorization(true);
      await dropboxService.syncDropboxFiles();
      await fetchAllFiles();
    }else{
      SharedPref.storeUserAuthorization(false);
      showToast(message: "Authorization Error : Please Authorized with Dropbox", isError: true);
    }
  }else{
  SharedPref.storeUserAuthorization(false);
  showToast(message: "Authorization Error : Please Authorized with Dropbox", isError: true);
  }}


  List<FileModel> files = [];

  Future<void> fetchAllFiles() async {
    files = [];
    files = await databaseHelper.fetchAllFilesFromDatabase();
    update();// Fetch from SQLite
  }

  Future<void> fetchSearchFiles() async {
    files = [];
    files = await databaseHelper.fetchSearchFilesFromDatabase(
        searchText: searchController.text,
        searchByTitle: selectedFiler== "Name" ? true : false);
    update();// Fetch from SQLite
  }
}
