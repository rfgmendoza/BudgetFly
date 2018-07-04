import 'package:flutter/material.dart';
import 'package:sembast/sembast.dart';
import 'package:budget_fly/share/database_common.dart' show budgetItemType, DBCommon, BudgetItem;


class AddBudgetItem extends StatefulWidget {
  
  @override
  AddBudgetItemState createState() {
    return AddBudgetItemState();
  }
}

class AddBudgetItemState extends State<AddBudgetItem> {
  final _formKey = GlobalKey<FormState>();
  budgetItemType _itemType = budgetItemType.creditCard;
  BudgetItem _budgetItem = BudgetItem();
  
  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(children: <Widget>[
          Padding(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                decoration:
                    InputDecoration(hintText: "Name", labelText: "Name"),
                onFieldSubmitted: (String value) {},
                onSaved: (String value) {
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
                  decoration:
                      InputDecoration(hintText: "Amount", labelText: "Amount"),
                  initialValue: null,
                  keyboardType: TextInputType.numberWithOptions(
                      signed: false, decimal: true),
                  onSaved: (String value) {
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
                      hintText: "Day Due", labelText: "Day Due"),
                  initialValue: null,
                  keyboardType: TextInputType.datetime,
                  onSaved: (String value) {
                    this._budgetItem.dayDue = int.parse(value);
                  },
                  validator: (value) {
                    if (value.isEmpty ||
                        int.parse(value) <= 0 ||
                        int.parse(value) > 31) {
                      return 'Please enter a valid day of the month:' +
                          (value.isEmpty ||
                                  int.parse(value) > 0 ||
                                  int.parse(value) <= 31)
                              .toString();
                    }
                  })),
          RadioListTile<budgetItemType>(
            title: const Text('Credit Card'),
            value: budgetItemType.creditCard,
            groupValue: _budgetItem.itemType,
            onChanged: (budgetItemType value) {
              setState(() {
                _budgetItem.itemType = value;
              });
            },
          ),
          RadioListTile<budgetItemType>(
            title: const Text('Bill'),
            value: budgetItemType.bill,
            groupValue: _budgetItem.itemType,
            onChanged: (budgetItemType value) {
              setState(() {
                _budgetItem.itemType = value;
              });
            },
          ),
          RadioListTile<budgetItemType>(
            title: const Text('Subscription'),
            value: budgetItemType.subscription,
            groupValue: _budgetItem.itemType,
            onChanged: (budgetItemType value) {
              setState(() {
                _budgetItem.itemType = value;
              });
            },
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
              )),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: RaisedButton(
                onPressed: () {
                  checkLocalStore(context);
                },
                child: Text('check'),
              ))
        ]));
  }

  void addtoLocalStore(BuildContext context) async {
    
    Store budgetStore = await DBCommon().getStore("budget");
    Record budgetItem = DBCommon().maptoRecord(budgetStore, _budgetItem);
    DBCommon.db.putRecord(budgetItem);
  }

  void checkLocalStore(BuildContext context) async {
    
    Store budgetStore = await DBCommon().getStore("budget");
    
    num count = await budgetStore.count();
    
    if(count!=null)
    Scaffold
        .of(context)
        .showSnackBar(SnackBar(content: Text(count.toString())));

  }
}

