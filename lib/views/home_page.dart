import 'package:bachelor/views/user_info_page.dart';
import 'package:flutter/material.dart';
import 'recommendation_chat_page.dart';
import 'gallery_page.dart';
import 'favorites_page.dart';
import '../controllers/auth_controller.dart';
import '../views/login_page.dart';

// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  final int userId;
  int selectedPage;

  HomePage({super.key, required this.userId, this.selectedPage=0});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedPage;
    _pages = [
      RecommendationChatPage(userId: widget.userId),
      GalleryPage(userId: widget.userId),
      FavoritesPage(userId: widget.userId),
      UserInfoPage(userId: widget.userId),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      widget.selectedPage=0;
    });
  }

  void _logout() async {
    await AuthController().logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Рекомендатор одягу'),
        ),
        drawer: Drawer(
          width: MediaQuery.of(context).size.width*0.8,
          child: ListView(
            children: [
              Container(
                height: 64,
                color: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Меню",
                      style: TextStyle(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.chat),
                title: const Text('Рекомендації'),
                selected: _selectedIndex == 0,
                onTap: () {
                  _onItemTapped(0);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Одяг'),
                selected: _selectedIndex == 1,
                onTap: () {
                  _onItemTapped(1);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text('Обране'),
                selected: _selectedIndex == 2,
                onTap: () {
                  _onItemTapped(2);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Акаунт'),
                selected: _selectedIndex == 3,
                onTap: () {
                  _onItemTapped(3);
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Вийти'),
                onTap: _logout,
              ),
            ],
          ),
        ),
        body: _pages[_selectedIndex],
      ),
    );
  }
}
