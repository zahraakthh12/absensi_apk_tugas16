import 'package:flutter/material.dart';

extension ExtendedNavigator on BuildContext {
  Future<dynamic> push(Widget page, {String? name}) async {
    return Navigator.push(
      this,
      MaterialPageRoute(
        builder: (_) => page,
        settings: RouteSettings(name: name ?? page.runtimeType.toString()),
      ),
    );
  }

  Future<dynamic> pushReplacement(Widget page, {String? name}) async {
    return Navigator.pushReplacement(
      this,
      MaterialPageRoute(
        builder: (_) => page,
        settings: RouteSettings(name: name ?? page.runtimeType.toString()),
      ),
    );
  }

  Future<dynamic> pushRoute(Route route) async {
    return Navigator.of(this).push(route);
  }

  Future<dynamic> pushRouteAndRemoveUntil(
    Route newRoute,
    RoutePredicate predicate,
  ) async {
    Navigator.pushAndRemoveUntil(this, newRoute, predicate);
  }

  Future<dynamic> pushRouteAndRemoveAll(Route newRoute) async {
    Navigator.pushAndRemoveUntil(this, newRoute, (route) => false);
  }

  void pop([result]) async {
    return Navigator.of(this).pop(result);
  }
}