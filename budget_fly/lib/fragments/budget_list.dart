import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sembast/sembast.dart';
import 'dart:async';
import 'package:budget_fly/share/database_common.dart';
import 'package:budget_fly/share/database_common.dart'
    show DBCommon, BudgetItem;

Future<List<Record>> fetchBudgetItems() async {
  Store storeOut;
  await DBCommon().getStore("budget")
    .then((store)=>
      storeOut=store);
  
  if(storeOut !=null)
    return storeOut.records.toList();
  else
    return null;
}

List<_BudgetListItem> _buildList(AsyncSnapshot snapshot) {
  List<Record> records = snapshot.data;
  List<_BudgetListItem> items= new List<_BudgetListItem>();
  if(records!=null){
    records.forEach((Record record){
      BudgetItem bi = DBCommon().mapToBudgetItem(record);
      items.add(new _BudgetListItem(bi));
    });
    
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
    return FutureBuilder<List<Record>>(
      future: fetchBudgetItems(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if(snapshot.data!=null){
            return new Column(children: <Widget>[
              new Expanded(
                child: new ListView(
                  children: _buildList(snapshot,)
                )
              )
            ],
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
