import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// A mixin for [State] classes that need to react when their screen is both
/// the top (leaf) route in a [GoRouter] navigation stack **and** the host app
/// is in the foreground.
///
/// This solves the "Double Fire" problem: hardware controllers (like native
/// cameras) must strictly alternate between `start()` and `stop()` commands
/// without race conditions, regardless of whether focus is lost via a Flutter
/// navigation push, an OS backgrounding event, or both simultaneously.
///
/// ## Usage
///
/// ```dart
/// class _MyScreenState extends State<MyScreen>
///     with TopRouteAndLifecycleMixin {
///   @override
///   String get routeAwareName => MyScreen.name;
///
///   @override
///   void onScreenActive() {
///     // Both conditions met: top route AND foreground.
///     // e.g. start camera, resume stream
///   }
///
///   @override
///   void onScreenInactive() {
///     // At least one condition lost: navigated away OR backgrounded.
///     // e.g. stop camera, pause stream
///   }
/// }
/// ```
///
/// The mixin handles [RouterDelegate] setup, [AppLifecycleListener]
/// registration, and teardown automatically. It fires an initial evaluation
/// immediately after attaching so the screen always starts in the correct
/// state.
///
/// ### State Machine
///
/// Two independent boolean inputs feed a single deterministic gate:
///
/// | `_isTopRoute` | `_isAppInForeground` | `shouldBeActive` |
/// |---|---|---|
/// | ✅ | ✅ | ✅ → `onScreenActive()` |
/// | ✅ | ❌ | ❌ → `onScreenInactive()` |
/// | ❌ | ✅ | ❌ → `onScreenInactive()` |
/// | ❌ | ❌ | ❌ → `onScreenInactive()` |
///
/// The callbacks are guaranteed to fire as **strict alternating pairs** —
/// it is impossible to receive two consecutive [onScreenActive] calls.
mixin TopRouteAndLifecycleMixin<T extends StatefulWidget> on State<T> {
  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// The GoRoute [name] this screen owns.
  ///
  /// Must exactly match the `name` field declared in [GoRoute] inside the
  /// router configuration.
  String get routeAwareName;

  /// Whether this screen is currently considered "active" — meaning it is the
  /// top route **and** the app is in the foreground.
  ///
  /// Useful for conditional logic in callbacks that are outside the mixin's
  /// control, e.g.:
  /// ```dart
  /// onBarcodeScanned: (code) { if (isScreenActive) _process(code); }
  /// ```
  bool get isScreenActive => _isCurrentlyActive;

  /// Called exactly once when this screen transitions to being active.
  ///
  /// "Active" means both conditions are true:
  /// 1. This screen is the top (leaf) route.
  /// 2. The host app is in the foreground.
  ///
  /// Override to start resources (camera, streams, HID listeners, etc.).
  void onScreenActive() {}

  /// Called exactly once when this screen transitions to being inactive.
  ///
  /// "Inactive" means at least one condition is no longer true:
  /// - The screen is no longer the top route (user navigated away), **or**
  /// - The host app left the foreground (user locked screen / switched apps).
  ///
  /// Override to stop or pause resources to prevent background activity.
  void onScreenInactive() {}

  // ---------------------------------------------------------------------------
  // Internal state
  // ---------------------------------------------------------------------------

  /// The published combined state — `true` iff `_isTopRoute && _isAppInForeground`.
  bool _isCurrentlyActive = false;

  /// Set by the route-delegate listener.
  bool _isTopRoute = false;

  /// Set by [AppLifecycleListener]. Defaults to `true` because the app starts
  /// in the foreground — the OS will notify us if that changes.
  bool _isAppInForeground = true;

  /// Cached reference for one-shot attachment in [didChangeDependencies].
  RouterDelegate<Object>? _routerDelegate;

  /// Lifecycle listener initialized once in [initState].
  late final AppLifecycleListener _lifecycleListener;

  // ---------------------------------------------------------------------------
  // Lifecycle overrides
  // ---------------------------------------------------------------------------

  @override
  @mustCallSuper
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onResume: () {
        _isAppInForeground = true;
        _evaluateCombinedState();
      },
      // onHide fires first on iOS; onPause fires on Android.
      // Covering both ensures cross-platform correctness.
      onHide: () {
        _isAppInForeground = false;
        _evaluateCombinedState();
      },
      onPause: () {
        _isAppInForeground = false;
        _evaluateCombinedState();
      },
      // onInactive is intentionally NOT mapped here. Transient interruptions
      // (notification shade, incoming call overlay) should not trigger a
      // deactivation cycle — doing so would cause a visible "black flash"
      // when the camera remounts for a momentary interruption.
    );
  }

  @override
  @mustCallSuper
  void didChangeDependencies() {
    super.didChangeDependencies();
    // One-shot initialization: attach once and never re-attach on subsequent
    // didChangeDependencies calls (e.g. theme/locale changes).
    if (_routerDelegate == null) {
      _routerDelegate = GoRouter.of(context).routerDelegate;
      _routerDelegate?.addListener(_onRouteChanged);
      // Evaluate immediately so the screen starts in the correct state
      // rather than waiting for the first navigation event.
      _onRouteChanged();
    }
  }

  @override
  @mustCallSuper
  void dispose() {
    _lifecycleListener.dispose();
    _routerDelegate?.removeListener(_onRouteChanged);
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Private logic
  // ---------------------------------------------------------------------------

  /// Route-delegate listener callback. Extracts the current top route name
  /// from [GoRouterDelegate.currentConfiguration] and updates [_isTopRoute].
  void _onRouteChanged() {
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

    _isTopRoute = topRouteName == routeAwareName;
    _evaluateCombinedState();
  }

  /// Single deterministic gate. Both the route listener and the lifecycle
  /// listener converge here. Guarantees that [onScreenActive] and
  /// [onScreenInactive] always fire as strict alternating pairs.
  void _evaluateCombinedState() {
    if (!mounted) return;

    final shouldBeActive = _isTopRoute && _isAppInForeground;

    if (shouldBeActive && !_isCurrentlyActive) {
      _isCurrentlyActive = true;
      onScreenActive();
    } else if (!shouldBeActive && _isCurrentlyActive) {
      _isCurrentlyActive = false;
      onScreenInactive();
    }
  }
}
