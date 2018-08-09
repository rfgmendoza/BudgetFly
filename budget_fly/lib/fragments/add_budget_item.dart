import 'package:flutter/material.dart';
import 'package:sembast/sembast.dart';
import 'package:budget_fly/pages/home_page.dart';
import 'package:budget_fly/share/database_common.dart'
    show BudgetItemType, DBCommon, BudgetItem;

class AddBudgetItem extends StatefulWidget {
  final BudgetItem budgetItem;
  AddBudgetItem({Key key, this.budgetItem}) : super(key: key);

  @override
  AddBudgetItemState createState() {
    return AddBudgetItemState();
  }
}

class AddBudgetItemState extends State<AddBudgetItem> {
  final _formKey = GlobalKey<FormState>();

  BudgetItem _budgetItem = BudgetItem();
  bool editMode = false;
  @override
  Widget build(BuildContext context) {
    if (widget.budgetItem != null) {
      this._budgetItem = widget.budgetItem;
      editMode = true;
    }
    return new Scaffold(
        appBar: new AppBar(
          // here we display the title corresponding to the fragment
          // you can instead choose to have a static title
          title: editMode ? new Text("Edit Budget Item") : new Text("Add Budget Item"),
        ),
        drawer: editMode? null : getDrawer(context),
        body: Form(
            key: _formKey,
            child: SingleChildScrollView(child: Column(children: <Widget>[
              Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration:
                        InputDecoration(hintText: "Name", labelText: "Name"),
                    onFieldSubmitted: (String value) {},
                    onSaved: (String value) {
                      this._budgetItem.name = value;
                    },
                    initialValue: _budgetItem.name,
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
                          hintText: "Amount", labelText: "Amount"),
                      initialValue: _budgetItem.amount?.toString(),
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
                      initialValue: _budgetItem.dayDue?.toString(),
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
              RadioListTile<BudgetItemType>(
                title: const Text('Credit Card'),
                value: BudgetItemType.creditCard,
                groupValue: _budgetItem.itemType,
                onChanged: (BudgetItemType value) {
                  setState(() {
                    _budgetItem.itemType = value;
                  });
                },
              ),
              RadioListTile<BudgetItemType>(
                title: const Text('Bill'),
                value: BudgetItemType.bill,
                groupValue: _budgetItem.itemType,
                onChanged: (BudgetItemType value) {
                  setState(() {
                    _budgetItem.itemType = value;
                  });
                },
              ),
              RadioListTile<BudgetItemType>(
                title: const Text('Subscription'),
                value: BudgetItemType.subscription,
                groupValue: _budgetItem.itemType,
                onChanged: (BudgetItemType value) {
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
                    child: !editMode ? Text('Add'):Text('Save'),
                  )),
              // Padding(
              //     padding: const EdgeInsets.symmetric(vertical: 16.0),
              //     child: RaisedButton(
              //       onPressed: () {
              //         checkLocalStore(context);
              //       },
              //       child: Text('check'),
              //     ))
            ]
            )
            )
            ));
  }

  void addtoLocalStore(BuildContext context) async {
    
    Store budgetStore = await DBCommon().getStore("budget");
      Record budgetItem = DBCommon().maptoRecord(budgetStore, _budgetItem);
    if(budgetItem.key != null){    
      await DBCommon().deleteBudgetItem(budgetItem);
           
    }
    DBCommon.db.putRecord(budgetItem);

    Navigator.pop(context);
  }

  void checkLocalStore(BuildContext context) async {
    Store budgetStore = await DBCommon().getStore("budget");

    num count = await budgetStore.count();

    if (count != null)
      Scaffold
          .of(context)
          .showSnackBar(SnackBar(content: Text(count.toString())));
  }
}
