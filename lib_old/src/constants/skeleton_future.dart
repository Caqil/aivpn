import 'package:flutter/cupertino.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SkeletonFutureBuilder<T> extends StatefulWidget {
  SkeletonFutureBuilder({
    super.key,
    required this.future,
    required this.builder,
    this.mock_data,
    Widget? loadingWidget, // used if mock_data is null
    Widget? errorWidget, // returned if an error occured
  }) {
    this.loadingWidget = loadingWidget ??
        const Center(
            child:
                CupertinoActivityIndicator()); 
    this.errorWidget =
        errorWidget ?? const Text('');
  }
  final Future<T> future;
  final T? mock_data;

  final Widget Function(BuildContext context, AsyncSnapshot<T> snapshot)
      builder;
  late final Widget loadingWidget;
  late final Widget errorWidget;
  late final void Function(dynamic error) onError;

  @override
  _SkeletonizingFutureBuilderState<T> createState() =>
      _SkeletonizingFutureBuilderState<T>();
}

class _SkeletonizingFutureBuilderState<T>
    extends State<SkeletonFutureBuilder<T>> {
  bool is_loading = true;

  @override
  void initState() {
    super.initState();

    widget.future.then((value) {
      setState(() {
        is_loading = false;
      });
    });

    widget.future.onError((e, s) {
      setState(() {
        is_loading = false;
      });
      return Future.error(e ?? Object(), s);
    });
  }

  @override
  Widget build(BuildContext context) {
    final use_skeletonizer = widget.mock_data != null;

    final loading_widget = use_skeletonizer
        ? widget.builder(
            context,
            AsyncSnapshot.withData(
              ConnectionState.waiting,
              // ignore: null_check_on_nullable_type_parameter
              widget.mock_data!,
            ),
          )
        : widget.loadingWidget;

    final future_builder = FutureBuilder<T>(
      future: widget.future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.connectionState == ConnectionState.active ||
            snapshot.connectionState == ConnectionState.none) {
          return loading_widget;
        } else {
          if (snapshot.hasError) {
            final error = snapshot.error;

            // log error to sentry
            widget.onError(error);

            return widget.errorWidget;
          } else if (snapshot.hasData) {
            // call the builder with the real data
            return widget.builder(context, snapshot);
          } else {
            return loading_widget;
          }
        }
      },
    );

    if (use_skeletonizer) {
      return Skeletonizer(
        enabled: is_loading,
        child: future_builder,
      );
    } else {
      return future_builder;
    }
  }
}
