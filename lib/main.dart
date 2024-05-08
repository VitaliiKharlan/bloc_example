import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'counter_bloc.dart';
import 'user_bloc/user_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final counterBloc = CounterBloc();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => counterBloc,
          lazy: false,
        ),
        BlocProvider(
          create: (context) => UserBloc(counterBloc),
        ),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final counterBloc = BlocProvider.of<CounterBloc>(context);
    return Scaffold(
      floatingActionButton: BlocConsumer<CounterBloc, int>(
        buildWhen: (prev, current) => prev > current,
        listenWhen: (prev, current) => prev > current,
        listener: (context, state) {
          if (state == 0) {
            Scaffold.of(context).showBottomSheet(
              (context) => Container(
                color: Colors.blue,
                width: double.infinity,
                height: 30,
                child: const Text('State is 0'),
              ),
            );
          }
        },
        builder: (context, state) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.toString()),
            IconButton(
              onPressed: () {
                counterBloc.add(CounterIncrementEvent());
              },
              icon: const Icon(Icons.plus_one),
            ),
            IconButton(
              onPressed: () {
                counterBloc.add(CounterDecrementEvent());
              },
              icon: const Icon(Icons.exposure_minus_1),
            ),
            IconButton(
              onPressed: () {
                final userBloc = context.read<UserBloc>();
                userBloc.add(
                  UserGetUsersEvent(context.read<CounterBloc>().state),
                );
              },
              icon: const Icon(Icons.person),
            ),
            IconButton(
              onPressed: () {
                final userBloc = context.read<UserBloc>();

                userBloc.add(
                  UserGetUsersJobEvent(context.read<CounterBloc>().state),
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: userBloc,
                      child: const Job(),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.work),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              BlocBuilder<CounterBloc, int>(
                // bloc: counterBloc,
                builder: (context, state) {
                  final users =
                      context.select((UserBloc bloc) => bloc.state.users);
                  return Column(
                    children: [
                      Text(
                        state.toString(),
                        style: const TextStyle(fontSize: 33),
                      ),
                      if (users.isNotEmpty) ...users.map((e) => Text(e.name)),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Job extends StatelessWidget {
  const Job({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          final users = state.users;
          final job = state.job;
          return Column(
            children: [
              if (state.isLoading) const CircularProgressIndicator(),
              if (job.isNotEmpty) ...state.job.map((e) => Text(e.name)),
            ],
          );
        },
      ),
    );
  }
}
