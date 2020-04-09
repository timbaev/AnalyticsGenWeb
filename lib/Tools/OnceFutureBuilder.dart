import 'package:flutter/widgets.dart';

typedef Future<T> GetFuture<T>();

class OnceFutureBuilder<T> extends StatefulWidget {
  final GetFuture<T> future;
  final AsyncWidgetBuilder<T> builder;
  final T initialData;

  OnceFutureBuilder({this.future, this.builder, this.initialData});

  @override
  State<OnceFutureBuilder<T>> createState() => _OnceFutureBuilderState<T>();
}

class _OnceFutureBuilderState<T> extends State<OnceFutureBuilder<T>> {
  Future<T> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.future();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      initialData: widget.initialData,
      builder: widget.builder,
      future: _future,
    );
  }
}