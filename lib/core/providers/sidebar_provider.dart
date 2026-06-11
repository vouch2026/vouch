import 'package:flutter_riverpod/flutter_riverpod.dart';

final sidebarVisibleProvider = StateProvider<bool>((ref) => true);

final sidebarScrollOffsetProvider = StateProvider<double>((ref) => 0.0);
