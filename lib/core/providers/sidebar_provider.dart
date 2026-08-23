import 'package:flutter_riverpod/flutter_riverpod.dart';

final sidebarVisibleProvider = StateProvider<bool>((ref) => false);

final sidebarScrollOffsetProvider = StateProvider<double>((ref) => 0.0);
