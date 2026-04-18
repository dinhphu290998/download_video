import 'package:flutter/material.dart';

class LoadingAnimationWidget extends StatefulWidget {
  @override
  State<LoadingAnimationWidget> createState() => _LoadingAnimationWidgetState();
}

class _LoadingAnimationWidgetState extends State<LoadingAnimationWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    // TODO: implement initState
    _animationController =
    AnimationController(vsync: this, duration: Duration(seconds: 4))
      ..repeat();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              AnimatedBuilder(
                  animation: _animationController,
                  child: Container(
                    height: 80,
                    width: 80,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Image(
                        height: 80,
                        width: 80,
                        image: AssetImage('assets/logo/logo.png'),
                      ),
                    ),
                  ), 
                  builder: (context, widget) {
                return Transform.rotate(angle: _animationController.value*18, child: widget,);
              })
          ],
        )
      ),
    );
  }
}
