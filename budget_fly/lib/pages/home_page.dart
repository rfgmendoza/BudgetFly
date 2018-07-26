
import 'package:budget_fly/fragments/budget_list.dart';
import 'package:budget_fly/fragments/add_budget_item.dart';
import 'package:budget_fly/fragments/third_fragment.dart';

import 'package:flutter/material.dart';

class DrawerItem {
  String title;
  IconData icon;
  DrawerItem(this.title, this.icon);
}

class HomePage extends StatefulWidget {
  final drawerItems = [
    new DrawerItem("Budget List", Icons.list),
    new DrawerItem("Add Budget Item", Icons.add),
    new DrawerItem("Fragment 3", Icons.info)
  ];
  HomePage(): super(listenable: ValueNotifier<Widget>(null));
  ValueNotifier<Widget> get notifier => listenable as ValueNotifier<Widget>;
  @override
  State<StatefulWidget> createState() {
    return new HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  int _selectedDrawerIndex = 0;
  HomePageState(): super(listenable: ValueNotifier<Widget>(null));  ValueNotifier<Widget> get notifier => Listenable as ValueNotifier<Widget>;

  _getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        return new BudgetList();
      case 1:
        return new AddBudgetItem(recordKey: "",);
      case 2:
        return new ThirdFragment();

      default:
        return new Text("Error");
    }
  }
  
  _onSelectItem(int index) {
    //setState(() => _selectedDrawerIndex = index);
    this.notifier = _getDrawerItemWidget(index);
    Navigator.of(context).pop(); // close the drawer
  }

  @override
  Widget build(BuildContext context) {
    var drawerOptions = <Widget>[];
    for (var i = 0; i < widget.drawerItems.length; i++) {
      var d = widget.drawerItems[i];
      drawerOptions.add(
        new ListTile(
          leading: new Icon(d.icon),
          title: new Text(d.title),
          selected: i == _selectedDrawerIndex,
          onTap: () => _onSelectItem(i),
        )
      );
    }

    return new Scaffold(
      appBar: new AppBar(
        // here we display the title corresponding to the fragment
        // you can instead choose to have a static title
        title: new Text(widget.drawerItems[_selectedDrawerIndex].title),
      ),
      drawer: new Drawer(
        child: new Column(
          children: <Widget>[
            new UserAccountsDrawerHeader(
                accountName: new Text("John Doe"), accountEmail: null),
            new Column(children: drawerOptions)
          ],
        ),
      ),
      body: _notifySelect.value ?? BudgetList(notifier),
    );
  }
}
