
import '../fragments/budget_list.dart';
import '../fragments/add_budget_item.dart';
import 'package:budget_fly/fragments/budget_config.dart';
import '../fragments/budget_summary.dart';

import 'package:flutter/material.dart';

class DrawerItem {
  String title;
  IconData icon;
  DrawerItem(this.title, this.icon);
}

class HomePage extends StatefulWidget {
  

  @override
  State<StatefulWidget> createState() {
    return new HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  int _selectedDrawerIndex = 0;
  GlobalKey _homepagekey=  new GlobalKey<ScaffoldState>();
  
  _getDrawerItemWidget(int pos, GlobalKey<ScaffoldState> key) {
    switch (pos) {
      case 0:
        return new BudgetSummary();
      case 1:
        return new BudgetList(homepagekey: _homepagekey);
      case 2: 
        return new AddBudgetItem();
      case 3:
        return new BudgetConfig();
      

      default:
        return new Text("Error");
    }
  }
  
  @override
  Widget build(BuildContext context) {
    

    return new Scaffold(
      key: _homepagekey,
      appBar: new AppBar(
        // here we display the title corresponding to the fragment
        // you can instead choose to have a static title
        title: new Text("test"),
      ),
      drawer: getDrawer(context),
      body: _getDrawerItemWidget(_selectedDrawerIndex, _homepagekey),
      
    );
  }
}

_getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        return new BudgetSummary();
      case 1:
        return new BudgetList();
      case 2: 
        return new AddBudgetItem();
      case 3:
        return new BudgetConfig();

      default:
        return new Text("Error");
    }
  }

Drawer getDrawer(BuildContext context){

  final drawerItems = [
    new DrawerItem("Summary", Icons.dashboard),
    new DrawerItem("Budget List", Icons.list),
    new DrawerItem("Add Budget Item", Icons.add),
    new DrawerItem("Settings", Icons.settings)
  ];
  var drawerOptions = <Widget>[];
    for (var i = 0; i < drawerItems.length; i++) {
      var d = drawerItems[i];
      drawerOptions.add(
        new ListTile(
          leading: new Icon(d.icon),
          title: new Text(d.title),          
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=>_getDrawerItemWidget(i)));
          },
        )
      );
    }

  return new Drawer(
        child: new Column(
          
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Budget Fly", style: TextStyle(color: Colors.white, fontSize: 20.0),),
                ],
              ),
              decoration: BoxDecoration(color: Colors.green),
            ),
          
            new Column(children: drawerOptions)
          ],
        ),
      );
}


