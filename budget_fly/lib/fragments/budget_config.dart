import 'dart:io';

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
  BudgetSettingsModel bsModel = null;
  TextEditingController _c;
  @override
  initState() {
    _c = new TextEditingController();

    super.initState();
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
          future: DBCommon().getBudgetSettings(bsModel),
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
                      // Divider(),
                      _getLastPayDay(),

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
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text("Pay Check")),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: new TextField(
                            textAlign: TextAlign.center,
                            onSubmitted: (text) {
                              bsModel.paycheck = int.parse(text);
                              _saveModel(bsModel);
                            },
                            decoration: new InputDecoration(
                                hintText: "Amount received per paycheck"),
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            controller: _c,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: new FlatButton(
                            child: new Text("Save"),
                            onPressed: () {
                              bsModel.paycheck = int.parse(_c.text);
                              _saveModel(bsModel);
                            },
                          ),
                        )
                      ])));
        });
  }

  _setNextPayDay() {
    if (bsModel.lastPayDay == null) {
      return;
    }
    PayPeriodType type = bsModel.payPeriodType;
    DateTime lpd = bsModel.lastPayDay;
    DateTime npd = lpd;
    int day = lpd.day;
    switch (bsModel.payPeriodType) {
      case PayPeriodType.monthly:
        npd = lpd = new DateTime(lpd.year, lpd.month + 1, lpd.day);
        break;

      case PayPeriodType.biweekly:
        npd = lpd.add(Duration(days: 14));
        break;
      case PayPeriodType.weekly:
        npd = lpd.add(Duration(days: 7));
        break;
      case PayPeriodType.firstAndFifteen:
        if (day < 15) {
          npd = lpd.add(Duration(days: 15 - day));
          if (npd.weekday == DateTime.sunday)
            npd = npd.subtract(Duration(days: 2));
          else if (npd.weekday == DateTime.saturday) {
            npd = npd.subtract(Duration(days: 1));
          }
        } else if (day >= 15) {
          npd = new DateTime(lpd.year, lpd.month + 1, 1);
          if (npd.weekday == DateTime.sunday)
            npd = npd.subtract(Duration(days: 2));
          else if (npd.weekday == DateTime.saturday) {
            npd = npd.subtract(Duration(days: 1));
          }
        }
        break;
    }
    if (bsModel.nextPayDay != npd) {
      bsModel.nextPayDay = npd;
      DBCommon().saveBudgetSettings(bsModel);
    }
    return;
  }

  

  _getLastPayDay() {
    String lpd;
    String npd;
    if (bsModel.lastPayDay != null) {
      lpd = bsModel.lastPayDay.month.toString();
      lpd += "\\" + bsModel.lastPayDay.day.toString();
    } else
      lpd = "not defined";
    if (bsModel.nextPayDay != null) {
      npd = bsModel.nextPayDay.month.toString();
      npd += "\\" + bsModel.nextPayDay.day.toString();
    } else
      npd = "not defined";
    return ListTile(
        //leading: new Icon(Icons.date_range),
        title: Text("Pay Day"),
        subtitle: Text("Last: " + lpd + " Next: " + npd),
        trailing: Column(children: [
          new Icon(Icons.calendar_today),
          new Text("Click to set last pay day")
        ]),
        onTap: () {
          _pickDateTime();
        });
  }

  _pickDateTime() async {
    DateTime now = DateTime.now();
    final DateTime picked = await showDatePicker(
      context: context,
      firstDate: now.subtract(new Duration(days: 31)),
      lastDate: now,
      initialDate: bsModel.lastPayDay != null ? bsModel.lastPayDay : now,
      initialDatePickerMode: DatePickerMode.day,
    );

    if (picked != null && picked != bsModel.lastPayDay) {
      bsModel.lastPayDay = picked;

      DBCommon().saveBudgetSettings(bsModel);
      _setNextPayDay();
      setState(() {
        bsModel = bsModel;
      });
    }
  }

  _getPaySchedule() {
    return ListTile(
        leading: new Icon(Icons.av_timer),
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
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                        _getTypeChoice(PayPeriodType.weekly),
                        _getTypeChoice(PayPeriodType.biweekly),
                        _getTypeChoice(PayPeriodType.monthly),
                        _getTypeChoice(PayPeriodType.firstAndFifteen),
                      ])));
        });
  }

  Color _getLabelStyle(PayPeriodType type) {
    return bsModel.payPeriodType == type ? Colors.white : Colors.black;
  }

  _saveModel(BudgetSettingsModel bsModel) {
    DBCommon().saveBudgetSettings(bsModel);
    setState(() {
      bsModel = bsModel;
    });
    Navigator.pop(context);
  }

  _onPressSchedule(PayPeriodType type) {
    bsModel.payPeriodType = type;
    _saveModel(bsModel);
    _setNextPayDay();
  }

  Widget _getTypeChoice(PayPeriodType type) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ChoiceChip(
        selectedColor: Colors.green,
        label: Text(type.toString().split('.')[1]),
        labelPadding: EdgeInsets.symmetric(horizontal: 30.0),
        labelStyle: TextStyle(color: _getLabelStyle(type)),
        selected: bsModel.payPeriodType == type,
        onSelected: (selected) {
          if (selected) {
            _onPressSchedule(type);
          }
        },
      ),
    );
  }
}
