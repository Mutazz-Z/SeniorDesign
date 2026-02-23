import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum _RefreshState { idle, dragging, loading, complete }

class CustomRefreshIndicator extends StatefulWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  final double refreshTriggerPullDistance;
  final double indicatorExtent;

  const CustomRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    this.refreshTriggerPullDistance = 100.0,
    this.indicatorExtent = 100.0,
  });

  @override
  State<CustomRefreshIndicator> createState() => _CustomRefreshIndicatorState();
}

class _CustomRefreshIndicatorState extends State<CustomRefreshIndicator>
    with TickerProviderStateMixin {
  // -- State --
  _RefreshState _state = _RefreshState.idle;
  double _dragOffset = 0.0;

  // -- Controllers --
  late AnimationController _loadingPulseController;
  late AnimationController _popController;
  late Animation<double> _popAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Pulse animation for the loading state
    _loadingPulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // 2. Pop Controller (Simple Up/Down)
    _popController = AnimationController(
      duration: const Duration(milliseconds: 150), // Fast 150ms up, 150ms down
      vsync: this,
    );

    _popAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _popController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _loadingPulseController.dispose();
    _popController.dispose();
    super.dispose();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (_state == _RefreshState.loading || _state == _RefreshState.complete) {
      return false;
    }

    if (notification is ScrollUpdateNotification) {
      if (notification.metrics.pixels < 0) {
        final double overscroll = notification.metrics.pixels.abs();

        if (_state != _RefreshState.dragging) {
          setState(() {
            _state = _RefreshState.dragging;
          });
        }

        setState(() {
          _dragOffset = overscroll;
        });

        // iOS Logic: Trigger when user lifts finger
        if (notification.dragDetails == null &&
            overscroll >= widget.refreshTriggerPullDistance) {
          _triggerRefresh();
        }
      } else {
        if (_dragOffset > 0) {
          setState(() {
            _dragOffset = 0.0;
            _state = _RefreshState.idle;
          });
        }
      }
    } else if (notification is ScrollEndNotification) {
      if (_dragOffset >= widget.refreshTriggerPullDistance) {
        _triggerRefresh();
      } else {
        setState(() {
          _dragOffset = 0.0;
          _state = _RefreshState.idle;
        });
      }
    }
    return false;
  }

  Future<void> _triggerRefresh() async {
    if (_state == _RefreshState.loading) return;

    HapticFeedback.mediumImpact();

    setState(() {
      _state = _RefreshState.loading;
    });

    // --- TRIGGER THE POP ---
    await _popController.forward();
    _popController.reverse();

    // Start Breathing
    _loadingPulseController.repeat(reverse: true);

    try {
      await widget.onRefresh();

      if (mounted) {
        setState(() {
          _state = _RefreshState.complete;
        });
        _loadingPulseController.stop();
        _loadingPulseController.value = 1.0;

        await Future.delayed(const Duration(milliseconds: 800));

        if (mounted) {
          setState(() {
            _dragOffset = 0.0;
            _state = _RefreshState.idle;
          });
          _popController.reset();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _dragOffset = 0.0;
          _state = _RefreshState.idle;
        });
        _loadingPulseController.stop();
        _popController.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double progress = 0.0;
    double topPosition = 0.0;

    if (_state == _RefreshState.dragging) {
      progress =
          (_dragOffset / widget.refreshTriggerPullDistance).clamp(0.0, 1.0);

      // CHANGED: Increased multiplier (0.75) so it moves further down
      // CHANGED: Increased clamp (200.0) so you can pull it deeper
      topPosition = (_dragOffset * 0.75).clamp(0.0, 200.0);
    } else if (_state == _RefreshState.loading ||
        _state == _RefreshState.complete) {
      progress = 1.0;

      // CHANGED: Resting position is now 110.0 (was 50.0)
      // This ensures it sits lower on the screen while loading
      topPosition = 110.0;
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final logoAsset = isDarkMode
        ? 'assets/Reload_Logo_A-Dark.svg'
        : 'assets/Reload_Logo_A-Light.svg';
    const checkAsset = 'assets/Reload_Logo_Check.svg';

    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: _handleScrollNotification,
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: widget.child,
          ),
        ),
        if (_dragOffset > 0 || _state != _RefreshState.idle)
          AnimatedPositioned(
            duration: _state == _RefreshState.dragging
                ? Duration.zero
                : const Duration(milliseconds: 400),
            curve: Curves.elasticOut,
            top: topPosition,
            left: 0,
            right: 0,
            child: Center(
              child: ScaleTransition(
                scale: _popAnimation,
                child: Opacity(
                  opacity: progress,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: SvgPicture.asset(
                            logoAsset,
                            width: 40,
                            height: 40,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: ClipRect(
                            clipper: _HorizontalRevealClipper(progress),
                            child: FadeTransition(
                              opacity: _state == _RefreshState.loading
                                  ? Tween<double>(begin: 0.5, end: 1.0)
                                      .animate(_loadingPulseController)
                                  : const AlwaysStoppedAnimation(1.0),
                              child: SvgPicture.asset(
                                checkAsset,
                                width: 40,
                                height: 40,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _HorizontalRevealClipper extends CustomClipper<Rect> {
  final double progress;

  _HorizontalRevealClipper(this.progress);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width * progress, size.height);
  }

  @override
  bool shouldReclip(_HorizontalRevealClipper oldClipper) {
    return oldClipper.progress != progress;
  }
}
