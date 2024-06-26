import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:search_user_repository/search_user_repository.dart';

import 'search_bloc/search_bloc.dart';

class MyAppSearch extends StatelessWidget {
  const MyAppSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => SearchUserRepository(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => SearchBloc(
                searchUserRepository:
                    RepositoryProvider.of<SearchUserRepository>(context)),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            textTheme: const TextTheme(
              bodyText2: TextStyle(fontSize: 33),
              subtitle1: TextStyle(fontSize: 22),
            ),
          ),
          home: const Scaffold(
            body: SafeArea(
              child: MyHomePage(),
            ),
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final users = context.select((SearchBloc bloc) => bloc.state.users);
    return Column(
      children: [
        const Text('Search User'),
        const SizedBox(height: 20),
        TextFormField(
          decoration: const InputDecoration(
            hintText: 'User name',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            context.read<SearchBloc>().add(SearchUserEvent(value));
          },
        ),
        if (users.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title: Text(user.username ?? ''),
                  leading: Hero(
                    tag: user.username ?? '',
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(user.images ?? ''),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserInfoScreen(
                          user: user,
                        ),
                      ),
                    );
                  },
                );
              },
              itemCount: users.length,
            ),
          ),
      ],
    );
  }
}

class UserInfoScreen extends StatelessWidget {
  final UserModel user;

  const UserInfoScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          user.username ?? '',
          style: const TextStyle(fontSize: 32),
        ),
      ),
      body: Column(
        children: [
          Hero(
            tag: user.username ?? '',
            child: Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(user.images ?? ''),
                ),
              ),
            ),
          ),
          Text.rich(
            TextSpan(
              style: const TextStyle(fontSize: 16),
              children: [
                const TextSpan(text: 'Visit Site'),
                TextSpan(
                  text: user.url ?? '',
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = () {

                  }
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
