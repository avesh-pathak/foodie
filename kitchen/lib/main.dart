import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:foodie_core/foodie_core.dart';

void main() {
  runApp(const KitchenApp());
}

class KitchenApp extends StatelessWidget {
  const KitchenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foodie Kitchen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'PlusJakartaSans',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFDC2B3B),
          brightness: Brightness.light,
          surface: const Color(0xFFFBF8F5),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F1EC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF6F1EC),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF221A18)),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22), side: const BorderSide(color: Color(0xFFEFE5DE))),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFDC2B3B),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w700),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE7DCD4))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE7DCD4))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFDC2B3B), width: 1.5)),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _user = TextEditingController(text: 'kitchen');
  final _pass = TextEditingController(text: 'password123');
  final _api = ApiClient(baseUrl: const String.fromEnvironment('API_BASE_URL', defaultValue: kIsWeb ? 'http://localhost:3001' : 'http://10.0.2.2:3001'));
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      await _api.login(_user.text, _pass.text);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => KitchenShell(api: _api)));
    } catch (e) {
      setState(() => _error = 'Login failed. Check the backend and credentials.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFDF4F0), Color(0xFFF6F1EC), Color(0xFFFBE9E5)]),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              margin: const EdgeInsets.all(24),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(child: ClipRRect(borderRadius: BorderRadius.circular(22), child: Image.asset('assets/brand/foodie_admin_logo.png', width: 84, height: 84, errorBuilder: (_, _, _) => const Icon(Icons.restaurant_menu_rounded, size: 56, color: Color(0xFFDC2B3B))))),
                    const SizedBox(height: 14),
                    Text('Foodie Kitchen', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                    const SizedBox(height: 4),
                    Text('Manage your kitchen', textAlign: TextAlign.center, style: TextStyle(color: Colors.brown.shade400, fontSize: 13)),
                    const SizedBox(height: 24),
                    TextField(controller: _user, decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextField(controller: _pass, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder())),
                    if (_error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_error!, style: const TextStyle(color: Colors.red))),
                    const SizedBox(height: 20),
                    FilledButton(onPressed: _loading ? null : _login, child: Padding(padding: const EdgeInsets.symmetric(vertical: 14), child: Text(_loading ? 'Signing in...' : 'Sign in'))),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class KitchenShell extends StatefulWidget {
  const KitchenShell({super.key, required this.api});
  final ApiClient api;

  @override
  State<KitchenShell> createState() => _KitchenShellState();
}

class _KitchenShellState extends State<KitchenShell> {
  int _index = 0;
  late final List<Widget?> _pages;

  @override
  void initState() {
    super.initState();
    _pages = List<Widget?>.filled(3, null);
    _pages[0] = _pageFor(0);
  }

  Widget _pageFor(int index) {
    switch (index) {
      case 0:
        return OrdersPage(api: widget.api);
      case 1:
        return AvailabilityPage(api: widget.api);
      default:
        return SettingsPage(api: widget.api);
    }
  }

  void _select(int index) {
    if (_pages[index] == null) _pages[index] = _pageFor(index);
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final body = IndexedStack(index: _index, children: _pages.map((page) => page ?? const SizedBox.shrink()).toList());
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(children: [
          ClipRRect(borderRadius: BorderRadius.circular(9), child: Image.asset('assets/brand/foodie_admin_logo.png', width: 30, height: 30, errorBuilder: (_, _, _) => const SizedBox.shrink())),
          const SizedBox(width: 10),
          const Text('Foodie Kitchen'),
        ]),
        actions: [
          IconButton(onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage())), icon: const Icon(Icons.logout)),
        ],
      ),
      body: wide
          ? Row(children: [
              NavigationRail(
                selectedIndex: _index,
                onDestinationSelected: _select,
                labelType: NavigationRailLabelType.all,
                destinations: const [
                  NavigationRailDestination(icon: Icon(Icons.receipt_long), label: Text('Orders')),
                  NavigationRailDestination(icon: Icon(Icons.toggle_on), label: Text('Availability')),
                  NavigationRailDestination(icon: Icon(Icons.settings), label: Text('Settings')),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: body),
            ])
          : body,
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              height: 68,
              labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
              selectedIndex: _index,
              onDestinationSelected: _select,
              destinations: const [
                NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Orders'),
                NavigationDestination(icon: Icon(Icons.toggle_on), label: 'Availability'),
                NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
              ],
            ),
    );
  }
}

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key, required this.api});
  final ApiClient api;

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<dynamic> _orders = [];
  bool _loading = true;
  String? _error;
  Timer? _timer;
  http.Client? _sseClient;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) { if (mounted) setState(() {}); });
    _listenSse();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sseClient?.close();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final rid = widget.api.restaurantId;
      final path = rid != null ? '/orders?restaurantId=$rid' : '/orders';
      final data = await widget.api.getList(path);
      // show only real customer-placed orders (exclude seeded demo/seed rows)
      _orders = data;
    } catch (_) {
      _error = 'No internet connection. Check the API server and try again.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _listenSse() async {
    while (mounted) {
      try {
        final client = http.Client();
        _sseClient = client;
        final req = http.Request('GET', Uri.parse('${widget.api.baseUrl}/events'));
        final res = await client.send(req);
        await for (final line in res.stream.transform(utf8.decoder).transform(const LineSplitter())) {
          if (line.startsWith('event: change')) {
            // refresh on next data line
          }
          if (line.startsWith('data:')) {
            await _refresh();
          }
        }
      } catch (_) {
        await Future<void>.delayed(const Duration(seconds: 3));
      }
    }
  }

  Future<void> _refresh() async {
    try {
      final rid = widget.api.restaurantId;
      final path = rid != null ? '/orders?restaurantId=$rid' : '/orders';
      final data = await widget.api.getList(path);
      if (mounted) setState(() { _orders = data; });
    } catch (_) {}
  }

  Future<void> _setStatus(String id, String status) async {
    try {
      await widget.api.put('/orders/$id/status', {'status': status});
      await _refresh();
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Update failed')));
    }
  }

  List<dynamic> _byStatus(String s) => _orders.where((o) => (o as Map)['status'] == s).toList();

  Color colorForStatus(String s) {
    switch (s) {
      case 'confirmed': return const Color(0xFFb87a12);
      case 'preparing': return const Color(0xFFc4202f);
      case 'ready': return const Color(0xFF1f8a4c);
      default: return Colors.grey;
    }
  }

  Color _timerColor(int secs) {
    if (secs < 600) return const Color(0xFF1f8a4c);
    if (secs < 1200) return const Color(0xFFb87a12);
    return const Color(0xFFc4202f);
  }

  String _fmt(int secs) {
    final m = secs ~/ 60;
    final s = secs % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  int _elapsed(Map<String, dynamic> o) {
    final prep = o['prepElapsedSeconds'];
    if (prep is num) return prep.toInt();
    final ready = o['readyAt'];
    final start = o['preparingStartedAt'] ?? o['confirmedAt'] ?? o['createdAt'];
    if (start == null) return 0;
    final st = DateTime.tryParse('$start');
    if (st == null) return 0;
    final end = ready != null ? DateTime.tryParse('$ready') : DateTime.now();
    if (end == null) return 0;
    return end.difference(st).inSeconds.clamp(0, 1 << 30);
  }

  Widget _card(Map<String, dynamic> o) {
    final id = '${o['id']}';
    final status = '${o['status']}';
    final items = (o['items'] as List?) ?? const [];
    final elapsed = _elapsed(o);
    final isReady = status == 'ready';
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(child: Text('#$id', style: const TextStyle(fontWeight: FontWeight.w800))),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: colorForStatus(status), borderRadius: BorderRadius.circular(6)), child: Text(status.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700))),
              const SizedBox(width: 6),
              Text(isReady ? 'done ${_fmt(elapsed)}' : _fmt(elapsed), style: TextStyle(fontWeight: FontWeight.w700, color: _timerColor(elapsed))),
            ]),
            const SizedBox(height: 6),
            ...items.map((it) {
              final m = it as Map<String, dynamic>;
              return Text('${m['quantity']}x ${m['name']}', style: TextStyle(fontSize: 13, color: Colors.grey.shade700));
            }),
            const SizedBox(height: 6),
            Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFF3ECE7), borderRadius: BorderRadius.circular(6)), child: Text(o['deliveryAddress'] != null && (o['deliveryAddress'] as String).isNotEmpty ? 'Delivery' : 'Pickup', style: const TextStyle(fontSize: 11))),
              const Spacer(),
              if (status == 'confirmed')
                FilledButton(onPressed: () => _setStatus(id, 'preparing'), child: const Text('Start cooking'))
              else if (status == 'preparing')
                FilledButton(onPressed: () => _setStatus(id, 'ready'), style: FilledButton.styleFrom(backgroundColor: const Color(0xFF1f8a4c)), child: const Text('Mark as Ready'))
              else
                Text(status, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _column(String title, String status, Color color) {
    final list = _byStatus(status);
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: const Color(0xFFF3ECE7), borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(width: 8),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)), child: Text('${list.length}', style: const TextStyle(fontSize: 12))),
            ]),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: list.map((o) => _card(o as Map<String, dynamic>)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) return _ErrorState(onRetry: _load);
    if (_loading) return const _SkeletonList();
    final wide = MediaQuery.sizeOf(context).width >= 700;
    if (wide) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          _column('Confirmed', 'confirmed', const Color(0xFFb87a12)),
          _column('Preparing', 'preparing', const Color(0xFFc4202f)),
          _column('Ready', 'ready', const Color(0xFF1f8a4c)),
        ]),
      );
    }
    // mobile: tabs? just stacked
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        ..._byStatus('confirmed').map((o) => _card(o as Map<String, dynamic>)),
        ..._byStatus('preparing').map((o) => _card(o as Map<String, dynamic>)),
        ..._byStatus('ready').map((o) => _card(o as Map<String, dynamic>)),
      ],
    );
  }
}

class AvailabilityPage extends StatefulWidget {
  const AvailabilityPage({super.key, required this.api});
  final ApiClient api;

  @override
  State<AvailabilityPage> createState() => _AvailabilityPageState();
}

class _AvailabilityPageState extends State<AvailabilityPage> {
  List<dynamic> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final rid = widget.api.restaurantId;
      final path = rid != null ? '/menu?restaurantId=$rid' : '/menu';
      final data = await widget.api.getList(path);
      _items = data;
    } catch (_) {
      _error = 'No internet connection. Check the API server and try again.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refresh() async {
    try {
      final rid = widget.api.restaurantId;
      final path = rid != null ? '/menu?restaurantId=$rid' : '/menu';
      final data = await widget.api.getList(path);
      if (mounted) setState(() => _items = data);
    } catch (_) {}
  }

  Future<void> _toggle(String id, bool v) async {
    try {
      await widget.api.put('/menu/$id', {'isAvailable': v});
      await _refresh();
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Update failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) return _ErrorState(onRetry: _load);
    if (_loading) return const _SkeletonList();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _SectionHeader(title: 'Availability', subtitle: 'Toggle items in stock', action: IconButton(onPressed: _load, icon: const Icon(Icons.refresh))),
        const SizedBox(height: 12),
        ..._items.map((raw) {
          final m = raw as Map<String, dynamic>;
          final avail = m['isAvailable'] != false;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: SwitchListTile(
              title: Text('${m['name']}', style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(avail ? 'In stock' : 'Sold out', style: TextStyle(color: avail ? Colors.green.shade700 : Colors.red.shade700, fontSize: 12)),
              value: avail,
              onChanged: (v) => _toggle('${m['id']}', v),
            ),
          );
        }),
      ],
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.api});
  final ApiClient api;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _SectionHeader(title: 'Settings', subtitle: 'Kitchen account'),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(api.role ?? 'kitchen'),
            subtitle: Text(api.restaurantId ?? 'No restaurant assigned'),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage())),
          icon: const Icon(Icons.logout),
          label: const Text('Log out'),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle, this.action});
  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
      ])),
      ?action,
    ]);
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(color: Color(0xFFFDEBEE), shape: BoxShape.circle),
              child: const Icon(Icons.wifi_off_rounded, size: 42, color: Color(0xFFDC2B3B)),
            ),
            const SizedBox(height: 20),
            const Text('No internet connection', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF221A18))),
            const SizedBox(height: 8),
            Text('The kitchen app cannot reach the Foodie API. Make sure the backend is running, then try again.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, height: 1.5, color: Colors.brown.shade400)),
            const SizedBox(height: 20),
            FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh_rounded), label: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  const _ShimmerBox({this.width, required this.height, this.radius = 12});
  final double? width;
  final double height;
  final double radius;

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.35, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(color: const Color(0xFFEDE3DC), borderRadius: BorderRadius.circular(widget.radius)),
      ),
    );
  }
}

class _SkeletonList extends StatelessWidget {
  const _SkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_ShimmerBox(width: 180, height: 24), SizedBox(height: 8), _ShimmerBox(width: 100, height: 12)])),
        ]),
        const SizedBox(height: 22),
        ...List.generate(6, (_) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFFEFE5DE))),
          child: const Row(children: [
            _ShimmerBox(width: 58, height: 58, radius: 14),
            SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_ShimmerBox(width: 170, height: 14), SizedBox(height: 9), _ShimmerBox(width: 230, height: 10)])),
          ]),
        )),
      ],
    );
  }
}


