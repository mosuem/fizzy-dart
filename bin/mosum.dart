import 'dart:collection';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import '../test/check_correctness.dart';

IOSink sink = stdout;
// IOSink sink = testSink;

final fizzbuzz = "FizzBuzz\n".codeUnits;
final fizz = "Fizz\n".codeUnits;
final buzz = "Buzz\n".codeUnits;
final buzzThenFizz = "Buzz\nFizz\n".codeUnits;
final fizzThenBuzz = "Fizz\nBuzz\n".codeUnits;
const fblength = 8;
const flength = 4;

// Much more than this and we get messages >64k back.
//
// TODO: adjust this down over time if responses grow in size beyond 64k?
int iterationsPerTask = 500;

// Incremental gains past this, machine dependent also.
const numWorkers = 12;

void main(List<String> arguments) async {
  var next = 1;
  final jobQueue = Queue<Job>();

  for (var worker = 0; worker < numWorkers; worker++) {
    final receivePort = ReceivePort();
    Isolate.spawn(
      genFizzbuzz,
      receivePort.sendPort,
    );
    late SendPort sendPort;
    late Job lastJob;
    receivePort.listen((message) {
      switch (message) {
        case SendPort():
          sendPort = message;
        case TransferableTypedData():
          lastJob.result = message.materialize().asUint8List();
          while (jobQueue.isNotEmpty && jobQueue.first.result != null) {
            sink.add(jobQueue.removeFirst().result!);
          }
        default:
          throw StateError(
              'Bad state, expected a SendPort or TransferableTypedData but got '
              '$message');
      }
      jobQueue.add(lastJob = Job());
      sendPort.send(next);
      next += 15 * iterationsPerTask;
    });
  }
}

void genFizzbuzz(SendPort sendPort) {
  var receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);
  receivePort.listen((i) {
    i = i as int;
    var s = Uint8List(iterationsPerTask * 15 * 8);
    var j = 0;
    int ptr = 0;
    while (j < iterationsPerTask) {
      ptr = s.setIntRange(i, ptr); // 1
      ptr = s.setIntRange(i + 1, ptr); // 2
      ptr = s.setFizz(ptr); // 3
      ptr = s.setIntRange(i + 3, ptr); // 4
      ptr = s.setBuzz(ptr); // 5
      ptr = s.setFizz(ptr); // 6
      ptr = s.setIntRange(i + 6, ptr); // 7
      ptr = s.setIntRange(i + 7, ptr); // 8
      ptr = s.setFizz(ptr); // 9
      ptr = s.setBuzz(ptr); // 10
      ptr = s.setIntRange(i + 10, ptr); // 11
      ptr = s.setFizz(ptr); // 12
      ptr = s.setIntRange(i + 12, ptr); // 13
      ptr = s.setIntRange(i + 13, ptr); // 14
      ptr = s.setFizzBuzz(ptr); // 15

      i += 15;
      j++;
    }
    sendPort.send(TransferableTypedData.fromList([
      Uint8List.sublistView(
        s,
        0,
        ptr,
      )
    ]));
  });
}

class Job {
  Uint8List? result;
}

extension _ on Uint8List {
  int setIntRange(int value, int ptr) {
    final codeUnits = value.toString().codeUnits;
    setRange(ptr, ptr + codeUnits.length, codeUnits);
    this[ptr + codeUnits.length] = 10;
    return ptr + codeUnits.length + 1;
  }

  int setFizz(int ptr) {
    setRange(ptr, ptr + flength, fizz);
    this[ptr + flength] = 10;
    return ptr + flength + 1;
  }

  int setBuzz(int ptr) {
    setRange(ptr, ptr + flength, buzz);
    this[ptr + flength] = 10;
    return ptr + flength + 1;
  }

  int setFizzBuzz(int ptr) {
    setRange(ptr, ptr + fblength, fizzbuzz);
    this[ptr + fblength] = 10;
    return ptr + fblength + 1;
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