import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frogg_flutter/src/data/blocs/profile/profile_bloc.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoadSuccess) {
            return Center(
              child: Text('Welcome, ${state.profile.username}!'),
            );
          }
          return const Center(
            child: Text('Welcome!'),
          );
        },
      ),
    );
  }
}