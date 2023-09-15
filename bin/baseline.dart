import 'dart:io';

const String fizzbuzz = "FizzBuzz";
const String fizz = "Fizz";
const String buzz = "Buzz";

StringSink sink = stdout;
// StringSink sink = testSink;

void main(List<String> arguments) {
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
    if (i > 1000000) {
      sink.write(s.toString());
      s.clear();
    }
  }
}
