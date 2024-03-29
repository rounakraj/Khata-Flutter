import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:simple_khata/blocs/customerBloc.dart';
import 'package:simple_khata/blocs/transactionBloc.dart';
import 'package:simple_khata/helpers/conversion.dart';
import 'package:simple_khata/models/customer.dart';
import 'package:simple_khata/models/transaction.dart';
import 'package:simple_khata/pages/singleTransaction.dart';
import 'package:simple_khata/pages/transactions.dart';

import 'addTransaction.dart';
import 'customers.dart';
import 'editCustomer.dart';

class EditCustomerScreenArguments {
  final Customer customer;

  EditCustomerScreenArguments(this.customer);
}

class AddTransactionScreenArguments {
  final Customer customer;

  AddTransactionScreenArguments(this.customer);
}

class SingleCustomer extends StatefulWidget {
  @override
  _SingleCustomerState createState() => _SingleCustomerState();
}

class _SingleCustomerState extends State<SingleCustomer> {
  final CustomerBloc customerBloc = CustomerBloc();
  final TransactionBloc transactionBloc = TransactionBloc();

  void _showDeleteDialog(customer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text("Delete " + customer.name),
          content: Text(
              "Deleting action will remove all the transactions associated with the current customer."),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            RaisedButton(
              color: Colors.red,
              child: Text(
                "Delete",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                customerBloc.deleteCustomerById(customer.id);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final SingleCustomerScreenArguments args =
        ModalRoute.of(context).settings.arguments;

    return FutureBuilder<dynamic>(
        future: customerBloc.getCustomer(args.customerId),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            Customer customer = snapshot.data;

            Uint8List customerImage;
            if (customer.image != null) {
              customerImage = Base64Decoder().convert(customer.image);
            }

            return Scaffold(
              resizeToAvoidBottomPadding: false,
              appBar: AppBar(
                  elevation: 0.0,
                  backgroundColor: Colors.transparent,
                  title: null,
                  iconTheme: IconThemeData(
                    color: Colors.black, //change your color here
                  ),
                  actions: <Widget>[
                    // action button
                    IconButton(
                      icon: Icon(Icons.edit, size: 20.0, color: Colors.purple),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EditCustomer(),
                                settings: RouteSettings(
                                  arguments: EditCustomerScreenArguments(
                                    customer,
                                  ),
                                )));
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, size: 20.0, color: Colors.red),
                      onPressed: () {
                        _showDeleteDialog(customer);
                      },
                    ),
                    // action button
                  ]),
              body: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Hero(
                            tag: customer.id,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                              child: customerImage != null
                                  ? CircleAvatar(
                                      radius: 40.0,
                                      child: ClipOval(
                                          child: Image.memory(customerImage,
                                              height: 80,
                                              width: 80,
                                              fit: BoxFit.cover)),
                                      backgroundColor: Colors.transparent,
                                    )
                                  : CircleAvatar(
                                      backgroundColor: Colors.purple.shade500,
                                      radius: 40,
                                      child: Icon(Icons.person,
                                          color: Colors.purple.shade100,
                                          size: 40.0),
                                    ),
                            )),
                        Padding(
                          padding: EdgeInsets.fromLTRB(8, 12, 8, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 8),
                                child: Text(
                                  customer.name,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 20),
                                ),
                              ),
                              Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.phone,
                                    color: Colors.brown.shade600,
                                    size: 16.0,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(8, 4, 4, 4),
                                    child: Text(customer.phone),
                                  ),
                                ],
                              ),
                              customer.address != null &&
                                      customer.address.length > 0
                                  ? Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.location_on,
                                          color: Colors.brown.shade600,
                                          size: 16.0,
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(8, 4, 4, 4),
                                          child: Text(customer.address),
                                        ),
                                      ],
                                    )
                                  : Container()
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: getCustomerTransactions(customer.id))
                ],
              ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddTransaction(),
                        settings: RouteSettings(
                          arguments: AddTransactionScreenArguments(
                            customer,
                          ),
                        )),
                  );
                },
                icon: Icon(Icons.add),
                label: Text('Add Transaction'),
              ),
            );
          }

          return Container();
        });
  }

  Widget getCustomerTransactionsTotalWidget(int cid) {
    return FutureBuilder(
        future: transactionBloc.getCustomerTransactionsTotal(cid),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            int total = snapshot.data;
            bool neg = false;
            String ttype = "payment";
            if (total.isNegative) {
              neg = true;
              ttype = "credit";
            }
            return Row(children: <Widget>[
              Text(total.abs().toString(),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              neg
                  ? Icon(
                      Icons.arrow_upward,
                      color: Colors.green.shade900,
                      size: 16.0,
                    )
                  : Icon(
                      Icons.arrow_downward,
                      color: Colors.orange.shade900,
                      size: 16.0,
                    ),
              Padding(
                padding: EdgeInsets.fromLTRB(4, 0, 0, 0),
                child: Text(
                  ttype.toUpperCase(),
                  style: TextStyle(
                      color: Colors.black38, fontSize: 10, letterSpacing: 0.6),
                ),
              )
            ]);
          }

          return Container();
        });
  }

  Widget getCustomerTransactions(int cid) {
    return FutureBuilder(
        future: transactionBloc.getTransactionsByCustomerId(cid),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData && snapshot.data.length != 0) {
            return Column(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(color: Colors.grey.shade200),
                  padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                  child: Row(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(Icons.history,
                              color: Colors.black54, size: 16.0),
                          Padding(
                              padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                              child: Text('History')),
                        ],
                      ),
                      Spacer(),
                      Chip(
                          backgroundColor: Colors.green.shade100,
                          label: getCustomerTransactionsTotalWidget(cid))
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                      padding: EdgeInsets.fromLTRB(0, 16, 0, 60),
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, itemIndex) {
                        Transaction transaction = snapshot.data[itemIndex];
                        return Column(
                          children: <Widget>[
                            FlatButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SingleTransaction(),
                                    settings: RouteSettings(
                                      arguments:
                                          SingleTransactionScreenArguments(
                                        transaction.id,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 0, 16, 0),
                                      child: CircleAvatar(
                                        backgroundColor: Colors.grey.shade200,
                                        radius: 20,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                              "${transaction.date.day}",
                                              style: TextStyle(
                                                color:
                                                    Colors.deepPurple.shade900,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              "${convertNumberToMonth(transaction.date.month)}",
                                              style: TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 10),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.9,
                                            padding:
                                                EdgeInsets.fromLTRB(0, 4, 8, 4),
                                            child: Text(
                                              transaction.comment,
                                              softWrap: true,
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  color: Colors.black87),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: <Widget>[
                                        Row(children: <Widget>[
                                          Text(
                                              transaction.amount
                                                  .abs()
                                                  .toString(),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16)),
                                          transaction.ttype == 'payment'
                                              ? Icon(
                                                  Icons.arrow_downward,
                                                  color: Colors.orange.shade900,
                                                  size: 16.0,
                                                )
                                              : Icon(
                                                  Icons.arrow_upward,
                                                  color: Colors.green.shade900,
                                                  size: 16.0,
                                                ),
                                        ]),
                                        Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 4, 0, 0),
                                          child: Text(
                                            transaction.ttype.toUpperCase(),
                                            style: TextStyle(
                                                color: Colors.black38,
                                                fontSize: 10,
                                                letterSpacing: 0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            snapshot.data.length - 1 != itemIndex
                                ? Divider(
                                    color: Colors.grey.shade300,
                                    height: 2,
                                  )
                                : Container(),
                          ],
                        );
                      }),
                ),
              ],
            );
          }
          return Container();
        });
  }
}
