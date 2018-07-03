import 'package:flutter/material.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' show Platform, Directory;

enum budgetItemType { creditCard, bill, subscription}

class AddBudgetItem extends StatefulWidget {
  @override
  AddBudgetItemState createState() {
    return AddBudgetItemState();
  }
}

class AddBudgetItemState extends State<AddBudgetItem> {
  final _formKey = GlobalKey<FormState>();
  budgetItemType _itemType = budgetItemType.creditCard;
  _BudgetItem _budgetItem = _BudgetItem();

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(children: <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),  
            child: TextFormField(
              decoration: InputDecoration(
                hintText: "Name",
                labelText: "Name"
              ),
              onFieldSubmitted: (String value){

              },
              onSaved:( String value){
                this._budgetItem.name = value;
              },
              initialValue: null,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
              },
              )),
              Padding(
            padding: EdgeInsets.all(8.0),  
            child: TextFormField(
              decoration: InputDecoration(
                hintText: "Amount",
                labelText: "Amount"
              ),
              initialValue: null,
              keyboardType: TextInputType.numberWithOptions(signed: false, decimal: true),
              onSaved:( String value){
                this._budgetItem.amount = int.parse(value);
              },
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
              })),
              Padding(
                padding: EdgeInsets.all(8.0),
                 
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Day Due",
                    labelText: "Day Due"
                  ),
                  initialValue: null,
                   keyboardType: TextInputType.datetime,
                   onSaved:( String value){
                this._budgetItem.dayDue = int.parse(value);
              },
                  validator: (value) {
                    if(value.isEmpty || int.parse(value) <=0 || int.parse(value) > 31){
                      return 'Please enter a valid day of the month:'+ (value.isEmpty || int.parse(value) >0 || int.parse(value) <=31).toString();
                    }
                  }
                  
                )
              ),
              RadioListTile<budgetItemType>(
                title: const Text('Credit Card'),
                value: budgetItemType.creditCard,
                groupValue: _itemType,
                onChanged: (budgetItemType value){ setState(() {
                                  _budgetItem.itemType = value;
                                });},
              ),
              RadioListTile<budgetItemType>(
                title: const Text('Bill'),
                value: budgetItemType.bill,
                groupValue: _itemType,
                onChanged: (budgetItemType value){ setState(() {
                                  _budgetItem.itemType = value;
                                });},
              ),
              RadioListTile<budgetItemType>(
                title: const Text('Subscription'),
                value: budgetItemType.subscription,
                groupValue: _itemType,
                onChanged: (budgetItemType value){ setState(() {
                                  _budgetItem.itemType = value;
                                });},
              ),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: RaisedButton(
                onPressed: () {
                  // Validate will return true if the form is valid, or false if
                  // the form is invalid.
                  if (_formKey.currentState.validate()) {
                    // If the form is valid, display a snackbar. In the real world, you'd
                    // often want to call a server or save the information in a database
                    // Scaffold.of(context).showSnackBar(
                    //     SnackBar(content: Text('Processing Data')));
                    _formKey.currentState.save();
                    addtoLocalStore(context);
                  }
                },
                child: Text('Add'),
              ))
              
        ]));
  }

  void addtoLocalStore(BuildContext context) async{
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String dbPath = join(dirname(appDocDir.path), "sample.db");
      DatabaseFactory dbFactory = databaseFactoryIo;

      // We use the database factory to open the database
      Database db = await dbFactory.openDatabase(dbPath);
      
      Store budgetStore = db.getStore("budget");
      Record budgetItem = new Record(budgetStore, _budgetItem);
      db.putRecord(budgetItem);
      await budgetStore.records.listen((Record _budgetItem){
          String debug= _budgetItem.toString();
          Scaffold.of(context).showSnackBar(
                        SnackBar(content: Text(debug)));
      }).asFuture();
  }
}
class _BudgetItem{
  String name = "";
  num amount = 0;
  num dayDue = 1;
  budgetItemType itemType = budgetItemType.creditCard;
}
