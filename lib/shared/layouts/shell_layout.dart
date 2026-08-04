import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/sidebar/dynamic_sidebar.dart';
import '../../core/providers/sidebar_provider.dart';

class ShellLayout extends ConsumerWidget {
  final Widget child;

  const ShellLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSidebarVisible = ref.watch(sidebarVisibleProvider);

    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1024;

    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOut,
                width: (isDesktop && isSidebarVisible) ? 250.0 : 0.0,
                child: ClipRect(
                  child: OverflowBox(
                    minWidth: 250.0,
                    maxWidth: 250.0,
                    alignment: Alignment.topLeft,
                    child: const SizedBox(
                      width: 250.0,
                      child: DynamicSidebar(),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: child,
              ),
            ],
          ),
          
          // Mobile/Tablet Sidebar Overlay
          if (!isDesktop)
            IgnorePointer(
              ignoring: !isSidebarVisible,
              child: Stack(
                children: [
                  // Scrim
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOut,
                    opacity: isSidebarVisible ? 1.0 : 0.0,
                    child: GestureDetector(
                      onTap: () => ref.read(sidebarVisibleProvider.notifier).state = false,
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  // Sliding Sidebar
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutBack,
                    left: isSidebarVisible ? 0.0 : -250.0,
                    top: 0,
                    bottom: 0,
                    width: 250,
                    child: const DynamicSidebar(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
