import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sembast/sembast.dart';
import 'dart:async';
import 'package:budget_fly/share/database_common.dart';
import 'package:budget_fly/share/database_common.dart'
    show budgetItemType, DBCommon, BudgetItem;

Future<List<_BudgetListItem>> fetchBudgetItems() async {
  final store = await DBCommon().getStore("budget");
  List<Record> records = await store.records.toList();
  List<_BudgetListItem> items;
  items = new List<_BudgetListItem>();
  records.forEach((Record record){
    items.add(new _BudgetListItem(DBCommon().mapToBudgetItem(record)));
  });
  return items;
}

class BudgetList extends StatefulWidget {
  BudgetList({Key key}) : super(key: key);

  @override
  _BudgetListState createState() => new _BudgetListState();
}

class _BudgetListState extends State<BudgetList> {
  List<BudgetItem> _budgetItems = new List<BudgetItem>();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<_BudgetListItem>>(
      future: fetchBudgetItems(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return new ListView(
              children: snapshot.data
          );
        }
        
        if(snapshot.hasError)
          return Text("${snapshot.error}");
        return CircularProgressIndicator();
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
              budgetItem.itemType.toString()),
        );
}
