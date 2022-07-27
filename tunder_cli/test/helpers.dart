import 'dart:async';

var logs = [];

FutureOr<void> Function() withOverrides(FutureOr<void> Function() body) => () {
      return Zone.current
          .fork(
              specification: ZoneSpecification(
            print: (_, __, ___, line) => logs.add(line),
          ))
          .run<void>(body);
    };
