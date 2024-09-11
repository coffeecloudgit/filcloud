import 'package:flutter/material.dart';

/// `VoidFutureBuilder` 是一个适配于 GetX 包的 `FutureBuilder` 封装组件
///
/// 通过传入 `future` 和 `builder` 参数，达成对 `Future<void>` 类型的数据的构建
/// 由 `VoidFutureBuilder` 负责局部组件初始化
/// 由 `builder` 绑定 `Obx` 来负责局部组件的后续更新
class VoidFutureBuilder extends StatefulWidget {
  final Future<void>? future;
  final Widget Function(BuildContext context) builder;

  const VoidFutureBuilder(
      {super.key, required this.future, required this.builder});

  @override
  State<VoidFutureBuilder> createState() => _VoidFutureBuilderState();
}

class _VoidFutureBuilderState extends State<VoidFutureBuilder> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: widget.future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text('Error${snapshot.error}'));
            } else {
              return widget.builder(context);
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}
