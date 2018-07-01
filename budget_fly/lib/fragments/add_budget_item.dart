import 'package:flutter/material.dart';

class AddBudgetItem extends StatefulWidget {
  @override
  AddBudgetItemState createState() {
    return AddBudgetItemState();
  }
}

class AddBudgetItemState extends State<AddBudgetItem> {
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(children: <Widget>[
          Padding(
            padding: EdgeInsets.all(16.0),  
            child: TextFormField(
              decoration: InputDecoration(
                hintText: "Name",
                labelText: "Name"
              ),
              initialValue: null,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
              })),
              Padding(
            padding: EdgeInsets.all(16.0),  
            child: TextFormField(
              decoration: InputDecoration(
                hintText: "Amount",
                labelText: "Amount"
              ),
              initialValue: null,
              keyboardType: TextInputType.numberWithOptions(signed: false, decimal: true),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
              })),
              Padding(
                padding: EdgeInsets.all(16.0),
                 
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Day Due",
                    labelText: "Day Due"
                  ),
                  initialValue: null,
                   keyboardType: TextInputType.datetime,
                  validator: (value) {
                    if(value.isEmpty || int.parse(value) >0 || int.parse(value) <=31){
                      return 'Please enter a valid day of the month';
                    }
                  }
                  
                )
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
                    Scaffold.of(context).showSnackBar(
                        SnackBar(content: Text('Processing Data')));
                  }
                },
                child: Text('Submit'),
              ))
        ]));
  }
}
