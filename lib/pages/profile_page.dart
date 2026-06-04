import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import 'edit_profile_page.dart';
import 'order_detail_page.dart';
import 'landing_page.dart';

class OrderItem {
  final Product product;
  final String date;
  String status;

  OrderItem({required this.product, required this.date, required this.status});
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<OrderItem> myOrders = [];
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    loadTheme();

    if (allProducts.isNotEmpty) {
      myOrders = [
        OrderItem(
          product: allProducts[0],
          date: '01 Mei 2026',
          status: 'Proses',
        ),
        OrderItem(
          product: allProducts[2],
          date: '30 Apr 2026',
          status: 'Proses',
        ),
        OrderItem(
          product: allProducts[1],
          date: '25 Apr 2026',
          status: 'Dikirim',
        ),
        OrderItem(
          product: allProducts[3],
          date: '24 Apr 2026',
          status: 'Dikirim',
        ),
        OrderItem(
          product: allProducts[4],
          date: '20 Apr 2026',
          status: 'Selesai',
        ),
        OrderItem(
          product: allProducts[5],
          date: '15 Apr 2026',
          status: 'Pengembalian',
        ),
        OrderItem(
          product: allProducts[6],
          date: '10 Apr 2026',
          status: 'Dibatalkan',
        ),
      ];
    }
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', !isDarkMode);

    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _changeOrderStatus(OrderItem order, String newStatus) {
    setState(() {
      order.status = newStatus;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Status pesanan menjadi $newStatus')),
    );
  }

  // ===== THEME COLORS =====
  Color get bg => isDarkMode ? Colors.black : Colors.grey[50]!;
  Color get card => isDarkMode ? Colors.grey[900]! : Colors.white;
  Color get text => isDarkMode ? Colors.white : Colors.black;
  Color get subText => isDarkMode ? Colors.white70 : Colors.grey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: card,
        foregroundColor: text,

        title: Text(
          'Profil Saya',
          style: TextStyle(color: text, fontWeight: FontWeight.bold),
        ),

        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              size: 28,
              color: text,
            ),
            onPressed: toggleTheme,
          ),

          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Keluar Akun?'),
                  content: const Text('Apakah Anda yakin ingin keluar?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LandingPage(),
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text('Keluar'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),

      // ================= BODY =================
      body: Column(
        children: [
          // PROFILE HEADER
          Container(
            color: card,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/150?img=47',
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ai Nur Azizah',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ai.nur@example.com',
                        style: TextStyle(color: subText),
                      ),
                      Text(
                        '+62 812 3456 7890',
                        style: TextStyle(color: subText),
                      ),
                    ],
                  ),
                ),

                IconButton(
                  icon: Icon(Icons.edit, color: subText),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfilePage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // TAB BAR
          Container(
            color: card,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.pink,
              unselectedLabelColor: subText,
              indicatorColor: Colors.pink,
              tabs: const [
                Tab(text: 'Proses'),
                Tab(text: 'Dikirim'),
                Tab(text: 'Selesai'),
                Tab(text: 'Pengembalian'),
                Tab(text: 'Dibatalkan'),
              ],
            ),
          ),

          // TAB VIEW
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList('Proses'),
                _buildOrderList('Dikirim'),
                _buildOrderList('Selesai'),
                _buildOrderList('Pengembalian'),
                _buildOrderList('Dibatalkan'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= ORDER LIST =================
  Widget _buildOrderList(String status) {
    final list = myOrders.where((e) => e.status == status).toList();

    if (list.isEmpty) {
      return Center(
        child: Text('Tidak ada pesanan', style: TextStyle(color: subText)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, i) {
        final order = list[i];

        return Card(
          color: card,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.product.name,
                  style: TextStyle(color: text, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 4),

                Text(order.date, style: TextStyle(color: subText)),

                const SizedBox(height: 6),

                Text(
                  order.status,
                  style: const TextStyle(
                    color: Colors.pink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
