import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../models/order_model/order_model.dart';

class EarningScreen extends StatefulWidget {
  @override
  _EarningScreenState createState() => _EarningScreenState();
}

class _EarningScreenState extends State<EarningScreen> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  late Future<List<ChartData>> _chartData;
  String _selectedView = 'Quarterly';

  @override
  void initState() {
    super.initState();
    _chartData = _fetchChartData();
  }

  Future<List<ChartData>> _fetchChartData() async {
    if (_selectedView == 'Quarterly') {
      return _fetchQuarterlyRevenue();
    } else if (_selectedView == 'Monthly') {
      return _fetchMonthlyRevenue();
    } else {
      return _fetchCompletionRate();
    }
  }

  Future<List<ChartData>> _fetchQuarterlyRevenue() async {
    QuerySnapshot snapshot = await _firebaseFirestore
        .collection("orders")
        .where("status", isEqualTo: 'completed')
        .get();

    Map<int, double> quarterlyRevenue = {1: 0, 2: 0, 3: 0, 4: 0};

    for (var doc in snapshot.docs) {
      OrderModel order =
          OrderModel.fromJson(doc.data() as Map<String, dynamic>);
      int quarter = ((order.orderDate.month - 1) ~/ 3) + 1;
      quarterlyRevenue[quarter] = quarterlyRevenue[quarter]! + order.totalPrice;
    }

    return quarterlyRevenue.entries
        .map((entry) => ChartData("Q${entry.key}", entry.value))
        .toList();
  }

  Future<List<ChartData>> _fetchMonthlyRevenue() async {
    QuerySnapshot snapshot = await _firebaseFirestore
        .collection("orders")
        .where("status", isEqualTo: 'completed')
        .get();

    Map<int, double> monthlyRevenue = {
      for (var i = 1; i <= 12; i++) i: 0,
    };

    for (var doc in snapshot.docs) {
      OrderModel order =
          OrderModel.fromJson(doc.data() as Map<String, dynamic>);
      int month = order.orderDate.month;
      monthlyRevenue[month] = monthlyRevenue[month]! + order.totalPrice;
    }

    return monthlyRevenue.entries
        .map((entry) => ChartData("${entry.key}", entry.value))
        .toList();
  }

  Future<List<ChartData>> _fetchCompletionRate() async {
    QuerySnapshot completedSnapshot = await _firebaseFirestore
        .collection("orders")
        .where("status", isEqualTo: 'completed')
        .get();

    QuerySnapshot canceledSnapshot = await _firebaseFirestore
        .collection("orders")
        .where("status", isEqualTo: 'cancel')
        .get();

    int completedOrders = completedSnapshot.docs.length;
    int canceledOrders = canceledSnapshot.docs.length;
    int totalOrders = completedOrders + canceledOrders;

    double completedPercentage =
        totalOrders > 0 ? (completedOrders / totalOrders) * 100 : 0;
    double canceledPercentage =
        totalOrders > 0 ? (canceledOrders / totalOrders) * 100 : 0;

    return [
      ChartData("Completed", completedPercentage),
      ChartData("Canceled", canceledPercentage),
    ];
  }

  void _onViewChange(String? newValue) {
    setState(() {
      _selectedView = newValue!;
      _chartData = _fetchChartData(); // Refresh data based on selection
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Earnings Overview',
          style: TextStyle(
            color: Colors.red,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          color: Colors.red,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: FutureBuilder<List<ChartData>>(
        future: _chartData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return Center(child: Text("No data available"));
          } else {
            // Filter out zero values
            List<ChartData> pieData =
                snapshot.data!.where((data) => data.value > 0).toList();

            bool hasData = pieData.isNotEmpty;

            return Column(
              children: [
                SizedBox(height: 10),
                DropdownButton<String>(
                  value: _selectedView,
                  items: ['Quarterly', 'Monthly', 'Completion Rate']
                      .map((view) => DropdownMenuItem(
                            value: view,
                            child: Text(view),
                          ))
                      .toList(),
                  onChanged: _onViewChange,
                ),
                SizedBox(height: 20),
                SizedBox(
                  height: screenHeight / 2,
                  child: _selectedView == 'Completion Rate'
                      ? hasData
                          ? SfCircularChart(
                              legend: Legend(
                                isVisible: true,
                                overflowMode: LegendItemOverflowMode.wrap,
                                position: LegendPosition.bottom,
                                iconHeight: 22, // Increase legend icon size
                                iconWidth: 22, // Increase legend icon size
                                textStyle: TextStyle(fontSize: 17),
                              ),
                              series: <CircularSeries>[
                                PieSeries<ChartData, String>(
                                  dataSource: pieData,
                                  xValueMapper: (ChartData data, _) =>
                                      data.label,
                                  yValueMapper: (ChartData data, _) =>
                                      data.value,
                                  dataLabelSettings: DataLabelSettings(
                                    isVisible: true,
                                    textStyle: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    labelPosition: ChartDataLabelPosition
                                        .inside, // Labels inside segments
                                  ),
                                  dataLabelMapper: (ChartData data, _) =>
                                      '${data.value.toStringAsFixed(1)}%',
                                  pointColorMapper: (ChartData data, _) =>
                                      data.label == "Completed"
                                          ? Colors.green
                                          : Colors.red,
                                ),
                              ],
                            )
                          : Center(
                              child: Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 3,
                                  ),
                                ),
                                child: Center(child: Text("No data")),
                              ),
                            )
                      : SfCartesianChart(
                          primaryXAxis: CategoryAxis(),
                          primaryYAxis: NumericAxis(
                            numberFormat: NumberFormat.currency(
                              locale: 'vi',
                              symbol: '',
                              decimalDigits: 0,
                            ),
                            labelFormat: '{value}',
                          ),
                          series: <ChartSeries>[
                            ColumnSeries<ChartData, String>(
                              dataSource: snapshot.data!,
                              xValueMapper: (ChartData data, _) => data.label,
                              yValueMapper: (ChartData data, _) => data.value,
                            ),
                          ],
                        ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

class ChartData {
  final String label;
  final double value;

  ChartData(this.label, this.value);
}
