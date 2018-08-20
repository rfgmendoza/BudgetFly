import 'package:flutter/material.dart';
import 'package:budget_fly/pages/home_page.dart';
import 'package:budget_fly/share/database_common.dart' show DBCommon, PayPeriodType;
import 'package:shared_preferences/shared_preferences.dart';


class BudgetSettingsModel{
  num paycheck;
  PayPeriodType payPeriodType;
  int monthlyFrequency;
  DateTime lastPayday;
  DateTime nextPayDay;
  List<int> calendarPayDays;

  BudgetSettingsModel(){
    paycheck = null;
    payPeriodType = null;
    monthlyFrequency = null;
    lastPayday = null;
    nextPayDay = null;
    calendarPayDays = null;
  }
}

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
  BudgetSettingsModel bsModel = new BudgetSettingsModel();
   TextEditingController _c;
  @override
  initState(){
    super.initState();
    _c = new TextEditingController();
    _initBudgetSettings();
  }

  _initBudgetSettings() async {
    BudgetSettingsModel bsm = new BudgetSettingsModel();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bsm.paycheck = prefs.getInt('paycheck') ?? null;
    var type = prefs.getString('payperiodtype') ?? null;
    
    switch (type){
      case "biweekly": bsm.payPeriodType = PayPeriodType.biweekly; break;
      case "calendardate" : bsm.payPeriodType = PayPeriodType.calendarDate; break;
      case "monthly" : bsm.payPeriodType = PayPeriodType.monthly; break;
      default: bsm.payPeriodType = null; break;
    }

    bsm.monthlyFrequency = prefs.getInt("frequency") ?? null;
    String lpd = prefs.getString("lastpayday")?? null;
    if(lpd!=null)
      bsm.lastPayday = DateTime.parse(lpd);
    String npd = prefs.getString("lastpayday")??null;
    if(npd!=null)      
      bsm.nextPayDay = DateTime.parse(npd);
    List<int> calendarPayDays = new List<int>();
    List<String> calendarDates = prefs.getStringList("calendardates");
    if(calendarDates!=null)
      calendarDates.forEach((date)=> calendarPayDays.add(int.parse(date)));
    bsm.calendarPayDays = calendarPayDays;
    setState((){
      bsModel = bsm;
    });
  }

  _saveBudgetSettings(BudgetSettingsModel bsm) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("paycheck", bsm.paycheck);
    await prefs.setString("payperiodtype", bsm.payPeriodType.toString().split('.')[1]);
    await prefs.setInt("frequency", bsm.monthlyFrequency);
    await prefs.setString("lastpayday", bsm.lastPayday.toString());
    await prefs.setString("nextpayday", bsm.lastPayday.toString());
    List<String> calendarDates = new List<String>();
    bsm.calendarPayDays.forEach((day)=> calendarDates.add(day.toString()));
    await prefs.setStringList("calendardates", calendarDates);
    setState(() {
          bsm = bsm;
        });
  }

  _saveInt(String key, int value) async{
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
        body: ListView(
          children: <Widget>[
            //getPayCheck(context, bsModel),
            ListTile(
    
      leading: new Icon(Icons.attach_money),
      title: Text("Paycheck"),
      subtitle: Text("\$"+ (bsModel.paycheck!=null ? bsModel.paycheck.toString(): "0")),
      trailing: new Icon(Icons.edit),
      onTap: () {
        showDialog(
            context: context,
            child: new Dialog(
                child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: new TextField(
              decoration:
                  new InputDecoration(hintText: "Amount received per paycheck"),
              keyboardType: TextInputType.numberWithOptions(),
              controller: _c,
            ),
          ),
          new FlatButton(
            child: new Text("Save"),
            onPressed: (){              
              bsModel.paycheck = int.parse(_c.text);
              setState(() {
                bsModel = bsModel ;
              });
              _saveInt("paycheck", bsModel.paycheck);
              Navigator.pop(context);
              //_saveBudgetSettings(bsModel);            
            },
          )

        ])));
      }),
            Divider(),


            //payCheckCard(),
          ],
        ));
  }
}

getPayCheck(BuildContext context, BudgetSettingsModel bsModel) {
  String paycheck;
  if(bsModel.paycheck !=null)
    paycheck = bsModel.paycheck.toString();
  else
  paycheck = "0";
  return ListTile(
    
      leading: new Icon(Icons.attach_money),
      title: Text("Paycheck"),
      subtitle: Text("\$"+paycheck),
      trailing: new Icon(Icons.edit),
      onTap: () {
        showDialog(
            context: context,
            child: new Dialog(
                child: new Column(children: <Widget>[
          new TextField(
            decoration:
                new InputDecoration(hintText: "Amount received per paycheck"),
            keyboardType: TextInputType.numberWithOptions(),
          ),
          new FlatButton(
            child: new Text("Save"),
            onPressed: (){
              
            
            },
          )

        ])));
      });
}

getCard(List<Widget> content) {
  return Container(
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
  content.add(new Padding(
      padding: EdgeInsets.all(8.0),
      child: new TextField(
        decoration:
            InputDecoration(hintText: 'Enter your income per pay period'),
      )));
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

payPeriodContent() {}


