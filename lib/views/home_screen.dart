import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/cubits/news_state.dart';
import 'package:news_app/models/category_model.dart';
import '../cubits/news_cubit.dart';
import '../models/user_model.dart';
import '../services/local_auth_service.dart';
import '../widgets/article_card.dart';

class HomeScreen extends StatefulWidget {
  final UserModel currentUser;

  const HomeScreen({super.key, required this.currentUser});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Category selectedCategory = Category(
    id: 'general',
    name: 'General',
    displayName: 'General',
    icon: Icons.public,
    color: Colors.blue,
    isSelected: true,
  );

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    context.read<NewsCubit>().fetchByCategory(selectedCategory);
  }

  void _onCategoryChanged(Category category) {
    setState(() {
      selectedCategory = category;
    });
    _loadNews();
  }

  void _onLogout() async {
    await LocalAuthService().logout();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good morning";
    } else if (hour < 17) {
      return "Good afternoon";
    } else {
      return "Good evening";
    }
  }

  PreferredSizeWidget _buildAppBar(UserModel user) {
    final greeting = _getGreeting();
    final unreadNotifications = 3; 
    final isOnline = true; 

    return AppBar(
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(user.profileImage ?? ''),
            radius: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$greeting, ${user.firstName.split(' ').first} 👋",
                  style: const TextStyle(fontSize: 16),
                ),
                Row(
                  children: [
                    Icon(
                      isOnline ? Icons.wifi : Icons.wifi_off,
                      size: 14,
                      color: isOnline ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isOnline ? "Online" : "Offline",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                
              },
            ),
            if (unreadNotifications > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    unreadNotifications.toString(),
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => Navigator.pushNamed(context, '/search'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.currentUser;

    return Scaffold(
      appBar: _buildAppBar(user),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user.firstName),
              accountEmail: Text(user.email),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(user.profileImage ?? ''),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text('Bookmarks'),
              trailing: BlocBuilder<NewsCubit, NewsState>(
                builder: (context, state) {
                  final count = context.read<NewsCubit>().bookmarks.length;
                  return CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.blue,
                    child: Text('$count',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.white)),
                  );
                },
              ),
              onTap: () => Navigator.pushNamed(context, '/bookmarks'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: _onLogout,
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadNews,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Welcome back, ${user.firstName.split(' ').first} 👋",
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: Category.defaultCategories().length,
              itemBuilder: (context, index) {
                final category = Category.defaultCategories()[index];
                final isSelected = category.id == selectedCategory.id;

                return ChoiceChip(
                  label: Text(category.displayName),
                  avatar: Icon(category.icon, size: 18),
                  selected: isSelected,
                  selectedColor: category.color,
                  onSelected: (_) {
                    setState(() {
                      selectedCategory = category;
                      
                    });
                  },
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                  backgroundColor: Colors.grey[200],
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 8),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: BlocBuilder<NewsCubit, NewsState>(
                builder: (context, state) {
                  if (state is NewsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is NewsLoaded) {
                    if (state.articles.isEmpty) {
                      return const Center(child: Text("No articles found."));
                    }
                    return ListView.builder(
                      itemCount: state.articles.length,
                      itemBuilder: (context, index) {
                        return NewsCard(article: state.articles[index]);
                      },
                    );
                  } else if (state is NewsError) {
                    return Center(child: Text("Error: ${state.message}"));
                  } else {
                    return const SizedBox();
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/search'),
        child: const Icon(Icons.search),
      ),
    );
  }
}
