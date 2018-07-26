import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sembast/sembast.dart';
import 'package:budget_fly/fragments/add_budget_item.dart';
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

List<_BudgetListItem> _buildList(AsyncSnapshot snapshot, BuildContext context, ValueNotifier<Widget> notifier) {
  List<Record> records = snapshot.data;
  List<_BudgetListItem> items= new List<_BudgetListItem>();
  List<_BudgetListItem> topItems = new List<_BudgetListItem>();
  if(records!=null){
    records.sort(
      (a,b)=>
          int.parse(a.value[0]["dayDue"]).compareTo(int.parse(b.value[0]["dayDue"]))
              );

    // records.forEach((Record record){
    //   if 
    // });          
    DateTime now = new DateTime.now();
    
    records.forEach((Record record){
      BudgetItem bi = DBCommon().mapToBudgetItem(record);
      if(bi.dayDue.compareTo(now.day)>=0){
        topItems.add(new _BudgetListItem(bi, context, notifier));
      }
      else{
        items.add(new _BudgetListItem(bi, context, notifier));
      }
    });
    topItems.addAll(items);
    
  }
  return topItems;
}



class BudgetList extends StatefulWidget {
  final ValueNotifier<Widget> notifier;
  BudgetList({Key key, this.notifier}) : super(key: key);

  @override
  _BudgetListState createState() => new _BudgetListState(notifier);
}

class _BudgetListState extends State<BudgetList>{
  final ValueNotifier<Widget> notifier;

  _BudgetListState(this.notifier);

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
                  children: _buildList(snapshot,context, notifier)
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
  _BudgetListItem(BudgetItem budgetItem, BuildContext context, ValueNotifier<Widget> notifier)
      : super(
          isThreeLine: true,
          title: new Text(budgetItem.name),
          subtitle: new Text(budgetItem.dayDue.toString() +
              " " +
              budgetItem.amount.toString() +
              " " +
              budgetItem.itemType.toString().split('.')[1]),
          onTap: () { _editBudgetItem(context, budgetItem, notifier); }
        );
}

_editBudgetItem(BuildContext context, BudgetItem budgetItem, ValueNotifier<Widget> notifier){
    notifier.value = AddBudgetItem(recordKey: budgetItem.key, notifier: notifier);
    // Widget
    // Navigator.defaultRouteName;
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AddBudgetItem(recordKey: budgetItem.key,)));
}

