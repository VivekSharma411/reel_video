import 'package:flutter/material.dart';

import '../injection.dart';
import '../service/navigation_service.dart';

/// Global BuildContext
final BuildContext context =
    getIt<NavigationService>().navigationKey.currentContext!;
