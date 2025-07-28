import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:integrador/core/navigation/route_names.dart';
import 'package:integrador/global/nav.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final String location;

  const MainLayout({
    super.key,
    required this.child,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _getCurrentIndex(location),
        onTap: (index) => _onNavBarTap(context, index),
        items: NavBarConfigs.yoloxochitlItems,
      ),
    );
  }

  int _getCurrentIndex(String location) {
    switch (location) {
      case RouteNames.home:
        return 0;
      case RouteNames.lessons:
        return 1;
      case RouteNames.practice:
      case RouteNames.traductor:
      case RouteNames.game:
        return 2;
      case RouteNames.profile:
        return 3;
      default:
        return 0;
    }
  }

  void _onNavBarTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(RouteNames.home);
        break;
      case 1:
        context.go(RouteNames.lessons);
        break;
      case 2:
        context.go(RouteNames.practice);
        break;
      case 3:
        context.go(RouteNames.profile);
        break;
    }
  }
}