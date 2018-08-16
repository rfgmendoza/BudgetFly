import 'package:flutter/material.dart';
import 'package:sembast/sembast.dart';
import 'package:budget_fly/pages/home_page.dart';
import 'package:budget_fly/share/database_common.dart' show DBCommon;

class BudgetConfig extends StatefulWidget {
  @override
  BudgetConfigState createState() {
    return BudgetConfigState();
  }
}

class BudgetConfigState extends State<BudgetConfig> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          // here we display the title corresponding to the fragment
          // you can instead choose to have a static title
          title: Text("Budget Settings"),
        ),
        drawer: getDrawer(context),
        body: ListView(
          children: <Widget>[
            new Text("settings page"),
            new Padding(
              padding: EdgeInsets.all(8.0),
              child: new TextField(
              decoration: InputDecoration(
                
                hintText: 'Enter your income per pay period'

                
              ),
            )
            )
            //payCheckCard(),
          ],
        ));
  }
}

getCard(List<Widget> content) {
  return Card(
      child: new Column(
    mainAxisSize: MainAxisSize.min,
    children: content,
  ));
}

payCheckCard() {
  List<Widget> content = new List<Widget>();
  content.add(new Text("Income"));
  content.add(new Text("35000"));
  content.add(new ButtonBar(
    children: <Widget>[
      new FlatButton(
        child: const Text("Edit"),
        onPressed: (){
           //create dialog 
        }
      ),
      new FlatButton(
        child: const Text("Schedule"),
        onPressed: (){

        },
        ) 
    ],
  ));
}
