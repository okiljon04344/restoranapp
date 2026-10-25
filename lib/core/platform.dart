import 'package:flutter/foundation.dart';

/// True where staff and customers choose a role by mouse (web and desktop),
/// false on phones where the customer goes straight to table entry.
bool get isDesktopLike =>
    kIsWeb ||
    defaultTargetPlatform == TargetPlatform.macOS ||
    defaultTargetPlatform == TargetPlatform.windows ||
    defaultTargetPlatform == TargetPlatform.linux;
