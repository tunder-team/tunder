import 'dart:async';

import 'package:tunder/src/core/container.dart';

class Pipeline {
  late Container container;
  var handlers = [];
  var passable;

  Pipeline(this.container);

  Pipeline send(passable) {
    this.passable = passable;

    return this;
  }

  Pipeline through(handlers) {
    this.handlers = handlers;

    return this;
  }

  FutureOr<T> then<T>(Function destination) {
    var pipeline = handlers.reversed.fold((passable) {
      return destination(passable);
    }, (next, handler) {
      return (passable) {
        var handle = handler is Type ? container.get(handler).handle : handler;

        return handle(passable, next);
      };
    });

    return pipeline(passable);
  }

  FutureOr thenReturn() {
    return then((passable) => passable);
  }
}
