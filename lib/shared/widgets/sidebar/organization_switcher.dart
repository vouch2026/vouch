import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../features/organizations/providers/workspace_provider.dart';
import '../../../../features/organizations/providers/organization_provider.dart';
import '../../../../features/organizations/models/organization_model.dart';

class OrganizationSwitcher extends ConsumerStatefulWidget {
  const OrganizationSwitcher({super.key});

  @override
  ConsumerState<OrganizationSwitcher> createState() => _OrganizationSwitcherState();
}

class _OrganizationSwitcherState extends ConsumerState<OrganizationSwitcher> {
  bool _isSwitching = false;
  bool _isDropdownOpen = false;
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _cardKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  ScrollPosition? _scrollPosition;

  @override
  void dispose() {
    _closeDropdown();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    if (_isDropdownOpen) return;

    final renderBox = _cardKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final width = renderBox.size.width;

    // Calculate position and available height to prevent overextending past screen/sidebar bottom
    final position = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final availableHeight = screenHeight - position.dy - renderBox.size.height - 16;
    final maxHeight = availableHeight.clamp(80.0, 250.0);

    final workspace = ref.read(workspaceProvider);
    final selectedOrg = workspace.selectedOrganization;
    final orgsAsyncValue = ref.read(userOrganizationsProvider);
    final orgs = orgsAsyncValue.value ?? [];

    // Register scroll listener to dismiss dropdown on parent scroll
    final scrollable = Scrollable.maybeOf(context);
    if (scrollable != null) {
      _scrollPosition = scrollable.position;
      _scrollPosition?.addListener(_closeDropdown);
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Translucent tap barrier to close the dropdown on outer clicks
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _closeDropdown,
            child: const SizedBox.expand(),
          ),
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            targetAnchor: Alignment.bottomLeft,
            followerAnchor: Alignment.topLeft,
            offset: const Offset(0, -1.2), // Tiny negative offset to overlap borders seamlessly
            child: Material(
              color: Colors.transparent,
              child: _DropdownMenu(
                orgs: orgs,
                selectedOrg: selectedOrg,
                workspace: workspace,
                width: width,
                maxHeight: maxHeight,
                onSelected: (org) async {
                  _closeDropdown();
                  if (org?.id == selectedOrg?.id && org != null) return;

                  setState(() => _isSwitching = true);
                  await ref.read(workspaceProvider.notifier).selectOrganization(org);
                  if (mounted) {
                    setState(() => _isSwitching = false);
                  }
                },
                onClose: _closeDropdown,
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isDropdownOpen = true;
    });
  }

  void _closeDropdown() {
    if (!_isDropdownOpen) return;

    // Remove scroll listener
    _scrollPosition?.removeListener(_closeDropdown);
    _scrollPosition = null;

    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() {
        _isDropdownOpen = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final workspace = ref.watch(workspaceProvider);
    final selectedOrg = workspace.selectedOrganization;
    final userOrgsAsync = ref.watch(userOrganizationsProvider);

    return userOrgsAsync.when(
      data: (orgs) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        child: Stack(
          children: [
            CompositedTransformTarget(
              link: _layerLink,
              child: Container(
                key: _cardKey,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: _isDropdownOpen
                      ? const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        )
                      : BorderRadius.circular(16),
                  border: Border.all(
                    color: _isDropdownOpen
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : (selectedOrg == null ? AppColors.primary.withValues(alpha: 0.3) : Colors.grey.shade200),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: _isDropdownOpen ? 0.05 : 0.03),
                      blurRadius: _isDropdownOpen ? 12 : 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: _isSwitching ? null : _toggleDropdown,
                  borderRadius: _isDropdownOpen
                      ? const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        )
                      : BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Row(
                      children: [
                        _OrgAvatar(
                          logoUrl: selectedOrg?.logoUrl,
                          isGlobal: selectedOrg == null,
                          type: selectedOrg?.type,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                selectedOrg?.name ?? 'Select Organization',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                selectedOrg != null
                                    ? (workspace.activeRole?.roleName ?? 'Member')
                                    : 'Switch Workspace',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: selectedOrg == null ? AppColors.primary : AppColors.textGrey,
                                  fontWeight: selectedOrg == null ? FontWeight.w600 : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_isSwitching)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: FlickrLoader(),
                          )
                        else
                          AnimatedRotation(
                            turns: _isDropdownOpen ? 0.5 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.textGrey,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_isSwitching)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
          ],
        ),
      ),
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Center(child: SizedBox(width: 20, height: 20, child: FlickrLoader())),
      ),
      error: (err, stack) {
        debugPrint('Error in userOrganizationsProvider: $err\n$stack');
        return const SizedBox.shrink();
      },
    );
  }
}

class _DropdownMenu extends StatefulWidget {
  final List<OrganizationModel> orgs;
  final OrganizationModel? selectedOrg;
  final WorkspaceState workspace;
  final ValueChanged<OrganizationModel?> onSelected;
  final double width;
  final double maxHeight;
  final VoidCallback onClose;

  const _DropdownMenu({
    required this.orgs,
    required this.selectedOrg,
    required this.workspace,
    required this.onSelected,
    required this.width,
    required this.maxHeight,
    required this.onClose,
  });

  @override
  State<_DropdownMenu> createState() => _DropdownMenuState();
}

class _DropdownMenuState extends State<_DropdownMenu> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<double>(begin: -8, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {}, // Consume taps inside the dropdown card
        child: Container(
          width: widget.width,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: widget.maxHeight),
                  child: widget.orgs.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Center(
                            child: Text(
                              'No workspaces found',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.textGrey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                          itemCount: widget.orgs.length,
                          itemBuilder: (context, index) {
                            final org = widget.orgs[index];
                            final isSelected = widget.selectedOrg?.id == org.id;
                            return _OrgItem(
                              name: org.name,
                              role: org.code,
                              logoUrl: org.logoUrl,
                              type: org.type,
                              isSelected: isSelected,
                              onTap: () => widget.onSelected(org),
                            );
                          },
                        ),
                ),
              ),
              if (widget.selectedOrg != null) ...[
                const Divider(height: 1, thickness: 0.5),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  child: _GlobalHubItem(
                    onTap: () => widget.onSelected(null),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _OrgAvatar extends StatelessWidget {
  final String? logoUrl;
  final bool isGlobal;
  final String? type;

  const _OrgAvatar({this.logoUrl, this.isGlobal = false, this.type});

  @override
  Widget build(BuildContext context) {
    final IconData fallbackIcon = isGlobal 
        ? Icons.business_rounded 
        : (type == 'comselec' ? Icons.how_to_vote_rounded : Icons.corporate_fare_rounded);

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isGlobal ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        image: logoUrl != null
            ? DecorationImage(image: NetworkImage(logoUrl!), fit: BoxFit.cover)
            : null,
      ),
      child: logoUrl == null
          ? Icon(
              fallbackIcon,
              color: isGlobal ? AppColors.primary : Colors.grey.shade400,
              size: 20,
            )
          : null,
    );
  }
}

class _OrgItem extends StatelessWidget {
  final String name;
  final String role;
  final String? logoUrl;
  final String? type;
  final bool isSelected;
  final VoidCallback onTap;

  const _OrgItem({
    required this.name,
    required this.role,
    this.logoUrl,
    this.type,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : Colors.transparent,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            hoverColor: AppColors.primary.withValues(alpha: 0.02),
            splashColor: AppColors.primary.withValues(alpha: 0.06),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
              child: Row(
                children: [
                  _OrgAvatar(logoUrl: logoUrl, type: type),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                            color: isSelected ? AppColors.primary : AppColors.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          role,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: isSelected ? AppColors.primary.withValues(alpha: 0.7) : AppColors.textGrey,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlobalHubItem extends StatelessWidget {
  final VoidCallback onTap;

  const _GlobalHubItem({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            hoverColor: AppColors.primary.withValues(alpha: 0.04),
            splashColor: AppColors.primary.withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.grid_view_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Personal Hub',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          'Exit current workspace',
                          style: GoogleFonts.poppins(
                            fontSize: 9.5,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_right_alt_rounded,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
