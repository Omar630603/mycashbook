import 'dart:math';
import 'package:flutter/material.dart';
import 'package:formz/formz.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key, Random? seed}) : seed = seed ?? Random();
  static const String routeName = '/login';
  final Random seed;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _key = GlobalKey<FormState>();
  late LoginFormState _state;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;

  void _onUsernameChanged() {
    setState(() {
      _state =
          _state.copyWith(username: Username.dirty(_usernameController.text));
    });
  }

  void _onPasswordChanged() {
    setState(() {
      _state = _state.copyWith(
        password: Password.dirty(_passwordController.text),
      );
    });
  }

  Future<void> _onSubmit() async {
    if (!_key.currentState!.validate()) return;

    setState(() {
      _state = _state.copyWith(status: FormzSubmissionStatus.inProgress);
    });

    try {
      await _submitForm();
      _state = _state.copyWith(status: FormzSubmissionStatus.success);
    } catch (_) {
      _state = _state.copyWith(status: FormzSubmissionStatus.failure);
    }

    if (!mounted) return;

    setState(() {});

    FocusScope.of(context)
      ..nextFocus()
      ..unfocus();

    const successSnackBar = SnackBar(
      content: Text('Logged in successfully! 🎉'),
    );
    const failureSnackBar = SnackBar(
      content: Text('Something went wrong... 🚨'),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        _state.status.isSuccess ? successSnackBar : failureSnackBar,
      );

    if (_state.status.isSuccess) {
      _resetForm();
      Navigator.of(context).pushNamed('/home');
    }
  }

  Future<void> _submitForm() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (widget.seed.nextInt(2) == 0) throw Exception();
  }

  void _resetForm() {
    _key.currentState!.reset();
    _usernameController.clear();
    _passwordController.clear();
    setState(() => _state = LoginFormState());
  }

  @override
  void initState() {
    super.initState();
    _state = LoginFormState();
    _usernameController = TextEditingController(text: _state.username.value)
      ..addListener(_onUsernameChanged);
    _passwordController = TextEditingController(text: _state.password.value)
      ..addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cash Book'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _key,
            child: Column(
              children: [
                // app logo
                Image.asset(
                  'assets/images/logo.png',
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 24),
                const Text('My Cash Book'),
                const SizedBox(height: 24),
                TextFormField(
                  key: const Key('loginForm_usernameInput'),
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.person),
                    labelText: 'Username',
                  ),
                  validator: (value) =>
                      _state.username.validator(value ?? '')?.text(),
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                ),
                TextFormField(
                  key: const Key('loginForm_passwordInput'),
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.lock),
                    labelText: 'Password',
                    errorMaxLines: 2,
                  ),
                  validator: (value) =>
                      _state.password.validator(value ?? '')?.text(),
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 24),
                if (_state.status.isInProgress)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    key: const Key('loginForm_submit'),
                    onPressed: _onSubmit,
                    child: const Text('Submit'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoginFormState with FormzMixin {
  LoginFormState({
    Username? username,
    this.password = const Password.pure(),
    this.status = FormzSubmissionStatus.initial,
  }) : username = username ?? Username.pure();

  final Username username;
  final Password password;
  final FormzSubmissionStatus status;

  LoginFormState copyWith({
    Username? username,
    Password? password,
    FormzSubmissionStatus? status,
  }) {
    return LoginFormState(
      username: username ?? this.username,
      password: password ?? this.password,
      status: status ?? this.status,
    );
  }

  @override
  List<FormzInput<dynamic, dynamic>> get inputs => [username, password];
}

enum UsernameValidationError { invalid, empty }

class Username extends FormzInput<String, UsernameValidationError>
    with FormzInputErrorCacheMixin {
  Username.pure([super.value = '']) : super.pure();

  Username.dirty([super.value = '']) : super.dirty();

  @override
  UsernameValidationError? validator(String value) {
    if (value.isEmpty) {
      return UsernameValidationError.empty;
    }

    return null;
  }
}

enum PasswordValidationError { invalid, empty }

class Password extends FormzInput<String, PasswordValidationError> {
  const Password.pure([super.value = '']) : super.pure();

  const Password.dirty([super.value = '']) : super.dirty();

  @override
  PasswordValidationError? validator(String value) {
    if (value.isEmpty) {
      return PasswordValidationError.empty;
    } else if (value.length < 8) {
      return PasswordValidationError.invalid;
    }

    return null;
  }
}

extension on UsernameValidationError {
  String text() {
    switch (this) {
      case UsernameValidationError.invalid:
        return 'Please ensure the username entered is valid';
      case UsernameValidationError.empty:
        return 'Please enter a username';
    }
  }
}

extension on PasswordValidationError {
  String text() {
    switch (this) {
      case PasswordValidationError.invalid:
        return '''Password must be at least 8 characters long''';
      case PasswordValidationError.empty:
        return 'Please enter a password';
    }
  }
}
