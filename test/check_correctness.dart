import 'dart:convert';
import 'dart:io';

final testSink = TestSink();

class TestSink implements IOSink {
  late String reference;

  @override
  Encoding encoding = utf8;

  TestSink() {
    reference = getReference(10000000);
    print('Got ref');
  }

  @override
  void add(List<int> data) {
    checkTotal(String.fromCharCodes(data));
  }

  void checkTotal(String string) {
    if (string.length > reference.length) {
      throw UnsupportedError('Too long');
    }
    var substring = reference.substring(0, string.length);
    if (substring != string) {
      print(string.length);
      print(substring.length);
      print(string.substring(string.length - 100));
      print(substring.substring(substring.length - 100));
      throw ArgumentError(string.length);
    } else {
      reference = reference.substring(string.length);
    }
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    throw UnimplementedError();
  }

  @override
  Future addStream(Stream<List<int>> stream) {
    throw UnimplementedError();
  }

  @override
  Future close() {
    throw UnimplementedError();
  }

  @override
  Future get done => throw UnimplementedError();

  @override
  Future flush() {
    throw UnimplementedError();
  }

  @override
  void write(Object? object) {
    if (object != null) checkTotal(object.toString());
  }

  @override
  void writeAll(Iterable objects, [String separator = ""]) {
    throw UnimplementedError();
  }

  @override
  void writeCharCode(int charCode) {
    throw UnimplementedError();
  }

  @override
  void writeln([Object? object = ""]) {
    throw UnimplementedError();
  }
}

String getReference(int until) {
  const String fizzbuzz = "FizzBuzz";
  const String fizz = "Fizz";
  const String buzz = "Buzz";
  int i = 1;
  var s = StringBuffer();
  while (true) {
    if (i % 15 == 0) {
      s.writeln(fizzbuzz);
    } else if (i % 3 == 0) {
      s.writeln(fizz);
    } else if (i % 5 == 0) {
      s.writeln(buzz);
    } else {
      s.writeln(i);
    }
    i++;
    if (i > until) {
      return s.toString();
    }
  }
}
