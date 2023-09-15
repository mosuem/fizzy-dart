import 'dart:collection';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

/// Uncomment for testing correctness
// import '../test/check_correctness.dart';

// IOSink sink = testSink;

IOSink sink = stdout;

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

const int nLength = 20;
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
  receivePort.listen((i2) {
    var message = i2 as int;

    var string = message.toString();
    var n = Uint8List(nLength)..fillRange(1, nLength, zero);
    n[0] = string.length;
    n.setRange(
      nLength - string.length,
      nLength,
      string.codeUnits,
    );
    var s = BytesBuilder(copy: true);
    var j = 0;
    while (j < iterationsPerTask) {
      s.add(n.number);
      s.addByte(10); // 1
      n.inc();

      s.add(n.number);
      s.addByte(10); // 2
      n.inc();

      s.add(fizz); // 3
      n.inc();

      s.add(n.number);
      s.addByte(10); // 4
      n.inc();

      s.add(buzzThenFizz); // 5 & 6
      n.inc();
      n.inc();

      s.add(n.number);
      s.addByte(10); // 7
      n.inc();

      s.add(n.number);
      s.addByte(10); // 8
      n.inc();

      s.add(fizzThenBuzz); // 9 & 10
      n.inc();
      n.inc();

      s.add(n.number);
      s.addByte(10); // 11
      n.inc();

      s.add(fizz); // 12
      n.inc();

      s.add(n.number);
      s.addByte(10); // 13
      n.inc();

      s.add(n.number);
      s.addByte(10); // 14
      n.inc();

      s.add(fizzbuzz); // 15
      n.inc();

      j++;
    }
    sendPort.send(TransferableTypedData.fromList([(s.takeBytes())]));
  });
}

class Job {
  Uint8List? result;
}

final zero = '0'.codeUnits.first;
final nine = '9'.codeUnits.first;

extension NumberExt on Uint8List {
  Uint8List inc() {
    bool carry = true;
    int k = nLength - 1;
    while (carry) {
      if (carry) {
        this[k]++;
        carry = false;
        if (nLength - k > this[0]) {
          this[0]++;
        }
      }
      if (this[k] > nine) {
        this[k] = zero;
        carry = true;
      }
      k--;
    }
    return this;
  }

  Uint8List get number =>
      Uint8List.sublistView(this, nLength - this[0], nLength);
}
