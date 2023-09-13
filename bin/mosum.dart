import 'dart:io';
import 'dart:typed_data';

final fizzbuzz = "FizzBuzz".codeUnits;
final fizz = "Fizz".codeUnits;
final buzz = "Buzz".codeUnits;

const fblength = 8;
const flength = 4;

void main(List<String> arguments) {
  stdout.addStream(genFizzbuzz());
}

Stream<Uint8List> genFizzbuzz() async* {
  int i = 1;
  int ptr = 0;
  var s = Uint8List(64000);
  while (true) {
    if (i % 15 == 0) {
      s.setRange(ptr, ptr + fblength, fizzbuzz);
      ptr += fblength;
    } else if (i % 3 == 0) {
      s.setRange(ptr, ptr + flength, fizz);
      ptr += fblength;
    } else if (i % 5 == 0) {
      s.setRange(ptr, ptr + flength, buzz);
      ptr += fblength;
    } else {
      final codeUnits = i.toString().codeUnits;
      s.setRange(ptr, ptr + codeUnits.length, codeUnits);
      ptr += codeUnits.length;
    }
    s[ptr++] = 10;

    i++;
    if (ptr > 63900) {
      yield Uint8List.sublistView(s, 0, ptr);
      ptr = 0;
    }
  }
}

// Uint8List uint8(int i) {
//   int n = i;
//   int count = 0;
//   while (n != 0) {
//     n = n ~/ 10;
//     count++;
//   }
//   final bytes = Uint8List(count);
//   for (var j = 0; j < count; j++) {
//     bytes[count - (j + 1)] = i % 10 + 48;
//     i = (i ~/ 10);
//   }
//   return bytes;
// }

// Uint8List uint8_2(int i) {
//   const length = 100;
//   int n = i;
//   int count = 0;
//   final bytes = Uint8List(length);
//   while (n != 0) {
//     bytes[length - (count + 1)] = n % 10 + 48;
//     n = n ~/ 10;
//     count++;
//   }
//   return bytes.sublist(length - count);
// }

// List<int> uint8_3(int i) {
//   return i.toString().codeUnits;
// }
