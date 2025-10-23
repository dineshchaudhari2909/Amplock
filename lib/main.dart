import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Door Lock',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.grey.shade200,
            ),
          ),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.grey.shade800,
            ),
          ),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final bool _isDarkMode = true;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ActivityLogScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Activity',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  bool _isLocked = true;
  late AnimationController _lockController;
  late Animation<double> _lockAnimation;
  bool _isLoading = false;

  final List<NotificationItem> _notifications = [
    NotificationItem(
      type: NotificationType.tamper,
      title: 'Tamper Alert',
      message: 'Unauthorized access attempt detected',
      time: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    NotificationItem(
      type: NotificationType.doorbell,
      title: 'Doorbell Pressed',
      message: 'Someone is at the door',
      time: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _lockController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _lockAnimation = CurvedAnimation(
      parent: _lockController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _lockController.dispose();
    super.dispose();
  }

  Future<void> _toggleLock() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLocked = !_isLocked;
      if (_isLocked) {
        _lockController.reverse();
      } else {
        _lockController.forward();
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Smart Door Lock',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  _showNotifications(context);
                },
              ),
              if (_notifications.isNotEmpty)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    _notifications.length.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Live Feed Section
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Text('Live Camera Feed'),
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: FloatingActionButton.small(
                      onPressed: () {
                        // TODO: Take snapshot
                      },
                      child: const Icon(Icons.camera_alt),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Lock Control Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: FilledButton.icon(
                    onPressed: _isLoading ? null : _toggleLock,
                    icon: AnimatedBuilder(
                      animation: _lockAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _lockAnimation.value * 2 * 3.14159,
                          child: Icon(_isLocked ? Icons.lock_outline : Icons.lock_open),
                        );
                      },
                    ),
                    label: Text(_isLocked ? 'Unlock Door' : 'Lock Door'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      backgroundColor: _isLocked
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Recent Activity Preview
                AnimatedSlide(
                  duration: const Duration(milliseconds: 300),
                  offset: Offset(0, _isLocked ? 0 : 0.1),
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.access_time),
                      title: Text(
                        'Recent Activity',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text('Door unlocked 2 hours ago'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO: Navigate to activity log
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notifications',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Clear all notifications
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return AnimatedSlide(
                    duration: Duration(milliseconds: 300 + (index * 100)),
                    offset: const Offset(0, 0),
                    child: _buildNotificationCard(notification),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    IconData icon;
    Color color;

    switch (notification.type) {
      case NotificationType.tamper:
        icon = Icons.warning_amber_rounded;
        color = Colors.red;
        break;
      case NotificationType.doorbell:
        icon = Icons.doorbell;
        color = Colors.orange;
        break;
      default:
        icon = Icons.notifications;
        color = Colors.blue;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          notification.title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(notification.message),
        trailing: Text(
          _getTimeAgo(notification.time),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        onTap: () {
          // TODO: Handle notification tap
        },
      ),
    );
  }

  String _getTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

enum NotificationType {
  tamper,
  doorbell,
  other,
}

class NotificationItem {
  final NotificationType type;
  final String title;
  final String message;
  final DateTime time;

  NotificationItem({
    required this.type,
    required this.title,
    required this.message,
    required this.time,
  });
}

class ActivityLogScreen extends StatelessWidget {
  const ActivityLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Activity Log',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.lock_outline),
              title: Text(
                'Door Unlocked',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text('2 hours ago'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Show activity details
              },
            ),
          );
        },
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        children: [
          _buildSettingsSection(
            context,
            'Notifications',
            [
              _buildSettingsTile(
                context,
                icon: Icons.notifications_outlined,
                title: 'Push Notifications',
                subtitle: 'Configure alert settings',
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // TODO: Implement notification toggle
                  },
                ),
              ),
              _buildSettingsTile(
                context,
                icon: Icons.warning_amber_rounded,
                title: 'Tamper Alerts',
                subtitle: 'Get notified of security breaches',
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // TODO: Implement tamper alerts toggle
                  },
                ),
              ),
              _buildSettingsTile(
                context,
                icon: Icons.doorbell,
                title: 'Doorbell Notifications',
                subtitle: 'Get notified when someone rings',
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // TODO: Implement doorbell notifications toggle
                  },
                ),
              ),
            ],
          ),
          _buildSettingsSection(
            context,
            'Security',
            [
              _buildSettingsTile(
                context,
                icon: Icons.security_outlined,
                title: 'Biometric Login',
                subtitle: 'Use fingerprint or face ID',
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // TODO: Implement biometric login toggle
                  },
                ),
              ),
              _buildSettingsTile(
                context,
                icon: Icons.password_outlined,
                title: 'Change PIN',
                subtitle: 'Update your security PIN',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Navigate to PIN change screen
                },
              ),
            ],
          ),
          _buildSettingsSection(
            context,
            'Appearance',
            [
              _buildSettingsTile(
                context,
                icon: Icons.palette_outlined,
                title: 'Theme',
                subtitle: 'Choose light or dark mode',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Navigate to theme settings
                },
              ),
              _buildSettingsTile(
                context,
                icon: Icons.wallpaper_outlined,
                title: 'Background',
                subtitle: 'Customize app background',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Navigate to background settings
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildSettingsTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        Widget? trailing,
        VoidCallback? onTap,
      }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: onTap,
    );
  }
}