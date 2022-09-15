// ignore: import_of_legacy_library_into_null_safe

import 'package:flutter/material.dart';
import 'package:my_finances/model/PaymentType.dart';
import 'package:my_finances/model/PersistedPayment.dart';
import 'package:my_finances/widgets/DropDownWithValues.dart';
import '../dal/Database.dart';
import '../model/Filters.dart';
import '../widgets/LastActions.dart';
import 'StepperInputScreenForFinance.dart';

class FinanceTypeScreen extends StatefulWidget {
  FinanceTypeScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _FinanceTypeScreenState createState() => _FinanceTypeScreenState();
}

class _FinanceTypeScreenState extends State<FinanceTypeScreen> {
  final amountController = TextEditingController();
  final nameController = TextEditingController();
  bool _groupByCategories = false;
  bool _filterByCategories = false;
  Filters _filters = Filters.EMPTY_FILTER;
  bool _sortDesc = false;

  double _amount = 00.0;
  String backgroundImage = '';

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    refreshTotalAmount();

    if (widget.title == 'Card') backgroundImage = "assets/images/bank-card.jpg";
    if (widget.title == 'Cash') backgroundImage = "assets/images/notes.jpg";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(backgroundImage),
                fit: BoxFit.cover,
                opacity: 1000,
                colorFilter:
                    ColorFilter.mode(Colors.lightBlueAccent, BlendMode.color))),
        child: Padding(
          padding: EdgeInsets.all(1.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: Text(_amount.toDouble().toStringAsFixed(2),
                      style:
                          TextStyle(fontSize: 70, color: Colors.amberAccent)),
                ),
              ),
              Flexible(
                  flex: 1,
                  child: ElevatedButton(
                      style: ButtonStyle(
                          shadowColor:
                              MaterialStateProperty.all<Color>(Colors.grey),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ))),
                      onPressed: () async {
                        PersistedPayment? createdPayment = await Navigator.push(
                            this.context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    new StepperInputScreenForFinance(
                                        widget.title)));

                        if (createdPayment == null) {
                          return;
                        }

                        await refreshTotalAmount();
                      },
                      child: Icon(Icons.add))),
              Expanded(
                  flex: 4,
                  child: LastActions(
                      paymentMethod: widget.title,
                      refreshFunction: refreshTotalAmount,
                      groupByCategories: _groupByCategories,
                      filters: _filters,
                      sortedDesc: _sortDesc
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                      style: _buttonStyle(_groupByCategories),
                      onPressed: () {
                        setState(() {
                          _groupByCategories = !_groupByCategories;
                        });
                      },
                      child: Text("Group")),
                  ElevatedButton(
                      style: _buttonStyle(_sortDesc),
                      onPressed: () {
                        setState(() {
                          _sortDesc = !_sortDesc;
                        });
                      },
                      child: Icon(Icons.compare_arrows_sharp)),
                  ElevatedButton(
                      style: _buttonStyle(_filters != Filters.EMPTY_FILTER),
                      onPressed: () async {
                        // turn of the filters
                        if (_filters != Filters.EMPTY_FILTER) {
                          setState(() {
                            _filters = Filters.EMPTY_FILTER;
                            _filterByCategories = false;
                          });
                          return;
                        }

                        // if no filters show dialog with filters
                        _filters = await _showFiltersDialog();
                        setState(() { });
                      },
                      child: Text("Filters")),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> refreshTotalAmount() async {
    Database db = Database.getDatabase();
    String paymentMethod = widget.title;

    double savedValue = await db.getSavedCashOrCard(paymentMethod);

    setState(() {
      this._amount = savedValue;
    });
  }

  ButtonStyle? _buttonStyle(bool condition) {
    return condition
        ? ElevatedButton.styleFrom(
            shape: CircleBorder(),
          )
        : null;
  }

  Future<Filters> _showFiltersDialog() async {
    var operationNameController = TextEditingController();
    Filters selectedFilters = Filters.EMPTY_FILTER;

    String selectedOperationType = '';

    var currentYear = DateTime.now().year;
    var currentMonth = DateTime.now().month;
    var currentDay = DateTime.now().day;

    DateTimeRange dateRange = DateTimeRange(
        start: DateTime(currentYear, currentMonth, currentDay),
        end: DateTime(currentYear, currentMonth, currentDay + 1)
    );

    RangeValues amountsForSlider = await Database.getDatabase().getHighestAndLowestAmount();
    var selectedRange = RangeValues(amountsForSlider.start, amountsForSlider.end);
    var rangeLabels = RangeLabels(selectedRange.start.toString(), selectedRange.end.toString());

    await showDialog<Filters>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.lightBlue,
              title: Text("Select filters"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Operation name'),
                    TextField(controller: operationNameController),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0,40,0,0),
                      child: Text('Amount range'),
                    ),
                    RangeSlider(
                      divisions: 10,
                      min: amountsForSlider.start,
                      max: amountsForSlider.end,
                      labels: rangeLabels,
                      values: selectedRange,
                      onChanged: (RangeValues rv) {
                        setState(() {
                          selectedRange = rv;
                          rangeLabels = RangeLabels(rv.start.toString(),
                          rv.end.toString());
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0,40,0,0),
                      child: Text('Date range'),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                            onPressed: () async {
                              DateTimeRange newDates = await pickDate(dateRange);
                              setState(() {
                                dateRange = newDates;
                              });
                            },
                            child: Text(showDateOnButton(dateRange.start))),
                        ElevatedButton(
                            onPressed: () {
                              pickDate(dateRange);
                            },
                            child: Text(showDateOnButton(dateRange.end)))
                      ],
                    ), // d
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0,40,0,0),
                      child: Text('Category'),
                    ),
                    Checkbox(
                      activeColor: Colors.white,
                      checkColor: Colors.blue,
                      value: _filterByCategories,
                      onChanged: (bool? value) {
                        setState(() {
                          _filterByCategories = value!;
                          selectedOperationType  = _filterByCategories
                              ? PaymentType.OTHERS.name
                              : "";
                        });
                      },
                    ),
                    _filterByCategories ? DropDownWithValues(
                        selectedOperationType: selectedOperationType,
                        refreshParent: (String selected) {
                          setState(() {
                            selectedOperationType = selected;
                          });
                        }) : Text(''),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    selectedFilters = Filters(
                        operationName: operationNameController.text,
                        selectedRangeAmount: selectedRange,
                        dateRange: dateRange,
                        selectedOperationType: selectedOperationType
                    );

                    Navigator.pop(context,selectedFilters);

                    return Future.value(selectedFilters);
                  },
                  child: Text("Ok", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
    return Future.value(selectedFilters);
  }

  String showDateOnButton(DateTime date) =>
      '${date.year}/${date.month}/${date.day}';

  Future pickDate(dateRange) async {
    DateTimeRange? dateTimeRange = await showDateRangePicker(
        context: context,
        initialDateRange: dateRange,
        firstDate: DateTime(DateTime.now().year),
        lastDate: DateTime(DateTime.now().year + 1));

    if (dateTimeRange == null) return;

    return dateTimeRange;
  }
}
