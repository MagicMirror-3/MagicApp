import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MagicRefresher extends StatelessWidget {
  MagicRefresher(
      {required this.childWidget,
      Key? key,
      this.pullDown = true,
      this.pullUp = false,
      this.onLoading,
      this.onRefresh,
      this.initialRefresh = false})
      : super(key: key);

  final Widget childWidget;
  final bool pullDown;
  final bool pullUp;
  final Future<bool> Function()? onLoading;
  final Future<bool> Function()? onRefresh;

  final bool initialRefresh;
  late final RefreshController _controller = RefreshController(
    initialRefresh: initialRefresh,
  );

  void _refreshCallback() async {
    if (onRefresh != null) {
      bool success = await onRefresh!();

      if (success) {
        _controller.refreshCompleted();
      } else {
        _controller.refreshFailed();
      }
    }
  }

  void _loadingCallback() async {
    if (onLoading != null) {
      bool success = await onLoading!();

      if (success) {
        _controller.loadComplete();
      } else {
        _controller.loadFailed();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: _controller,
      header: const ClassicHeader(),
      child: childWidget,
      enablePullDown: pullDown,
      enablePullUp: pullUp,
      onLoading: _loadingCallback,
      onRefresh: _refreshCallback,
    );
  }
}
