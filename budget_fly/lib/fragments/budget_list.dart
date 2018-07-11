import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sembast/sembast.dart';
import 'dart:async';
import 'package:budget_fly/share/database_common.dart';
import 'package:budget_fly/share/database_common.dart'
    show DBCommon, BudgetItem;

Future<List<_BudgetListItem>> fetchBudgetItems() async {
  final store = await DBCommon().getStore("budget");
  List<_BudgetListItem> items;
  if(store!=null){
    List<Record> records=new List<Record>();
    await for(var record in store.records){
      if(record !=null)
      records.add(record);
    }    
      
    if(records != null){
      items = new List<_BudgetListItem>();
      records.forEach((Record record){
        BudgetItem bi = DBCommon().mapToBudgetItem(record);
        
        _BudgetListItem bli = new _BudgetListItem(bi);
        items.add(bli);
      });
    }
  }
  return items;
}

class BudgetList extends StatefulWidget {
  BudgetList({Key key}) : super(key: key);

  @override
  _BudgetListState createState() => new _BudgetListState();
}

class _BudgetListState extends State<BudgetList> {
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<_BudgetListItem>>(
      future: fetchBudgetItems(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if(snapshot.data!=null){
            return new ListView(
                children: snapshot.data
            );
          }
        }        
        else if(snapshot.hasError)
          return Text("${snapshot.error}");
        // if(!snapshot.hasData){
        //   return new Center(child: new Text("No data exists yet!"));
        // }  
        else return new Center(child: CircularProgressIndicator());
      },
    );
  }
}

class _BudgetListItem extends ListTile {
  _BudgetListItem(BudgetItem budgetItem)
      : super(
          isThreeLine: true,
          title: new Text(budgetItem.name),
          subtitle: new Text(budgetItem.dayDue.toString() +
              " " +
              budgetItem.amount.toString() +
              " " +
              budgetItem.itemType.toString().split('.')[1]),
        );
}
