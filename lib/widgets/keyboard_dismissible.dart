import 'package:flutter/material.dart';

/// 子ウィジェット外をタップしたときにキーボードを閉じるラッパー。
/// TextFormField などを持つ画面の Scaffold.body に適用する。
class KeyboardDismissible extends StatelessWidget {
  const KeyboardDismissible({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: child,
    );
  }
}
