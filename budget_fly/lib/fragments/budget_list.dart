import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sembast/sembast.dart';
import 'package:budget_fly/pages/home_page.dart';
import '../fragments/add_budget_item.dart';
import 'dart:async';
import 'dart:io';
import 'package:budget_fly/share/database_common.dart'
    show DBCommon, BudgetItem, BudgetItemType;

Future<List<Record>> fetchBudgetItems() async {
  Store storeOut;
  await DBCommon().getStore("budget").then((store) => storeOut = store);

  if (storeOut != null)
    return storeOut.records.toList();
  else
    return null;
}

List<BudgetItem> _buildList(AsyncSnapshot snapshot) {
  List<Record> records = snapshot.data;
  List<BudgetItem> items = new List<BudgetItem>();
  List<BudgetItem> topItems = new List<BudgetItem>();
  if (records != null) {
    records.sort((a, b) => int
        .parse(a.value[0]["dayDue"])
        .compareTo(int.parse(b.value[0]["dayDue"])));

    // records.forEach((Record record){
    //   if
    // });
    DateTime now = new DateTime.now();

    records.forEach((Record record) {
      BudgetItem bi = DBCommon().mapToBudgetItem(record);
      if (bi.dayDue.compareTo(now.day) >= 0) {
        topItems.add(bi);
      } else {
        items.add(bi);
      }
    });
    topItems.addAll(items);
  }
  return topItems;
}

class BudgetList extends StatefulWidget {
  final GlobalKey<ScaffoldState> homepagekey;

  BudgetList({Key key, this.homepagekey}) : super(key: key);

  @override
  _BudgetListState createState() => new _BudgetListState();
}

class _BudgetListState extends State<BudgetList> {
  Future<List<Record>> budgetItemsFuture = fetchBudgetItems();
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          // here we display the title corresponding to the fragment
          // you can instead choose to have a static title
          title: new Text("test"),
        ),
        drawer: getDrawer(context),
        body: FutureBuilder<List<Record>>(
          future: budgetItemsFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data != null) {
                List<BudgetItem> items = _buildList(snapshot);
                return new Column(
                  children: <Widget>[
                    new Expanded(
                        child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Dismissible(
                            key: Key(item.record.toString()),
                            onDismissed: (direction) {
                              DBCommon().deleteBudgetItem(item.record);

                              Scaffold.of(context).showSnackBar(SnackBar(
                                  content: Text("budget item removed")));

                              sleep(const Duration(seconds: 2));

                              Navigator
                                  .of(context)
                                  .pushReplacementNamed('/list');
                            },
                            background: Container(color: Colors.red, ),
                            child: ListTile(
                              title:
                                  Text(item.name.toUpperCase()),
                              subtitle:  _formateSubtitle(item),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => new AddBudgetItem(
                                            budgetItem: item)));
                              },
                              leading: _getIcon(item),
                              trailing: Icon(Icons.edit),                              
                            ));
                      },
                    ))
                  ],
                );
              }
            } else if (snapshot.hasError)
              return Text("${snapshot.error}");
            // if(!snapshot.hasData){
            //   return new Center(child: new Text("No data exists yet!"));
            // }
            else
              return new Center(child: CircularProgressIndicator());
          },
        ));
  }
}

_getIcon(BudgetItem budgetItem){

  switch (budgetItem.itemType) {
    case BudgetItemType.bill: 
      return Icon(Icons.mail_outline);
      break;
    case BudgetItemType.creditCard:
      return Icon(Icons.credit_card);
      break;
    case BudgetItemType.subscription:
      return Icon(Icons.subscriptions);
      break;
    default:
      return Icon(Icons.attach_money);
  }
}

RichText _formateSubtitle(BudgetItem budgetItem) {


  RichText subtitle = new RichText(
    text: new TextSpan(
        children: <TextSpan>[
          new TextSpan(
            text: "\$"+budgetItem.amount.toString()+"     ",
            style: new TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black
              )
          ),
          new TextSpan(
            text: "due on: ",
            style: TextStyle(color: Colors.black)
          ),          
          new TextSpan(
            text: budgetItem.dayDue.toString(),
            style: new TextStyle(
              color: Colors.blue, 
              fontWeight: FontWeight.bold, 
              
              ),
            
            
          )
        ]
      )
    );
  //subtitle += "\$" + budgetItem.amount.toString();
  //subtitle += " due on: " + budgetItem.dayDue.toString();
  return subtitle;
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
            onTap: () {});
}
