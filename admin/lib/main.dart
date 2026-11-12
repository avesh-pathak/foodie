import 'dart:async';
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:foodie_core/foodie_core.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foodie Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'PlusJakartaSans',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC4202F),
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
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22), side: const BorderSide(color: Color(0xFFEFE5DE))),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFC4202F),
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
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFC4202F), width: 1.5)),
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
  final _user = TextEditingController(text: 'admin');
  final _pass = TextEditingController(text: 'password123');
  final _api = ApiClient(baseUrl: const String.fromEnvironment('API_BASE_URL', defaultValue: kIsWeb ? 'http://localhost:3001' : 'http://10.0.2.2:3001'));
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      await _api.login(_user.text, _pass.text);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => AdminShell(api: _api)));
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
                  Center(child: ClipRRect(borderRadius: BorderRadius.circular(22), child: Image.asset('assets/brand/foodie_admin_logo.png', width: 84, height: 84, errorBuilder: (_, __, ___) => const Icon(Icons.restaurant_menu_rounded, size: 56, color: Color(0xFFC4202F))))),
                  const SizedBox(height: 14),
                  Text('Foodie Admin', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  Text('Run your restaurants from one place', textAlign: TextAlign.center, style: TextStyle(color: Colors.brown.shade400, fontSize: 13)),
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

class AdminShell extends StatefulWidget {
  const AdminShell({super.key, required this.api});
  final ApiClient api;

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;
  late final List<Widget?> _pages;

  @override
  void initState() {
    super.initState();
    _pages = List<Widget?>.filled(5, null);
    _pages[0] = _pageFor(0);
  }

  Widget _pageFor(int index) {
    switch (index) {
      case 0:
        return RestaurantsPage(api: widget.api);
      case 1:
        return MenuPage(api: widget.api);
      case 2:
        return OrdersPage(api: widget.api);
      case 3:
        return KitchenTab(api: widget.api);
      default:
        return AnalyticsPage(api: widget.api);
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
          ClipRRect(borderRadius: BorderRadius.circular(9), child: Image.asset('assets/brand/foodie_admin_logo.png', width: 30, height: 30, errorBuilder: (_, __, ___) => const SizedBox.shrink())),
          const SizedBox(width: 10),
          const Text('Foodie Admin'),
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
                  NavigationRailDestination(icon: Icon(Icons.storefront), label: Text('Restaurants')),
                  NavigationRailDestination(icon: Icon(Icons.menu_book), label: Text('Menu')),
                  NavigationRailDestination(icon: Icon(Icons.receipt_long), label: Text('Orders')),
                  NavigationRailDestination(icon: Icon(Icons.soup_kitchen), label: Text('Kitchen')),
                  NavigationRailDestination(icon: Icon(Icons.insights), label: Text('Analytics')),
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
                NavigationDestination(icon: Icon(Icons.storefront), label: 'Restaurants'),
                NavigationDestination(icon: Icon(Icons.menu_book), label: 'Menu'),
                NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Orders'),
                NavigationDestination(icon: Icon(Icons.soup_kitchen), label: 'Kitchen'),
                NavigationDestination(icon: Icon(Icons.insights), label: 'Analytics'),
              ],
            ),
    );
  }
}

class RestaurantsPage extends StatefulWidget {
  const RestaurantsPage({super.key, required this.api});
  final ApiClient api;

  @override
  State<RestaurantsPage> createState() => _RestaurantsPageState();
}

class _RestaurantsPageState extends State<RestaurantsPage> {
  List<Restaurant> _items = [];
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
      final data = await widget.api.getList('/restaurants');
      _items = data.map((e) => Restaurant.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      _error = 'No internet connection. Check the API server and try again.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _edit([Restaurant? existing]) async {
    final name = TextEditingController(text: existing?.name ?? '');
    final tagline = TextEditingController(text: existing?.tagline ?? '');
    final image = TextEditingController(text: existing?.coverImage ?? '');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => _FormDialog(
        title: existing == null ? 'New restaurant' : 'Edit restaurant',
        subtitle: 'This updates the storefront the customer app sees.',
        saveLabel: existing == null ? 'Create restaurant' : 'Save changes',
        onCancel: () => Navigator.pop(ctx, false),
        onSave: () => Navigator.pop(ctx, true),
        children: [
          _Field(label: 'Restaurant name', controller: name, hint: 'e.g. Hyderabadi House'),
          _Field(label: 'Tagline', controller: tagline, hint: 'One short line about the food'),
          _Field(label: 'Cover image URL or asset path', controller: image, hint: 'assets/images/cover_hyderabadi.jpg'),
        ],
      ),
    );
    if (ok != true) return;
    final body = {
      if (existing != null) 'id': existing.id,
      'name': name.text,
      'tagline': tagline.text,
      'coverImage': image.text,
      'cuisines': existing?.cuisines ?? [],
      'categories': existing?.categories ?? [],
      'menuCategories': existing?.menuCategories ?? [],
      'deliveryMinutes': existing?.deliveryMinutes ?? 30,
      'deliveryFee': existing?.deliveryFee ?? 0,
      'priceForTwo': existing?.priceForTwo ?? 0,
      'distanceKm': existing?.distanceKm ?? 0,
      'rating': existing?.rating ?? 0,
      'ratingCount': existing?.ratingCount ?? 0,
      'offer': existing?.offer ?? '',
    };
    if (existing == null) {
      await widget.api.post('/restaurants', body);
    } else {
      await widget.api.put('/restaurants/${existing.id}', body);
    }
    await _load();
  }

  Future<void> _delete(Restaurant r) async {
    await widget.api.delete('/restaurants/${r.id}');
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) return _ErrorState(onRetry: _load);
    return _loading
        ? const _SkeletonList()
        : ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _SectionHeader(title: 'Restaurants', subtitle: '${_items.length} stores', action: FilledButton.icon(onPressed: () => _edit(), icon: const Icon(Icons.add), label: const Text('Add'))),
              const SizedBox(height: 12),
              ..._items.map((r) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(r.coverImage, width: 58, height: 58, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(width: 58, height: 58, color: const Color(0xFFFDEBEE), child: const Icon(Icons.restaurant, color: Color(0xFFC4202F)))),
                      ),
                      title: Text(r.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('${r.tagline}\n${r.cuisines.join(' · ')}'),
                      isThreeLine: true,
                      trailing: PopupMenuButton<String>(
                        onSelected: (v) => v == 'edit' ? _edit(r) : _delete(r),
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                    ),
                  )),
            ],
          );
  }
}

class MenuPage extends StatefulWidget {
  const MenuPage({super.key, required this.api});
  final ApiClient api;

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<Restaurant> _restaurants = [];
  List<MenuItem> _menu = [];
  String? _selected;
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
      final data = await widget.api.getList('/restaurants');
      _restaurants = data.map((e) => Restaurant.fromJson(e as Map<String, dynamic>)).toList();
      _selected ??= _restaurants.isEmpty ? null : _restaurants.first.id;
      await _loadMenu();
    } catch (_) {
      _error = 'No internet connection. Check the API server and try again.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadMenu() async {
    if (_selected == null) return;
    final data = await widget.api.getList('/menu?restaurantId=$_selected');
    _menu = data.map((e) => MenuItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  String _money(double value) => value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);

  Widget _photo(String path, BoxFit fit) {
    final Widget fallback = Container(
      color: const Color(0xFFF7EFEA),
      child: const Center(child: Icon(Icons.restaurant_menu, color: Color(0xFFC4202F))),
    );
    if (path.startsWith('http')) return Image.network(path, fit: fit, errorBuilder: (_, __, ___) => fallback);
    return Image.asset(path, fit: fit, errorBuilder: (_, __, ___) => fallback);
  }

  Future<void> _editItem([MenuItem? item]) async {
    final name = TextEditingController(text: item?.name ?? '');
    final price = TextEditingController(text: item == null ? '' : _money(item.price));
    final category = TextEditingController(text: item?.category ?? '');
    final description = TextEditingController(text: item?.description ?? '');
    final image = TextEditingController(text: item?.image ?? '');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => _FormDialog(
          title: item == null ? 'New menu item' : 'Edit menu item',
          subtitle: 'Changes publish to the customer app in real time.',
          saveLabel: item == null ? 'Create item' : 'Save changes',
          onCancel: () => Navigator.pop(ctx, false),
          onSave: () => Navigator.pop(ctx, true),
          children: [
            _Field(label: 'Item name', controller: name, hint: 'e.g. Hyderabadi Chicken Dum Biryani'),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _Field(label: 'Price (₹)', controller: price, hint: '329', keyboardType: const TextInputType.numberWithOptions(decimal: true))),
              const SizedBox(width: 12),
              Expanded(child: _Field(label: 'Menu category', controller: category, hint: 'Biryani')),
            ]),
            _Field(label: 'Description', controller: description, hint: 'What makes this dish special?', maxLines: 3),
            _Field(label: 'Photo URL or asset path', controller: image, hint: 'assets/images/dish_biryani.jpg', onChanged: (_) => setDialogState(() {})),
            const SizedBox(height: 2),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 148,
                width: double.infinity,
                color: const Color(0xFFF7EFEA),
                child: image.text.isEmpty
                    ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.image_outlined, color: Colors.brown.shade300, size: 30), const SizedBox(height: 6), Text('Photo preview', style: TextStyle(fontSize: 11, color: Colors.brown.shade300))]))
                    : _photo(image.text, BoxFit.cover),
              ),
            ),
          ],
        ),
      ),
    );
    if (ok != true || _selected == null) return;
    final body = {
      if (item != null) 'id': item.id,
      'restaurantId': _selected,
      'name': name.text,
      'price': double.tryParse(price.text) ?? 0,
      'category': category.text,
      'description': description.text,
      'image': image.text,
      'isVeg': item?.isVeg ?? true,
      'rating': item?.rating ?? 0,
      'ratingCount': item?.ratingCount ?? 0,
      'isBestseller': item?.isBestseller ?? false,
      'isRecommended': item?.isRecommended ?? false,
    };
    if (item == null) {
      await widget.api.post('/menu', body);
    } else {
      await widget.api.put('/menu/${item.id}', body);
    }
    await _loadMenu();
    if (mounted) setState(() {});
  }

  Future<void> _deleteItem(MenuItem item) async {
    await widget.api.delete('/menu/${item.id}');
    await _loadMenu();
    if (mounted) setState(() {});
  }

  Future<void> _uploadImage(MenuItem item) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 82);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    final key = 'menu/${DateTime.now().millisecondsSinceEpoch}-${picked.name}';
    final res = await http.post(
      Uri.parse('${widget.api.baseUrl}/images/presign'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${widget.api.token}'},
      body: jsonEncode({'key': key, 'contentType': picked.mimeType ?? 'image/jpeg'}),
    );
    if (res.statusCode >= 400) return;
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    String? publicUrl = data['publicUrl'] as String?;
    try {
      final upload = await http.put(Uri.parse(data['uploadUrl']), headers: {'Content-Type': picked.mimeType ?? 'image/jpeg'}, body: bytes);
      if (upload.statusCode >= 400) throw Exception('direct upload failed');
    } catch (_) {
      // Some mobile networks cannot resolve the storage host. Relay through
      // the API so the admin upload still succeeds.
      final relay = await http.post(
        Uri.parse('${widget.api.baseUrl}/images/upload'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${widget.api.token}'},
        body: jsonEncode({'key': key, 'contentType': picked.mimeType ?? 'image/jpeg', 'data': base64Encode(bytes)}),
      );
      if (relay.statusCode < 400) {
        publicUrl = (jsonDecode(relay.body) as Map<String, dynamic>)['publicUrl'] as String?;
      }
    }
    if (publicUrl == null) return;
    await widget.api.put('/menu/${item.id}', {'image': publicUrl});
    await _loadMenu();
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Photo updated')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) return _ErrorState(onRetry: _load);
    return _loading
        ? const _SkeletonList()
        : ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _SectionHeader(title: 'Menu & prices', subtitle: 'Select a restaurant, then edit items', action: FilledButton.icon(onPressed: () => _editItem(), icon: const Icon(Icons.add), label: const Text('Add item'))),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selected,
                decoration: const InputDecoration(labelText: 'Restaurant', border: OutlineInputBorder()),
                items: _restaurants.map((r) => DropdownMenuItem(value: r.id, child: Text(r.name))).toList(),
                onChanged: (v) async {
                  setState(() => _selected = v);
                  await _loadMenu();
                  if (mounted) setState(() {});
                },
              ),
              const SizedBox(height: 12),
              ..._menu.map((m) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(m.image, width: 58, height: 58, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(width: 58, height: 58, color: m.isVeg ? const Color(0xFFE7F3E5) : const Color(0xFFFDE8E5), child: Icon(m.isVeg ? Icons.eco : Icons.local_fire_department, color: m.isVeg ? Colors.green : Colors.deepOrange))),
                      ),
                      title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${m.category} · ₹${m.price.toStringAsFixed(0)}'),
                      trailing: Wrap(spacing: 4, children: [
                        IconButton(tooltip: 'Upload photo', onPressed: () => _uploadImage(m), icon: const Icon(Icons.photo_camera_outlined)),
                        IconButton(tooltip: 'Edit', onPressed: () => _editItem(m), icon: const Icon(Icons.edit_outlined)),
                        IconButton(tooltip: 'Delete', onPressed: () => _deleteItem(m), icon: const Icon(Icons.delete_outline)),
                      ]),
                    ),
                  )),
            ],
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
  List<Order> _orders = [];
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
      final data = await widget.api.getList('/orders');
      _orders = data.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      _error = 'No internet connection. Check the API server and try again.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _setStatus(Order o, String status) async {
    await widget.api.put('/orders/${o.id}/status', {'status': status});
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    const statuses = ['pending', 'confirmed', 'preparing', 'out_for_delivery', 'delivered', 'cancelled', 'returned'];
    if (_error != null) return _ErrorState(onRetry: _load);
    return _loading
        ? const _SkeletonList()
        : ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _SectionHeader(title: 'Orders', subtitle: '${_orders.length} orders', action: IconButton(onPressed: _load, icon: const Icon(Icons.refresh))),
              const SizedBox(height: 12),
              ..._orders.map((o) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text('${o.customerName} · ₹${o.total.toStringAsFixed(0)}'),
                      subtitle: Text('${o.locality} · ${o.paymentMethod}'),
                      trailing: DropdownButton<String>(
                        value: o.status,
                        items: statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (v) { if (v != null) _setStatus(o, v); },
                      ),
                    ),
                  )),
            ],
          );
  }
}

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key, required this.api});
  final ApiClient api;

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  AnalyticsOverview? _overview;
  List<dynamic> _areas = [];
  List<dynamic> _restaurants = [];
  List<dynamic> _dishes = [];
  List<dynamic> _hours = [];
  List<dynamic> _weekdays = [];
  List<dynamic> _months = [];
  double _avgPrep = 0;
  List<dynamic> _prepByRestaurant = [];
  List<dynamic> _prepByDish = [];
  List<dynamic> _prepByHour = [];
  List<dynamic> _prepTrend = [];
  List<dynamic> _prepSlowest = [];
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
      final results = await Future.wait([
        widget.api.getMap('/analytics/overview'),
        widget.api.getList('/analytics/by-area'),
        widget.api.getList('/analytics/by-restaurant'),
        widget.api.getList('/analytics/top-dishes'),
        widget.api.getList('/analytics/peak-hours'),
        widget.api.getList('/analytics/by-weekday'),
        widget.api.getList('/analytics/by-month'),
        widget.api.getMap('/analytics/prep-time'),
      ]);
      _overview = AnalyticsOverview.fromJson(results[0] as Map<String, dynamic>);
      _areas = results[1] as List<dynamic>;
      _restaurants = results[2] as List<dynamic>;
      _dishes = results[3] as List<dynamic>;
      _hours = results[4] as List<dynamic>;
      _weekdays = results[5] as List<dynamic>;
      _months = results[6] as List<dynamic>;
      final prep = results[7] as Map<String, dynamic>;
      _avgPrep = double.tryParse('${prep['avgPrepSeconds']}') ?? 0;
      _prepByRestaurant = (prep['byRestaurant'] as List?) ?? [];
      _prepByDish = (prep['byDish'] as List?) ?? [];
      _prepByHour = (prep['byHour'] as List?) ?? [];
      _prepTrend = (prep['trend'] as List?) ?? [];
      _prepSlowest = (prep['slowest'] as List?) ?? [];
    } catch (_) {
      _error = 'No internet connection. Check the API server and try again.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) return _ErrorState(onRetry: _load);
    if (_loading) return const _SkeletonAnalytics();
    final o = _overview!;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _SectionHeader(title: 'Analytics', subtitle: 'Live from Neon Postgres summary tables', action: IconButton(onPressed: _load, icon: const Icon(Icons.refresh))),
        const SizedBox(height: 14),
        _AnalyticsHero(overview: o),
        const SizedBox(height: 12),
        Wrap(spacing: 10, runSpacing: 10, children: [
          _PillMetric(label: 'Returned', value: '${o.returned}', icon: Icons.undo_rounded, tint: const Color(0xFF8E4160), soft: const Color(0xFFFBE8EF)),
          _PillMetric(label: 'Cancelled', value: '${o.cancelled}', icon: Icons.cancel_outlined, tint: const Color(0xFF5F5A57), soft: const Color(0xFFF0ECE9)),
          _PillMetric(label: 'Avg / order', value: _inr(o.aov), icon: Icons.trending_up_rounded, tint: const Color(0xFF9A6206), soft: const Color(0xFFFFF0CF)),
        ]),
        const SizedBox(height: 20),
        LayoutBuilder(builder: (context, constraints) {
          final wide = constraints.maxWidth > 760;
          final charts = <Widget>[
            _ChartCard(title: 'Peak order hours', subtitle: 'Orders grouped by hour of day', child: SizedBox(height: 220, child: _hoursBar())),
            _ChartCard(title: 'Best days of the week', subtitle: 'Orders by weekday', child: SizedBox(height: 220, child: _weekdayBar())),
            _ChartCard(title: 'Monthly revenue', subtitle: 'Earned per month', child: SizedBox(height: 220, child: _monthLine())),
            _ChartCard(title: 'Restaurant revenue', subtitle: 'Top performing restaurants', child: SizedBox(height: 220, child: _restaurantBar())),
            _ChartCard(title: 'Orders by area', subtitle: 'Share of orders per locality', child: SizedBox(height: 240, child: _areaPie())),
          ];
          if (!wide) return Column(children: charts.map((c) => Padding(padding: const EdgeInsets.only(bottom: 12), child: c)).toList());
          return Wrap(spacing: 12, runSpacing: 12, children: charts.map((c) => SizedBox(width: (constraints.maxWidth - 12) / 2, child: c)).toList());
        }),
        const SizedBox(height: 12),
        _RankBars(
          title: 'Top dishes',
          subtitle: 'Most ordered items',
          items: _dishes.take(7).map((e) => _RankItem(
                label: '${e['name']}',
                meta: '${e['qty']} sold · ${_inr(num.tryParse('${e['revenue']}') ?? 0)}',
                value: (e['qty'] as num).toDouble(),
                color: const Color(0xFFC4202F),
              )).toList(),
        ),
        _RankBars(
          title: 'Top areas',
          subtitle: 'Orders by locality',
          items: _areas.take(7).map((e) => _RankItem(
                label: '${e['locality']}',
                meta: '${e['orders']} orders · ${_inr(num.tryParse('${e['revenue']}') ?? 0)}',
                value: (e['orders'] as num).toDouble(),
                color: const Color(0xFF2E7D5B),
              )).toList(),
        ),
        const SizedBox(height: 20),
        _SectionHeader(title: 'Prep time', subtitle: 'Kitchen performance from ready orders'),
        const SizedBox(height: 12),
        Wrap(spacing: 10, runSpacing: 10, children: [
          _PillMetric(label: 'Avg prep', value: _fmtPrep(_avgPrep), icon: Icons.timer_outlined, tint: const Color(0xFF3F5C93), soft: const Color(0xFFE8EDF7)),
        ]),
        const SizedBox(height: 12),
        LayoutBuilder(builder: (context, constraints) {
          final wide = constraints.maxWidth > 760;
          final charts = <Widget>[
            _ChartCard(title: 'Prep time by restaurant', subtitle: 'Average seconds to ready', child: SizedBox(height: 220, child: _prepRestaurantBar())),
            _ChartCard(title: 'Prep time by hour', subtitle: 'Average seconds by hour of day', child: SizedBox(height: 220, child: _prepHourBar())),
            _ChartCard(title: 'Prep time trend', subtitle: 'Average seconds over time', child: SizedBox(height: 220, child: _prepTrendLine())),
          ];
          if (!wide) return Column(children: charts.map((c) => Padding(padding: const EdgeInsets.only(bottom: 12), child: c)).toList());
          return Wrap(spacing: 12, runSpacing: 12, children: charts.map((c) => SizedBox(width: (constraints.maxWidth - 12) / 2, child: c)).toList());
        }),
        const SizedBox(height: 12),
        _RankBars(
          title: 'Prep time by dish',
          subtitle: 'Average seconds per dish',
          items: _prepByDish.take(7).map((e) => _RankItem(
                label: '${e['name']}',
                meta: _fmtPrep(double.tryParse('${e['avg']}') ?? 0),
                value: double.tryParse('${e['avg']}') ?? 0,
                color: const Color(0xFF9A6206),
              )).toList(),
        ),
        const SizedBox(height: 12),
        _SlowestOrdersCard(items: _prepSlowest),
      ],
    );
  }

  Widget _hoursBar() {
    const palette = [Color(0xFFE8A3AA), Color(0xFFDE7B85), Color(0xFFD05461), Color(0xFFC4202F), Color(0xFFA8182A), Color(0xFF8E1020)];
    return BarChart(BarChartData(
      borderData: FlBorderData(show: false),
      gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => const FlLine(color: Color(0xFFF1E7E1), strokeWidth: 1)),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
          final i = v.toInt();
          if (i < 0 || i >= _hours.length) return const SizedBox();
          return Text('${_hours[i]['hour']}h', style: const TextStyle(fontSize: 9, color: Color(0xFF7A6F69)));
        })),
      ),
      barGroups: List.generate(_hours.length, (i) => BarChartGroupData(x: i, barRods: [BarChartRodData(toY: (_hours[i]['orders'] as num).toDouble(), color: palette[i % palette.length], width: 12, borderRadius: BorderRadius.circular(5))])),
    ));
  }

  Widget _weekdayBar() {
    const names = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return BarChart(BarChartData(
      borderData: FlBorderData(show: false),
      gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) => Text(names[v.toInt() % 7], style: const TextStyle(fontSize: 10, color: Color(0xFF7A6F69))))),
      ),
      barGroups: _weekdays.map((e) => BarChartGroupData(x: (e['dow'] as num).toInt(), barRods: [BarChartRodData(toY: (e['orders'] as num).toDouble(), color: const Color(0xFF2E7D5B), width: 18, borderRadius: BorderRadius.circular(6))])).toList(),
    ));
  }

  Widget _monthLine() {
    final spots = <FlSpot>[];
    for (var i = 0; i < _months.length; i++) {
      spots.add(FlSpot(i.toDouble(), double.tryParse('${_months[i]['revenue']}') ?? 0));
    }
    if (spots.isEmpty) spots.add(const FlSpot(0, 0));
    return LineChart(LineChartData(
      borderData: FlBorderData(show: false),
      gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => const FlLine(color: Color(0xFFF1E7E1), strokeWidth: 1)),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
          final i = v.toInt();
          if (i < 0 || i >= _months.length) return const SizedBox();
          return Text('${_months[i]['month']}'.substring(5), style: const TextStyle(fontSize: 10, color: Color(0xFF7A6F69)));
        })),
      ),
      lineBarsData: [LineChartBarData(spots: spots, isCurved: true, color: const Color(0xFF9A6206), barWidth: 3, dotData: const FlDotData(show: true), belowBarData: BarAreaData(show: true, color: const Color(0x229A6206)))],
    ));
  }

  Widget _restaurantBar() {
    final top = _restaurants.take(5).toList();
    return BarChart(BarChartData(
      borderData: FlBorderData(show: false),
      gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
          final i = v.toInt();
          if (i < 0 || i >= top.length) return const SizedBox();
          return Text('${top[i]['name'] ?? ''}'.split(' ').first, style: const TextStyle(fontSize: 9, color: Color(0xFF7A6F69)));
        })),
      ),
      barGroups: List.generate(top.length, (i) {
        final value = double.tryParse('${top[i]['revenue']}') ?? 0;
        return BarChartGroupData(x: i, barRods: [BarChartRodData(toY: value, color: const Color(0xFF8E4160), width: 22, borderRadius: BorderRadius.circular(6))]);
      }),
    ));
  }

  Widget _areaPie() {
    const palette = [Color(0xFFC4202F), Color(0xFF2E7D5B), Color(0xFF9A6206), Color(0xFF8E4160), Color(0xFF3F5C93), Color(0xFF56721F)];
    final total = _areas.fold<double>(0, (sum, e) => sum + ((e['orders'] as num?)?.toDouble() ?? 0));
    if (total == 0) return const Center(child: Text('No orders yet'));
    return Row(children: [
      Expanded(child: PieChart(PieChartData(sections: List.generate(_areas.length, (i) {
        final e = _areas[i];
        return PieChartSectionData(value: (e['orders'] as num).toDouble(), color: palette[i % palette.length], radius: 64, showTitle: false);
      })))),
      const SizedBox(width: 8),
      Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: List.generate(_areas.length, (i) {
        return Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(children: [
          Container(width: 9, height: 9, decoration: BoxDecoration(color: palette[i % palette.length], borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 6),
          Expanded(child: Text('${_areas[i]['locality']}', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))),
        ]));
      }))),
    ]);
  }

  String _fmtPrep(double seconds) {
    if (seconds <= 0) return '—';
    final m = (seconds / 60).floor();
    final s = (seconds % 60).round();
    if (m == 0) return '${s}s';
    return '${m}m ${s}s';
  }

  Widget _prepRestaurantBar() {
    final top = _prepByRestaurant.take(6).toList();
    if (top.isEmpty) return const Center(child: Text('No prep data yet'));
    return BarChart(BarChartData(
      borderData: FlBorderData(show: false),
      gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
          final i = v.toInt();
          if (i < 0 || i >= top.length) return const SizedBox();
          return Text('${top[i]['name'] ?? ''}'.split(' ').first, style: const TextStyle(fontSize: 9, color: Color(0xFF7A6F69)));
        })),
      ),
      barGroups: List.generate(top.length, (i) {
        final value = double.tryParse('${top[i]['avg']}') ?? 0;
        return BarChartGroupData(x: i, barRods: [BarChartRodData(toY: value, color: const Color(0xFF3F5C93), width: 20, borderRadius: BorderRadius.circular(6))]);
      }),
    ));
  }

  Widget _prepHourBar() {
    if (_prepByHour.isEmpty) return const Center(child: Text('No prep data yet'));
    const palette = [Color(0xFFB7C6E6), Color(0xFF9FB1DD), Color(0xFF7E96D1), Color(0xFF5E7BC5), Color(0xFF3F5C93), Color(0xFF2E4570)];
    return BarChart(BarChartData(
      borderData: FlBorderData(show: false),
      gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => const FlLine(color: Color(0xFFF1E7E1), strokeWidth: 1)),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
          final i = v.toInt();
          if (i < 0 || i >= _prepByHour.length) return const SizedBox();
          return Text('${_prepByHour[i]['hour']}h', style: const TextStyle(fontSize: 9, color: Color(0xFF7A6F69)));
        })),
      ),
      barGroups: List.generate(_prepByHour.length, (i) => BarChartGroupData(x: i, barRods: [BarChartRodData(toY: (double.tryParse('${_prepByHour[i]['avg']}') ?? 0), color: palette[i % palette.length], width: 12, borderRadius: BorderRadius.circular(5))])),
    ));
  }

  Widget _prepTrendLine() {
    final spots = <FlSpot>[];
    for (var i = 0; i < _prepTrend.length; i++) {
      spots.add(FlSpot(i.toDouble(), double.tryParse('${_prepTrend[i]['avg']}') ?? 0));
    }
    if (spots.isEmpty) spots.add(const FlSpot(0, 0));
    return LineChart(LineChartData(
      borderData: FlBorderData(show: false),
      gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => const FlLine(color: Color(0xFFF1E7E1), strokeWidth: 1)),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
          final i = v.toInt();
          if (i < 0 || i >= _prepTrend.length) return const SizedBox();
          return Text('${_prepTrend[i]['date']}'.substring(5), style: const TextStyle(fontSize: 10, color: Color(0xFF7A6F69)));
        })),
      ),
      lineBarsData: [LineChartBarData(spots: spots, isCurved: true, color: const Color(0xFF3F5C93), barWidth: 3, dotData: const FlDotData(show: true), belowBarData: BarAreaData(show: true, color: const Color(0x223F5C93)))],
    ));
  }

}

class _SlowestOrdersCard extends StatelessWidget {
  const _SlowestOrdersCard({required this.items});
  final List<dynamic> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Card(
        child: Padding(padding: const EdgeInsets.all(18), child: Text('No slow orders yet', style: TextStyle(color: Colors.brown.shade400))),
      );
    }
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Slowest orders', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 12),
          ...items.map((e) {
            final elapsed = double.tryParse('${e['elapsed']}') ?? 0;
            final m = (elapsed / 60).floor();
            final s = (elapsed % 60).round();
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Expanded(child: Text('${e['orderId']}', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                const SizedBox(width: 8),
                Text('${e['restaurant'] ?? ''}', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: Colors.brown.shade400)),
                const SizedBox(width: 8),
                Text(m > 0 ? '${m}m ${s}s' : '${s}s', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFC4202F))),
              ]),
            );
          }),
        ]),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
    this.maxLines = 1,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: TextStyle(fontSize: 10, letterSpacing: 1.1, fontWeight: FontWeight.w800, color: Colors.brown.shade400)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            minLines: 1,
            maxLines: maxLines,
            onChanged: onChanged,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF221A18)),
            decoration: InputDecoration(
              hintText: hint,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormDialog extends StatelessWidget {
  const _FormDialog({
    required this.title,
    required this.subtitle,
    required this.saveLabel,
    required this.onCancel,
    required this.onSave,
    required this.children,
  });

  final String title;
  final String subtitle;
  final String saveLabel;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      backgroundColor: const Color(0xFFFDF8F5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(child: Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.4, color: Color(0xFF221A18)))),
                IconButton(onPressed: onCancel, icon: const Icon(Icons.close, color: Color(0xFF7A6F69))),
              ]),
              Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.brown.shade400)),
              const SizedBox(height: 18),
              ...children,
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(onPressed: onCancel, child: const Text('Cancel')),
                const SizedBox(width: 8),
                FilledButton.icon(onPressed: onSave, icon: const Icon(Icons.check, size: 18), label: Text(saveLabel)),
              ]),
            ],
          ),
        ),
      ),
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
      if (action != null) action!,
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
              child: const Icon(Icons.wifi_off_rounded, size: 42, color: Color(0xFFC4202F)),
            ),
            const SizedBox(height: 20),
            const Text('No internet connection', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF221A18))),
            const SizedBox(height: 8),
            Text('The admin app cannot reach the Foodie API. Make sure the backend is running, then try again.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, height: 1.5, color: Colors.brown.shade400)),
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
          _ShimmerBox(width: 82, height: 40, radius: 14),
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

class _SkeletonAnalytics extends StatelessWidget {
  const _SkeletonAnalytics();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _ShimmerBox(width: 150, height: 28),
        const SizedBox(height: 8),
        const _ShimmerBox(width: 250, height: 12),
        const SizedBox(height: 18),
        const _ShimmerBox(height: 190, radius: 26),
        const SizedBox(height: 12),
        const Row(children: [
          Expanded(child: _ShimmerBox(height: 64, radius: 18)),
          SizedBox(width: 10),
          Expanded(child: _ShimmerBox(height: 64, radius: 18)),
          SizedBox(width: 10),
          Expanded(child: _ShimmerBox(height: 64, radius: 18)),
        ]),
        const SizedBox(height: 18),
        const _ShimmerBox(height: 250, radius: 22),
        const SizedBox(height: 12),
        const _ShimmerBox(height: 250, radius: 22),
      ],
    );
  }
}

class _AnalyticsHero extends StatelessWidget {
  const _AnalyticsHero({required this.overview});
  final AnalyticsOverview overview;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF241D1A), Color(0xFF3B2421)]),
        boxShadow: const [BoxShadow(color: Color(0x1F241D1A), blurRadius: 24, offset: Offset(0, 10))],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: const Color(0x33FFFFFF), borderRadius: BorderRadius.circular(20)), child: const Text('LIVE PULSE', style: TextStyle(color: Color(0xFFF7D8D2), fontSize: 9, letterSpacing: 1.2, fontWeight: FontWeight.w800))),
          const Spacer(),
          const Icon(Icons.auto_graph_rounded, color: Color(0xFFE8A3AA), size: 20),
        ]),
        const SizedBox(height: 18),
        Text('Revenue', style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(_inr(overview.totalRevenue), style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w800, letterSpacing: -1.5, height: 1.05)),
        const SizedBox(height: 18),
        Row(children: [
          _HeroStat(label: 'Orders', value: '${overview.totalOrders}'),
          Container(width: 1, height: 34, color: const Color(0x33FFFFFF)),
          _HeroStat(label: 'Avg order', value: _inr(overview.aov)),
          Container(width: 1, height: 34, color: const Color(0x33FFFFFF)),
          _HeroStat(label: 'Returns', value: '${overview.returned}'),
        ]),
      ]),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.w600)),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
      ]),
    );
  }
}

class _PillMetric extends StatelessWidget {
  const _PillMetric({required this.label, required this.value, required this.icon, required this.tint, required this.soft});
  final String label;
  final String value;
  final IconData icon;
  final Color tint;
  final Color soft;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: soft, borderRadius: BorderRadius.circular(18), border: Border.all(color: tint.withValues(alpha: 0.12))),
      child: Row(children: [
        Icon(icon, size: 18, color: tint),
        const SizedBox(width: 9),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: tint.withValues(alpha: 0.7))),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: tint, letterSpacing: -0.3)),
        ]),
      ]),
    );
  }
}
class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.child, this.subtitle});
  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!, style: TextStyle(fontSize: 11, color: Colors.brown.shade300)),
          ],
          const SizedBox(height: 12),
          child,
        ]),
      ),
    );
  }
}

class _RankItem {
  const _RankItem({required this.label, required this.meta, required this.value, required this.color});
  final String label;
  final String meta;
  final double value;
  final Color color;
}

class _RankBars extends StatelessWidget {
  const _RankBars({required this.title, required this.subtitle, required this.items});
  final String title;
  final String subtitle;
  final List<_RankItem> items;

  @override
  Widget build(BuildContext context) {
    final max = items.isEmpty ? 1.0 : items.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            const Spacer(),
            Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.brown.shade300)),
          ]),
          const SizedBox(height: 14),
          ...items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  SizedBox(width: 22, child: Text('${i + 1}'.padLeft(2, '0'), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: item.color.withValues(alpha: 0.7)))),
                  Expanded(child: Text(item.label, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                  Text(item.meta, style: TextStyle(fontSize: 10, color: Colors.brown.shade400)),
                ]),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: max == 0 ? 0 : item.value / max,
                    minHeight: 6,
                    backgroundColor: item.color.withValues(alpha: 0.10),
                    valueColor: AlwaysStoppedAnimation<Color>(item.color.withValues(alpha: 0.85)),
                  ),
                ),
              ]),
            );
          }),
        ]),
      ),
    );
  }
}

String _inr(num value) {
  final rounded = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < rounded.length; i++) {
    if (i > 0 && (rounded.length - i) % 3 == 0) buffer.write(',');
    buffer.write(rounded[i]);
  }
  return '₹$buffer';
}



// ---------------- Kitchen tab ----------------

class KitchenTab extends StatefulWidget {
  const KitchenTab({super.key, required this.api});
  final ApiClient api;

  @override
  State<KitchenTab> createState() => _KitchenTabState();
}

class _KitchenTabState extends State<KitchenTab> {
  List<Restaurant> _restaurants = [];
  List<Order> _orders = [];
  Map<String, List<Map<String, dynamic>>> _orderItems = {};
  String? _selectedRestaurant; // null => all
  bool _loading = true;
  String? _error;
  Timer? _ticker;

  List<MenuItem> _menu = [];
  bool _menuLoading = false;

  @override
  void initState() {
    super.initState();
    _load();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final rdata = await widget.api.getList('/restaurants');
      _restaurants = rdata.map((e) => Restaurant.fromJson(e as Map<String, dynamic>)).toList();
      await _loadOrders();
      await _loadMenu();
    } catch (_) {
      _error = 'No internet connection. Check the API server and try again.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadOrders() async {
    final path = _selectedRestaurant == null
        ? '/orders'
        : '/orders?restaurantId=$_selectedRestaurant';
    final data = await widget.api.getList(path);
    _orders = data.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
    final itemsMap = <String, List<Map<String, dynamic>>>{};
    await Future.wait(_orders.map((o) async {
      try {
        final detail = await widget.api.getMap('/orders/${o.id}');
        final items = (detail['items'] as List?) ?? [];
        itemsMap[o.id] = items.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } catch (_) {
        itemsMap[o.id] = const [];
      }
    }));
    _orderItems = itemsMap;
  }

  Future<void> _setStatus(Order o, String status) async {
    try {
      await widget.api.put('/orders/${o.id}/status', {'status': status});
      await _loadOrders();
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update status')));
      }
    }
  }

  Future<void> _loadMenu() async {
    setState(() => _menuLoading = true);
    try {
      final data = _selectedRestaurant == null
          ? await widget.api.getList('/menu')
          : await widget.api.getList('/menu?restaurantId=$_selectedRestaurant');
      _menu = data.map((e) => MenuItem.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => _menuLoading = false);
    }
  }

  Future<void> _toggleAvailability(MenuItem item) async {
    try {
      await widget.api.put('/menu/${item.id}', {'isAvailable': !item.isAvailable});
      final idx = _menu.indexWhere((m) => m.id == item.id);
      if (idx >= 0) {
        _menu[idx] = MenuItem(
          id: item.id,
          restaurantId: item.restaurantId,
          name: item.name,
          description: item.description,
          price: item.price,
          image: item.image,
          rating: item.rating,
          ratingCount: item.ratingCount,
          isVeg: item.isVeg,
          category: item.category,
          homeCategory: item.homeCategory,
          isBestseller: item.isBestseller,
          isRecommended: item.isRecommended,
          isAvailable: !item.isAvailable,
          addOns: item.addOns,
        );
      }
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to toggle availability')));
      }
    }
  }

  Color _timerColor(int seconds) {
    if (seconds < 600) return const Color(0xFF1f8a4c);
    if (seconds <= 1200) return const Color(0xFFb87a12);
    return const Color(0xFFC4202F);
  }

  int _liveSeconds(Order o) {
    DateTime? start = o.preparingStartedAt ?? o.confirmedAt ?? o.createdAt;
    DateTime? end = o.readyAt;
    if (start == null) return 0;
    final e = (end ?? DateTime.now()).difference(start).inSeconds;
    return e < 0 ? 0 : e;
  }

  String _formatTimer(Order o) {
    final seconds = _liveSeconds(o);
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  List<Order> _byStatus(String status) => _orders.where((o) => o.status == status).toList();

  @override
  Widget build(BuildContext context) {
    if (_error != null) return _ErrorState(onRetry: _load);
    if (_loading) return const _SkeletonList();
    if (_menu.isEmpty && _restaurants.isNotEmpty) {
      _loadMenu();
    }
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(children: [
              Expanded(
                child: DropdownButtonFormField<String?>(
                  initialValue: _selectedRestaurant,
                  decoration: const InputDecoration(labelText: 'Restaurant', border: OutlineInputBorder(), isDense: true),
                  items: [
                    const DropdownMenuItem<String?>(value: null, child: Text('All restaurants')),
                    ..._restaurants.map((r) => DropdownMenuItem<String?>(value: r.id, child: Text(r.name))),
                  ],
                  onChanged: (v) async {
                    setState(() => _selectedRestaurant = v);
                    await _loadOrders();
                    _menu = [];
                    await _loadMenu();
                    if (mounted) setState(() {});
                  },
                ),
              ),
            ]),
          ),
          const TabBar(tabs: [Tab(text: 'Orders'), Tab(text: 'Availability')]),
          Expanded(
            child: TabBarView(children: [
              _buildOrdersBoard(),
              _buildAvailability(),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersBoard() {
    return LayoutBuilder(builder: (context, constraints) {
      final columns = [
        _KanbanColumn(title: 'Confirmed', orders: _byStatus('confirmed'), color: const Color(0xFF9A6206)),
        _KanbanColumn(title: 'Preparing', orders: _byStatus('preparing'), color: const Color(0xFFb87a12)),
        _KanbanColumn(title: 'Ready', orders: _byStatus('ready'), color: const Color(0xFF1f8a4c)),
      ];
      if (constraints.maxWidth < 700) {
        return ListView(
          padding: const EdgeInsets.all(12),
          children: columns.map((c) => Padding(padding: const EdgeInsets.only(bottom: 12), child: c.build(context, this))).toList(),
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: columns.map((c) => Expanded(child: Padding(padding: const EdgeInsets.all(8), child: c.build(context, this)))).toList(),
      );
    });
  }

  Widget _buildAvailability() {
    if (_menuLoading) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        ..._menu.map((m) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(m.isAvailable ? 'Available' : 'Sold out', style: TextStyle(color: m.isAvailable ? const Color(0xFF1f8a4c) : const Color(0xFFC4202F))),
                trailing: Switch(
                  value: m.isAvailable,
                  onChanged: (_) => _toggleAvailability(m),
                  activeThumbColor: const Color(0xFF1f8a4c),
                ),
              ),
            )),
      ],
    );
  }
}

class _KanbanColumn {
  final String title;
  final List<Order> orders;
  final Color color;
  _KanbanColumn({required this.title, required this.orders, required this.color});

  Widget build(BuildContext context, _KitchenTabState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: color)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
                child: Text('${orders.length}', style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 12)),
              ),
            ]),
            const SizedBox(height: 8),
            ...orders.map((o) => _OrderCard(order: o, state: state)),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.state});
  final Order order;
  final _KitchenTabState state;

  @override
  Widget build(BuildContext context) {
    final seconds = state._liveSeconds(order);
    final color = state._timerColor(seconds);
    final items = state._orderItems[order.id] ?? const [];
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEFE5DE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('#${order.id}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const Spacer(),
            Text(state._formatTimer(order), style: TextStyle(fontWeight: FontWeight.w700, color: color, fontFeatures: const [FontFeature.tabularFigures()])),
          ]),
          const SizedBox(height: 6),
          ...items.map((it) => Text('${it['quantity']}x ${it['name']}', style: const TextStyle(fontSize: 12, color: Color(0xFF7A6F69)))),
          const SizedBox(height: 6),
          Row(children: [
            _Flag(label: order.locality.isEmpty ? 'Pickup' : 'Delivery'),
            const SizedBox(width: 6),
            _Flag(label: '\u20B9${order.total.toStringAsFixed(0)}'),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            if (order.status == 'confirmed')
              Expanded(child: FilledButton(onPressed: () => state._setStatus(order, 'preparing'), child: const Text('Start cooking'))),
            if (order.status == 'preparing')
              Expanded(child: FilledButton(onPressed: () => state._setStatus(order, 'ready'), child: const Text('Mark ready'))),
            if (order.status == 'ready')
              Expanded(child: OutlinedButton(onPressed: null, child: const Text('Awaiting pickup'))),
          ]),
        ],
      ),
    );
  }
}

class _Flag extends StatelessWidget {
  const _Flag({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: const Color(0xFFF3ECE7), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: const TextStyle(fontSize: 11)),
    );
  }
}