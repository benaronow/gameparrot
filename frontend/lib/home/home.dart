import 'package:flutter/material.dart';
import 'package:gameparrot/home/account_page/account_page.dart';
import 'package:gameparrot/home/sidebar.dart';
import 'package:gameparrot/home/user_list/user_list.dart';
import 'package:gameparrot/providers/games_provider.dart';
import 'package:gameparrot/providers/users_provider.dart';
import 'package:provider/provider.dart';
import 'app_bar.dart';
import 'package:gameparrot/theme.dart';
import '../services/services.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    WebSocketService.initialize(context);
  }

  @override
  void dispose() {
    WebSocketService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedId = Provider.of<UsersProvider>(context).selectedId;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: const GameParrotAppBar(),
      body: Row(
        children: [
          if (!isMobile) const Sidebar(),
          Expanded(
            child: Column(
              children: [
                if (isMobile && selectedId == null)
                  Expanded(child: UserList())
                else
                  Expanded(
                    child: ChangeNotifierProvider<GamesProvider>(
                      create: (context) => GamesProvider(),
                      child: AccountPage(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
