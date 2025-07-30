import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frogg_flutter/src/data/blocs/profile/profile_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoadInProgress) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProfileLoadSuccess) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(state.profile.avatarUrl),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.profile.username,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          } else if (state is ProfileLoadFailure) {
            return Center(child: Text('Error: ${state.error}'));
          }
          return const Center(child: Text('No Profile Data'));
        },
      ),
    );
  }
}