import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/auth_provider.dart';
import '../providers/game_provider.dart';
import '../utils/global_keys.dart';
import 'my_lands_sheet.dart';

class GameEdgePanelOverlay extends StatefulWidget {
  final Widget child;

  const GameEdgePanelOverlay({super.key, required this.child});

  @override
  State<GameEdgePanelOverlay> createState() => _GameEdgePanelOverlayState();
}

class _GameEdgePanelOverlayState extends State<GameEdgePanelOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  bool _isOpen = false;
  bool _isHiddenForSheet = false;

  final double _panelWidth = 90.0;
  final double _handleWidth = 24.0;
  final double _handleHeight = 64.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _togglePanel() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _closePanel() {
    if (_isOpen) {
      setState(() {
        _isOpen = false;
        _animationController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final gameProvider = Provider.of<GameProvider>(context);

    // Only show for investors who have the setting enabled
    final shouldShow =
        authProvider.user?.role == 'investor' &&
        gameProvider.showEdgePanel &&
        !gameProvider.isLoading &&
        !_isHiddenForSheet;

    return Stack(
      children: [
        // The main app content
        widget.child,

        // Overlay to catch taps outside to dismiss ONLY when open
        if (_isOpen && shouldShow)
          Positioned.fill(
            child: GestureDetector(
              onTap: _closePanel,
              behavior: HitTestBehavior.opaque,
              child: Container(
                color: Colors.black.withOpacity(0.02),
              ), // very faint shadow
            ),
          ),

        // The Edge Panel itself
        if (shouldShow)
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              // Offset logic: when 0, panel is hidden, only handle shows
              // when 1, panel is fully visible
              final double offset =
                  (_panelWidth) * (1.0 - _slideAnimation.value);

              return Positioned(
                right: -offset,
                top:
                    MediaQuery.of(context).size.height / 2 -
                    (_handleHeight / 2) -
                    40,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Slide Handle
                    GestureDetector(
                      onHorizontalDragEnd: (details) {
                        if (details.primaryVelocity != null) {
                          if (details.primaryVelocity! < 0 && !_isOpen) {
                            _togglePanel(); // Swipe left to open
                          } else if (details.primaryVelocity! > 0 && _isOpen) {
                            _closePanel(); // Swipe right to close
                          }
                        }
                      },
                      onTap: _togglePanel,
                      child: Container(
                        width: _handleWidth,
                        height: _handleHeight,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 6,
                              offset: const Offset(-2, 0),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 3.5,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).dividerColor.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Panel Content
                    Container(
                      width: _panelWidth,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(0),
                          bottomLeft: Radius.circular(16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 10,
                            offset: const Offset(
                              -4,
                              0,
                            ), // cast shadow to the left
                          ),
                        ],
                      ),
                      child: Center(
                        child: AnimatedOpacity(
                          opacity: _isOpen ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: _isOpen
                              ? Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: () async {
                                      _closePanel();
                                      setState(() {
                                        _isHiddenForSheet = true;
                                      });

                                      // Use navigatorKey.currentContext to access the Navigator
                                      if (navigatorKey.currentContext != null) {
                                        await showModalBottomSheet(
                                          context: navigatorKey.currentContext!,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (context) =>
                                              const MyLandsBottomSheet(),
                                        );
                                      }

                                      if (mounted) {
                                        setState(() {
                                          _isHiddenForSheet = false;
                                        });
                                      }
                                    },
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white.withOpacity(0.05)
                                            : Colors.grey.shade50,
                                        border: Border.all(
                                          color: Theme.of(
                                            context,
                                          ).dividerColor.withOpacity(0.1),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.08,
                                            ),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: SvgPicture.asset(
                                          'assets/game_images/land-red-location.svg',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
