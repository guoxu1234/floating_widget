import 'package:flutter/material.dart';

class FloatingWidget extends StatelessWidget {
  const FloatingWidget({
    Key? key,
    this.children = const <Widget>[],
    required this.floatingChild,
  }) : super(key: key);
  final List<Widget> children;

  final Widget floatingChild;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Stack(
        children: [
          ...children,
          _Floating(floatingChild, constraints.maxWidth, constraints.maxHeight),
        ],
      );
    });
  }
}

class _Floating extends StatefulWidget {
  const _Floating(this.child, this.maxWidth, this.maxHeight, {Key? key})
      : super(key: key);
  final Widget child;
  final double maxWidth, maxHeight;

  @override
  _FloatingState createState() => _FloatingState();
}

class _FloatingState extends State<_Floating>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 500),
    vsync: this,
  );

  late Animation<Offset> _animation = Tween<Offset>(
    begin: Offset(x, y),
    end: Offset(dx, dy),
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.elasticOut,
  ));

  late double x = 0, y = 0, dx = 0, dy = 0;

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  void initState() {
    super.initState();
    _animation.addListener(() {
      setState(() {
        x = _animation.value.dx;
        y = _animation.value.dy;
      });
    });
  }

  Size? _childSize;
  late double _rightBoundary;
  late double _bottomBoundary;

  void _down() {
    if (_childSize != null) return;
    _childSize = context.size!;
    _rightBoundary = widget.maxWidth - _childSize!.width;
    _bottomBoundary = widget.maxHeight - _childSize!.height;
  }

  void _upate(details) {
    if (x < 0) {
      x = 0;
    }
    if (x > _rightBoundary) {
      x = _rightBoundary;
    }
    if (y < 0) {
      y = 0;
    }
    if (y > _bottomBoundary) {
      y = _bottomBoundary;
    }
    if (x > widget.maxWidth / 2) {
      dx = _rightBoundary;
    } else {
      dx = 0;
    }
    setState(() {
      x += details.delta.dx;
      y += details.delta.dy;
      dy = y;
    });
  }

  void _end() {
    _animation = Tween<Offset>(
      begin: Offset(x, y),
      end: Offset(dx, dy),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x,
      top: y,
      child: GestureDetector(
        child: widget.child,
        onPanDown: (_) => _down(),
        onPanUpdate: (details) => _upate(details),
        onPanEnd: (details) => _end(),
      ),
    );
  }
}
