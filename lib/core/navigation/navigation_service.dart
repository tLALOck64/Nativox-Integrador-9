import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationService {
  static NavigationService? _instance;
  static GlobalKey<NavigatorState>? _navigatorKey;

  NavigationService._internal();

  factory NavigationService() {
    _instance ??= NavigationService._internal();
    return _instance!;
  }

  static GlobalKey<NavigatorState> get navigatorKey {
    _navigatorKey ??= GlobalKey<NavigatorState>();
    return _navigatorKey!;
  }

  static BuildContext? get context => navigatorKey.currentState?.context;

  // Navigation methods
  static void push(String routeName, {Object? arguments}) {
    if (context != null) {
      context!.push(routeName, extra: arguments);
    }
  }

  static void pushReplacement(String routeName, {Object? arguments}) {
    if (context != null) {
      context!.pushReplacement(routeName, extra: arguments);
    }
  }

  static void pushAndClearStack(String routeName, {Object? arguments}) {
    if (context != null) {
      context!.go(routeName, extra: arguments);
    }
  }

  static void pop([Object? result]) {
    if (context != null && context!.canPop()) {
      context!.pop(result);
    }
  }

  static void popUntil(String routeName) {
    if (context != null) {
      while (context!.canPop() && GoRouterState.of(context!).uri.toString() != routeName) {
        context!.pop();
      }
    }
  }

  // Utility methods
  static String get currentRoute {
    if (context != null) {
      return GoRouterState.of(context!).uri.toString();
    }
    return '';
  }

  static bool canPop() {
    return context?.canPop() ?? false;
  }

  // Dialog methods
  static Future<T?> showDialogCustom<T>({
    required Widget dialog,
    bool barrierDismissible = true,
  }) {
    if (context != null) {
      return showDialog<T>(
        context: context!,
        barrierDismissible: barrierDismissible,
        builder: (context) => dialog,
      );
    }
    return Future.value(null);
  }

  // BottomSheet methods
  static Future<T?> showBottomSheetCustom<T>({
    required Widget content,
    bool isScrollControlled = false,
  }) {
    if (context != null) {
      return showModalBottomSheet<T>(
        context: context!,
        isScrollControlled: isScrollControlled,
        builder: (context) => content,
      );
    }
    return Future.value(null);
  }
}