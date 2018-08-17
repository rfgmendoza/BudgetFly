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

/* Budget config page:
- pay check
- pay period/schedule
   - x-weekly (starting on y day)
   - on certain days off the month
   - variable
 - utility bill arrival dates
   - as many as needed ( for checking the monthly bill amount)
   */

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
                      hintText: 'Enter your income per pay period'),
                )),

            getCard(payCheckContent()),
            getCard(new List<Widget>())
            
            //payCheckCard(),
          ],
        ));
  }
}

getCard(List<Widget> content) {
  return Container(
    height: 124.0,
    margin: new EdgeInsets.all(8.0),
      decoration: new BoxDecoration(
       
      shape: BoxShape.rectangle,
      borderRadius: new BorderRadius.circular(8.0),
      boxShadow: <BoxShadow>[
        new BoxShadow(  
          color: Colors.black12,
          blurRadius: 10.0,
          offset: new Offset(0.0, 10.0),
        ),
      ],
    ),
      child: Card(
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            children: content,
  )));
}

payCheckContent() {
  List<Widget> content = new List<Widget>();
  content.add(new Text("Income"));
  content.add(new Text("35000"));
  content.add(new ButtonBar(
    children: <Widget>[
      new FlatButton(
          child: const Text("Edit"),
          onPressed: () {
            //create dialog
          }),
      new FlatButton(
        child: const Text("Schedule"),
        onPressed: () {},
      )
    ],
  ));
  return content;
}

payPeriodContent(){

}


