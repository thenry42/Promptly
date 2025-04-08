// TabView.dart
import 'package:flutter/material.dart';
import 'MainWindow.dart';
import '../services/Singleton.dart';
import 'package:promptly_app/srcs/widgets/SettingsTab.dart';

class PaperTabIndicator extends Decoration {
  final Color color;
  final double borderRadius;
  
  const PaperTabIndicator({
    required this.color,
    this.borderRadius = 8.0,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _PaperTabPainter(
      color: color,
      borderRadius: borderRadius,
    );
  }
}

class _PaperTabPainter extends BoxPainter {
  final Color color;
  final double borderRadius;

  _PaperTabPainter({
    required this.color,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Rect rect = offset & configuration.size!;
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top + borderRadius)
      ..quadraticBezierTo(rect.left, rect.top, rect.left + borderRadius, rect.top)
      ..lineTo(rect.right - borderRadius, rect.top)
      ..quadraticBezierTo(rect.right, rect.top, rect.right, rect.top + borderRadius)
      ..lineTo(rect.right, rect.bottom);

    canvas.drawPath(path, paint);
    
    // Add subtle shadow
    final shadowPath = Path()
      ..addPath(path, Offset.zero);
    canvas.drawShadow(shadowPath, Colors.black26, 4.0, true);
  }
}

class TabView extends StatefulWidget {
  const TabView({super.key});

  @override
  State<TabView> createState() => _TabViewState();
}

class _TabViewState extends State<TabView> with TickerProviderStateMixin {
  late TabController _tabController;
  
  final List<String> _tabTitles = const [
    'Chats',
    'Settings',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabTitles.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildTabContent(int index) {
    switch (index) {
      case 0:
        return const MainWindow();
      case 1:
        return const SettingsTab();
      default:
        return const Center(child: Text('Tab content not found'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final metadata = Singleton();

    return Scaffold(
      body: Column(
        children: [
          Container(
            color: colorScheme.surfaceContainerHigh,
            child: Stack(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: _tabTitles.map((title) => Tab(
                    height: 80,
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: metadata.fontSize,
                        fontWeight: FontWeight.w500,
                        fontFamily: metadata.fontFamily,
                      ),
                    ),
                  )).toList(),
                  isScrollable: false,
                  labelColor: colorScheme.onSurface,
                  unselectedLabelColor: colorScheme.onSurface,
                  indicator: PaperTabIndicator(
                    color: colorScheme.surfaceContainer,
                    borderRadius: 8,
                  ),
                  dividerColor: colorScheme.surfaceContainer.withOpacity(0),
                  labelPadding: EdgeInsets.zero,
                  indicatorSize: TabBarIndicatorSize.tab,
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: colorScheme.surfaceContainer,
              child: TabBarView(
                controller: _tabController,
                children: List.generate(
                  _tabTitles.length,
                  (index) => _buildTabContent(index),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ToolsTab extends StatelessWidget {
  const ToolsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceContainer,
      ),
      child: const Center(
        child: Text('Tools Content'),
      ),
    );
  }
}

class AgentsTab extends StatelessWidget {
  const AgentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceContainer,
      ),
      child: const Center(
        child: Text('Agents Content'),
      ),
    );
  }
}
