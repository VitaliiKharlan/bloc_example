import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'search_bloc/search_bloc.dart';

class MyAppSearch extends StatelessWidget {
  const MyAppSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SearchBloc(),
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
                return ListTile(
                  title: Text(users[index]['username']),
                );
              },
              itemCount: users.length,
            ),
          ),
      ],
    );
  }
}
