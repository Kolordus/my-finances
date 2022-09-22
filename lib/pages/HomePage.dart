import 'package:flutter/material.dart';
import 'package:my_finances/model/PaymentMethod.dart';
import '../dal/Database.dart';
import 'FinanceTypeScreen.dart';
import 'TotalScreen.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  PageController pageController = PageController(initialPage: 0);

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      pageController.animateToPage(index,
          duration: Duration(milliseconds: 200), curve: Curves.bounceInOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue[300],
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.credit_card),
              label: 'Karta',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.money),
              label: 'Gotowka',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_rounded),
              label: 'Total',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        ),
        body: PageView(
          controller: pageController,
          onPageChanged: (value) => {
            setState(() {
              _selectedIndex = value;
            })
          },
          children: [
            FinanceTypeScreen(title: PaymentMethod.Card),
            FinanceTypeScreen(title: PaymentMethod.Cash),
            TotalScreen(),
          ],
        ));
  }

  @override
  void dispose() {
    Database.getDatabase().close();
    super.dispose();
  }
}