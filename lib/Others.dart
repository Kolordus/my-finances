

import 'dart:isolate';

class Others {
  Future<void> ileczekac(Duration duration) async {
    await Future.delayed(duration);
    print("poszło po ${duration.inSeconds}");
  }

  void metodka_1() async {
    Isolate.spawn((message) async {
      var sss = ileczekac(Duration(seconds: 4));
      var sss1 = ileczekac(Duration(seconds: 5));
      var sss2 = ileczekac(Duration(seconds: 6));
      var sss3 = ileczekac(Duration(seconds: 7));

      var list = [sss, sss1, sss2, sss3];
      var list2 = await Future.wait(list);

      var length = list2.length;
      print(length);
    }, 'heheh');

    var sss = ileczekac(Duration(seconds: 4));
    var sss1 = ileczekac(Duration(seconds: 5));
    var sss2 = ileczekac(Duration(seconds: 6));
    var sss3 = ileczekac(Duration(seconds: 7));

    var list = [sss, sss1, sss2, sss3];
    var list2 = await Future.wait(list);

    var length = list2.length;
    print(length);
  }
}
