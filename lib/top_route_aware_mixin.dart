import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// A mixin for [State] classes that need to react when their screen becomes
/// or stops being the top (leaf) route in a [GoRouter] navigation stack.
///
/// ## Usage
///
/// ```dart
/// class _MyScreenState extends State<MyScreen> with TopRouteAwareMixin {
///   @override
///   String get routeAwareName => MyScreen.name;
///
///   @override
///   void onTopRouteGained() {
///     // e.g. start camera, resume stream
///   }
///
///   @override
///   void onTopRouteLost() {
///     // e.g. stop camera, pause stream
///   }
/// }
/// ```
///
/// The mixin handles [RouterDelegate] setup, listener registration, and
/// teardown automatically. It also fires an initial evaluation immediately
/// after attaching so the screen always starts in the correct state.
///
/// > **Note:** This mixin is strictly for [GoRouter] route tracking.
/// > App lifecycle management (foreground/background) is intentionally
/// > out of scope — handle that separately with [AppLifecycleListener].
mixin TopRouteAwareMixin<T extends StatefulWidget> on State<T> {
  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// The GoRoute [name] this screen owns.
  ///
  /// Must exactly match the `name` field declared in [GoRoute] inside the
  /// router configuration.
  String get routeAwareName;

  /// Called once when this screen transitions to being the top (leaf) route.
  ///
  /// Override to start resources (camera, streams, HID listeners, etc.).
  void onTopRouteGained() {}

  /// Called once when this screen is no longer the top (leaf) route.
  ///
  /// Override to stop or pause resources to prevent background activity.
  void onTopRouteLost() {}

  /// Whether this screen is currently the top route.
  ///
  /// Useful for conditional logic inside app lifecycle callbacks, e.g.:
  /// ```dart
  /// onResume: () { if (isTopRoute) _resumeStream(); }
  /// ```
  bool get isTopRoute => _isCurrentlyTopRoute;

  // ---------------------------------------------------------------------------
  // Internal state
  // ---------------------------------------------------------------------------

  bool _isCurrentlyTopRoute = false;
  RouterDelegate<Object>? _routerDelegate;

  // ---------------------------------------------------------------------------
  // Lifecycle overrides
  // ---------------------------------------------------------------------------

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // One-shot initialization: attach once and never re-attach on subsequent
    // didChangeDependencies calls (e.g. theme/locale changes).
    if (_routerDelegate == null) {
      _routerDelegate = GoRouter.of(context).routerDelegate;
      _routerDelegate?.addListener(_evaluateRouteState);
      // Evaluate immediately so the screen starts in the correct state
      // rather than waiting for the first navigation event.
      _evaluateRouteState();
    }
  }

  @override
  @mustCallSuper
  void dispose() {
    _routerDelegate?.removeListener(_evaluateRouteState);
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Private logic
  // ---------------------------------------------------------------------------

  /// Single source of truth for determining whether this screen is the top
  /// route. Guards against calling hooks redundantly if the route hasn't
  /// actually changed.
  void _evaluateRouteState() {
    if (!mounted) return;

    String? topRouteName;
    if (_routerDelegate is GoRouterDelegate) {
      final config =
          (_routerDelegate as GoRouterDelegate).currentConfiguration;
      if (config.isNotEmpty) {
        // config.last.route is typed as GoRoute in the current go_router
        // version, but the check is kept as a forward-compatible defensive
        // guard in case the return type widens (e.g. to RouteBase) in a
        // future version where ShellRoute could appear at the leaf.
        final route = config.last.route;
        // ignore: unnecessary_type_check
        if (route is GoRoute) {
          topRouteName = route.name;
        }
      }
    }

    final isTop = topRouteName == routeAwareName;

    if (isTop && !_isCurrentlyTopRoute) {
      _isCurrentlyTopRoute = true;
      onTopRouteGained();
    } else if (!isTop && _isCurrentlyTopRoute) {
      _isCurrentlyTopRoute = false;
      onTopRouteLost();
    }
  }
}
