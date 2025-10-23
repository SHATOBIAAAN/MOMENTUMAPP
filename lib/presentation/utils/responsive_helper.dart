import 'package:flutter/material.dart';

/// Helper class for responsive and adaptive layouts
/// Provides utilities for different screen sizes and orientations
class ResponsiveHelper {
  ResponsiveHelper._();

  // Breakpoints (Material Design guidelines)
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  static const double largeDesktopBreakpoint = 1800;

  /// Get screen width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Get screen orientation
  static Orientation screenOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation;
  }

  /// Check if portrait orientation
  static bool isPortrait(BuildContext context) {
    return screenOrientation(context) == Orientation.portrait;
  }

  /// Check if landscape orientation
  static bool isLandscape(BuildContext context) {
    return screenOrientation(context) == Orientation.landscape;
  }

  /// Check if mobile device
  static bool isMobile(BuildContext context) {
    return screenWidth(context) < mobileBreakpoint;
  }

  /// Check if tablet device
  static bool isTablet(BuildContext context) {
    final width = screenWidth(context);
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  /// Check if desktop device
  static bool isDesktop(BuildContext context) {
    return screenWidth(context) >= desktopBreakpoint;
  }

  /// Check if large desktop
  static bool isLargeDesktop(BuildContext context) {
    return screenWidth(context) >= largeDesktopBreakpoint;
  }

  /// Get device type
  static DeviceType getDeviceType(BuildContext context) {
    final width = screenWidth(context);
    if (width < mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (width < desktopBreakpoint) {
      return DeviceType.tablet;
    } else if (width < largeDesktopBreakpoint) {
      return DeviceType.desktop;
    } else {
      return DeviceType.largeDesktop;
    }
  }

  /// Get responsive value based on screen size
  static T responsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? mobile;
    }
  }

  /// Get responsive font size
  static double responsiveFontSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return responsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// Get responsive padding
  static EdgeInsets responsivePadding(
    BuildContext context, {
    required EdgeInsets mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) {
    return responsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// Get responsive spacing
  static double responsiveSpacing(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return responsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// Get number of grid columns based on screen size
  static int responsiveGridColumns(BuildContext context) {
    return responsiveValue(
      context,
      mobile: 2,
      tablet: 3,
      desktop: 4,
      largeDesktop: 6,
    );
  }

  /// Get responsive grid aspect ratio
  static double responsiveGridAspectRatio(BuildContext context) {
    return responsiveValue(context, mobile: 0.8, tablet: 1.0, desktop: 1.2);
  }

  /// Get responsive max width for content
  static double responsiveMaxWidth(BuildContext context) {
    return responsiveValue(
      context,
      mobile: screenWidth(context),
      tablet: 720,
      desktop: 960,
      largeDesktop: 1200,
    );
  }

  /// Create responsive builder
  static Widget responsiveBuilder(
    BuildContext context, {
    required WidgetBuilder mobile,
    WidgetBuilder? tablet,
    WidgetBuilder? desktop,
    WidgetBuilder? largeDesktop,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile(context);
      case DeviceType.tablet:
        return (tablet ?? mobile)(context);
      case DeviceType.desktop:
        return (desktop ?? tablet ?? mobile)(context);
      case DeviceType.largeDesktop:
        return (largeDesktop ?? desktop ?? tablet ?? mobile)(context);
    }
  }

  /// Get responsive card width
  static double responsiveCardWidth(BuildContext context) {
    final screenW = screenWidth(context);
    if (isMobile(context)) {
      return screenW - 32; // Full width with padding
    } else if (isTablet(context)) {
      return (screenW - 48) / 2; // 2 columns
    } else if (isDesktop(context)) {
      return (screenW - 64) / 3; // 3 columns
    } else {
      return (screenW - 80) / 4; // 4 columns
    }
  }

  /// Get responsive card height
  static double responsiveCardHeight(BuildContext context) {
    return responsiveValue(
      context,
      mobile: 200,
      tablet: 220,
      desktop: 240,
      largeDesktop: 260,
    );
  }

  /// Get responsive icon size
  static double responsiveIconSize(BuildContext context, {double base = 24}) {
    return responsiveValue(
      context,
      mobile: base,
      tablet: base * 1.2,
      desktop: base * 1.4,
    );
  }

  /// Get responsive border radius
  static double responsiveBorderRadius(BuildContext context) {
    return responsiveValue(context, mobile: 12, tablet: 16, desktop: 20);
  }

  /// Get responsive app bar height
  static double responsiveAppBarHeight(BuildContext context) {
    return responsiveValue(context, mobile: 56, tablet: 64, desktop: 72);
  }

  /// Get responsive drawer width
  static double responsiveDrawerWidth(BuildContext context) {
    return responsiveValue(
      context,
      mobile: screenWidth(context) * 0.8,
      tablet: 320,
      desktop: 360,
    );
  }

  /// Create adaptive list view
  static Widget adaptiveListView({
    required BuildContext context,
    required List<Widget> children,
    ScrollPhysics? physics,
    EdgeInsetsGeometry? padding,
  }) {
    if (isMobile(context)) {
      return ListView(
        physics: physics,
        padding: padding ?? const EdgeInsets.all(16),
        children: children,
      );
    } else {
      return GridView.count(
        crossAxisCount: responsiveGridColumns(context),
        physics: physics,
        padding: padding ?? const EdgeInsets.all(24),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: children,
      );
    }
  }

  /// Create adaptive scaffold with navigation
  static Widget adaptiveScaffold({
    required BuildContext context,
    required Widget body,
    PreferredSizeWidget? appBar,
    Widget? drawer,
    Widget? floatingActionButton,
    List<Widget>? navigationItems,
  }) {
    if (isMobile(context)) {
      // Mobile: standard scaffold with drawer
      return Scaffold(
        appBar: appBar,
        drawer: drawer,
        body: body,
        floatingActionButton: floatingActionButton,
      );
    } else if (isTablet(context)) {
      // Tablet: scaffold with rail
      return Scaffold(
        appBar: appBar,
        body: Row(
          children: [
            if (navigationItems != null)
              NavigationRail(
                destinations: navigationItems
                    .map(
                      (item) => const NavigationRailDestination(
                        icon: Icon(Icons.home),
                        label: Text(''),
                      ),
                    )
                    .toList(),
                selectedIndex: 0,
                onDestinationSelected: (index) {},
              ),
            Expanded(child: body),
          ],
        ),
        floatingActionButton: floatingActionButton,
      );
    } else {
      // Desktop: scaffold with permanent drawer
      return Scaffold(
        appBar: appBar,
        body: Row(
          children: [
            if (drawer != null)
              Container(
                width: responsiveDrawerWidth(context),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                child: drawer,
              ),
            Expanded(child: body),
          ],
        ),
        floatingActionButton: floatingActionButton,
      );
    }
  }

  /// Get responsive column count for list
  static int getResponsiveColumnCount(BuildContext context) {
    final width = screenWidth(context);
    if (width < mobileBreakpoint) {
      return 1;
    } else if (width < tabletBreakpoint) {
      return 2;
    } else if (width < desktopBreakpoint) {
      return 3;
    } else if (width < largeDesktopBreakpoint) {
      return 4;
    } else {
      return 6;
    }
  }

  /// Get responsive dialog width
  static double responsiveDialogWidth(BuildContext context) {
    final width = screenWidth(context);
    if (isMobile(context)) {
      return width * 0.9;
    } else if (isTablet(context)) {
      return 500;
    } else {
      return 600;
    }
  }

  /// Get responsive bottom sheet max height
  static double responsiveBottomSheetMaxHeight(BuildContext context) {
    return screenHeight(context) * 0.9;
  }

  /// Create responsive container with max width
  static Widget responsiveContainer({
    required BuildContext context,
    required Widget child,
    double? maxWidth,
    EdgeInsetsGeometry? padding,
    AlignmentGeometry alignment = Alignment.center,
  }) {
    return Container(
      alignment: alignment,
      padding: padding,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? responsiveMaxWidth(context),
        ),
        child: child,
      ),
    );
  }

  /// Get responsive card elevation
  static double responsiveCardElevation(BuildContext context) {
    return responsiveValue(context, mobile: 2, tablet: 3, desktop: 4);
  }

  /// Get responsive button height
  static double responsiveButtonHeight(BuildContext context) {
    return responsiveValue(context, mobile: 48, tablet: 52, desktop: 56);
  }

  /// Get responsive text field height
  static double responsiveTextFieldHeight(BuildContext context) {
    return responsiveValue(context, mobile: 56, tablet: 60, desktop: 64);
  }

  /// Create responsive two-pane layout (master-detail)
  static Widget responsiveTwoPaneLayout({
    required BuildContext context,
    required Widget master,
    required Widget detail,
    double breakpoint = 900,
  }) {
    final width = screenWidth(context);
    if (width < breakpoint) {
      // Single pane (mobile)
      return master;
    } else {
      // Two panes (tablet/desktop)
      return Row(
        children: [
          SizedBox(width: width * 0.35, child: master),
          const VerticalDivider(width: 1),
          Expanded(child: detail),
        ],
      );
    }
  }

  /// Get safe area padding
  static EdgeInsets safeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get responsive list tile height
  static double responsiveListTileHeight(BuildContext context) {
    return responsiveValue(context, mobile: 72, tablet: 80, desktop: 88);
  }

  /// Calculate responsive size based on percentage
  static double percentageWidth(BuildContext context, double percentage) {
    return screenWidth(context) * (percentage / 100);
  }

  /// Calculate responsive size based on percentage
  static double percentageHeight(BuildContext context, double percentage) {
    return screenHeight(context) * (percentage / 100);
  }

  /// Get device info summary
  static Map<String, dynamic> getDeviceInfo(BuildContext context) {
    return {
      'screenWidth': screenWidth(context),
      'screenHeight': screenHeight(context),
      'deviceType': getDeviceType(context).toString(),
      'orientation': screenOrientation(context).toString(),
      'isMobile': isMobile(context),
      'isTablet': isTablet(context),
      'isDesktop': isDesktop(context),
      'devicePixelRatio': MediaQuery.of(context).devicePixelRatio,
      'textScaleFactor': MediaQuery.of(context).textScaler.scale(1.0),
    };
  }
}

/// Device type enum
enum DeviceType { mobile, tablet, desktop, largeDesktop }

/// Extension on BuildContext for easier access
extension ResponsiveExtension on BuildContext {
  bool get isMobile => ResponsiveHelper.isMobile(this);
  bool get isTablet => ResponsiveHelper.isTablet(this);
  bool get isDesktop => ResponsiveHelper.isDesktop(this);
  DeviceType get deviceType => ResponsiveHelper.getDeviceType(this);
  double get screenWidth => ResponsiveHelper.screenWidth(this);
  double get screenHeight => ResponsiveHelper.screenHeight(this);
}
