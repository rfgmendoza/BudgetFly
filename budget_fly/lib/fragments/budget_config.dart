import 'package:flutter/material.dart';
import 'package:budget_fly/pages/home_page.dart';
import 'package:budget_fly/share/database_common.dart'
    show DBCommon, PayPeriodType, BudgetSettingsModel;
import 'package:shared_preferences/shared_preferences.dart';

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
  BudgetSettingsModel bsModel;
  TextEditingController _c;
  @override
  initState() {
    _c = new TextEditingController();

    super.initState();
  }

  _saveInt(String key, int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        // here we display the title corresponding to the fragment
        // you can instead choose to have a static title
        title: Text("Budget Settings"),
      ),
      drawer: getDrawer(context),
      body: FutureBuilder(
          future: DBCommon().getBudgetSettings(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return new CircularProgressIndicator();
              default:
                if (snapshot.hasData) {
                  if (snapshot.data != null) {
                    bsModel = snapshot.data as BudgetSettingsModel;
                  } else {
                    bsModel = new BudgetSettingsModel();
                  }
                  return ListView(
                    children: <Widget>[
                      //getPayCheck(context, bsModel),
                      _payCheckContent(),
                      Divider(),
                      _getPaySchedule(),
                      Divider(),

                      //payCheckCard(),
                    ],
                  );
                } else if (snapshot.hasError) return Text("${snapshot.error}");
            }
          }),
    );
  }

  _payCheckContent() {
    return ListTile(
        leading: new Icon(Icons.attach_money),
        title: Text("Paycheck"),
        subtitle: Text("\$" +
            (bsModel.paycheck != null ? bsModel.paycheck.toString() : "0")),
        trailing: new Icon(Icons.edit),
        onTap: () {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => Dialog(
                      child: new Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: new TextField(
                            decoration: new InputDecoration(
                                hintText: "Amount received per paycheck"),
                            keyboardType: TextInputType.numberWithOptions(),
                            controller: _c,
                          ),
                        ),
                        new FlatButton(
                          child: new Text("Save"),
                          onPressed: () {
                            bsModel.paycheck = int.parse(_c.text);
                            DBCommon().saveBudgetSettings(bsModel);
                            setState(() {
                              bsModel = bsModel;
                            });
                            Navigator.pop(context);
                          },
                        )
                      ])));
        });
  }

  _getPaySchedule() {
    var _frequency = bsModel.monthlyFrequency; 
    return ListTile(
        leading: new Icon(Icons.attach_money),
        title: Text("Pay Schedule"),
        subtitle: Text(bsModel.payPeriodType != null
            ? bsModel.payPeriodType.toString().split(".")[1]
            : "not defined"),
        trailing: new Icon(Icons.edit),
        onTap: () {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (__) => new Dialog(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ChoiceChip(
                        selectedColor: Colors.green,
                        label: //Text("option"),
                            Row(
                          mainAxisSize: MainAxisSize.max,
                          //crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("options1"),
                            DropdownButton(
                                value: bsModel.payPeriodType ==
                                        PayPeriodType.weekly
                                    ? _frequency
                                    : null,
                                items: _getWeeklyDropdown(),
                                onChanged: (value) {
                                  bsModel.monthlyFrequency = value;
                                  DBCommon().saveBudgetSettings(bsModel);
                                  setState(() {
                                   _frequency = value;
                                  });
                                })
                          ],
                        ),
                        selected: bsModel.payPeriodType == PayPeriodType.weekly,
                        onSelected: (selected) {
                          if (selected)
                            bsModel.payPeriodType = PayPeriodType.weekly;
                          DBCommon().saveBudgetSettings(bsModel);
                        },
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: ChoiceChip(
                    //     label: Row(
                    //       children: <Widget>[
                    //         Text("options2"),
                    //       ],
                    //     ),
                    //     selected: bsModel.payPeriodType == PayPeriodType.weekly,
                    //   ),
                    // ),
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: ChoiceChip(
                    //     label: Row(
                    //       children: <Widget>[
                    //         Text("options3"),
                    //       ],
                    //     ),
                    //     selected: bsModel.payPeriodType == PayPeriodType.weekly,
                    //   ),
                    // ),
                    FlatButton.icon(
                      label: Text("save"),
                      icon: Icon(Icons.check),
                      onPressed: () {
                        setState(() {
                          bsModel = bsModel;
                        });
                        Navigator.pop(context);
                      },
                    )
                  ])));
        });
  }

  _onPressSchedule(PayPeriodType type) {
    bsModel.payPeriodType = type;
    setState(() {
      bsModel = bsModel;
    });
    Navigator.pop(context);
  }

  List<DropdownMenuItem<int>> _getWeeklyDropdown() {
    List<DropdownMenuItem<int>> list = new List<DropdownMenuItem<int>>();
    for (int i = 1; i <= 4; i++) {
      list.add(new DropdownMenuItem<int>(
        value: i,
        child: Text(i.toString()),
      ));
    }
    return list;
  }
}
