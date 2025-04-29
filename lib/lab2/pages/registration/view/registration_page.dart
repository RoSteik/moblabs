import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moblabs/lab2/logic/service/auth/auth_service.dart';
import 'package:moblabs/lab2/pages/registration/cubit/registration_cubit.dart';
import 'package:moblabs/lab2/pages/registration/cubit/registration_state.dart';

class RegistrationPage extends StatelessWidget {
  RegistrationPage({super.key});

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegistrationCubit(authService: AuthService()),
      child: BlocConsumer<RegistrationCubit, RegistrationState>(
        listener: (context, state) {
          if (state is RegistrationSuccess) {
            Navigator.pushNamed(context, '/login');
          } else if (state is RegistrationFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator:
                          (value) =>
                              value!.isEmpty ? 'Name cannot be empty' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator:
                          (value) =>
                              value!.contains('@')
                                  ? null
                                  : 'Enter a valid email',
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password'),
                      validator:
                          (value) =>
                              value!.length < 6 ? 'Password too short' : null,
                    ),
                    const SizedBox(height: 20),
                    if (state is RegistrationLoading)
                      const CircularProgressIndicator()
                    else
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<RegistrationCubit>().register(
                              _nameController.text,
                              _emailController.text,
                              _passwordController.text,
                            );
                          }
                        },
                        child: const Text('Sign Up'),
                      ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      child: const Text('Already have an account? Login'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
