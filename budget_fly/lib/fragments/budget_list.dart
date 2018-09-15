import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sembast/sembast.dart';
import 'package:budget_fly/pages/home_page.dart';
import '../fragments/add_budget_item.dart';
import 'dart:async';
import 'dart:io';
import 'package:budget_fly/share/database_common.dart'
    show DBCommon, BudgetItem, BudgetItemType, BudgetSettingsModel;

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
    records.sort((a, b) => compareRecordDayDue(a,b));

    DateTime now = new DateTime.now();

    records.forEach((Record record) {
      BudgetItem bi = DBCommon().mapToBudgetItem(record);
      if (bi.dayDue.day.compareTo(now.day) >= 0) {
        topItems.add(bi);
      } else {
        items.add(bi);
      }
    });
    topItems.addAll(items);
  }
  return topItems;
}

int compareRecordDayDue(Record a, Record b){
  DateTime aDate = DBCommon().parseDayDue(a.value[0]["dayDue"]);
  DateTime bDate = DBCommon().parseDayDue(a.value[0]["dayDue"]);
  return aDate.difference(bDate).inDays;
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
  Color fontColor = Colors.blue;
  if(budgetItem.dayDue.day <= DateTime.now().day ){
    fontColor = Colors.grey;
  }

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
            text: budgetItem.dayDue.day.toString(),
            style: new TextStyle(
              color: fontColor, 
              fontWeight: FontWeight.bold, 
              
              ),
            
            
          )
        ]
      )
    );
  
  return subtitle;
}


