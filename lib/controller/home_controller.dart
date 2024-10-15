import 'dart:ffi';

import 'package:coqui/helper/connection_checker.dart';
import 'package:coqui/helper/database_helper.dart';
import 'package:coqui/models/file_model.dart';
import 'package:coqui/services/dropbox_services.dart';
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

    try{
      setLoading(true);
      bool? initialize = await dropboxService.initDropbox();
      if (initialize == true) {
        //await dropboxService.authorize();
        await dropboxService.authorizeWithAccessToken();
        await dropboxService.syncDropboxFiles();
        setLoading(false);
      } else {
        setLoading(false);
      }
    }catch(e){
      print(e);
      setLoading(false);
    }

  }

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
