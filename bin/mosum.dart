import 'dart:collection';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

final fizzbuzz = "FizzBuzz\n".codeUnits;
final fizz = "Fizz\n".codeUnits;
final buzz = "Buzz\n".codeUnits;
final buzzThenFizz = "Buzz\nFizz\n".codeUnits;
final fizzThenBuzz = "Fizz\nBuzz\n".codeUnits;

// Much more than this and we get messages >64k back.
//
// TODO: adjust this down over time if responses grow in size beyond 64k?
const iterationsPerTask = 500;

// Incremental gains past this, machine dependent also.
const numWorkers = 10;

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
            stdout.add(jobQueue.removeFirst().result!);
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
    var s = BytesBuilder();
    var j = 0;
    while (j < iterationsPerTask) {
      s.addInt(i); // 1
      s.addInt(i + 1); // 2
      s.add(fizz); // 3
      s.addInt(i + 3); // 4
      s.add(buzzThenFizz); // 5 & 6
      s.addInt(i + 6); // 7
      s.addInt(i + 7); // 8
      s.add(fizzThenBuzz); // 9 & 10
      s.addInt(i + 10); // 11
      s.add(fizz); // 12
      s.addInt(i + 12); // 13
      s.addInt(i + 13); // 14
      s.add(fizzbuzz); // 15

      i += 15;
      j++;
    }
    sendPort.send(TransferableTypedData.fromList([s.takeBytes()]));
  });
}

class Job {
  Uint8List? result;
}

extension _ on BytesBuilder {
  void addInt(int value) {
    add(value.toString().codeUnits);
    add([10]);
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
