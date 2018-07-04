import 'package:flutter/material.dart';
import 'package:sembast/sembast.dart';
import 'dart:async';
import 'package:budget_fly/share/database_common.dart';

class BudgetList extends StatelessWidget {

  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Center(
      child: new Text("Hello Fragment 1"),
    );
  }

  Future<List<Record>> getRecords() async{
    Store budgetStore = await DBCommon().getStore("budget");
    
    num count = await budgetStore.count();
    List<Record> data = await budgetStore.findRecords(Finder());
    return data;
  }
  
}

