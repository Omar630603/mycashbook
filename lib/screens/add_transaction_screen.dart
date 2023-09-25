import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:formz/formz.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class AddTransactionScreen extends StatefulWidget {
  AddTransactionScreen({super.key, Random? seed, required this.transactionType})
      : seed = seed ?? Random();

  static const String routeName = '/add_transaction';

  final Random seed;
  // ignore: prefer_typing_uninitialized_variables
  final transactionType;

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _key = GlobalKey<FormState>();
  late AddTransactionFormState _state;
  late final TextEditingController _dateController;
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _transactionTypeController;

  void _onDateChanged() {
    setState(() {
      _state = _state.copyWith(date: Date.dirty(_dateController.text));
    });
  }

  void _onAmountChanged() {
    setState(() {
      _state = _state.copyWith(amount: Amount.dirty(_amountController.text));
    });
  }

  void _onDescriptionChanged() {
    setState(() {
      _state = _state.copyWith(
        description: Description.dirty(_descriptionController.text),
      );
    });
  }

  Future onSubmit() async {
    if (!_key.currentState!.validate()) return;

    setState(() {
      _state = _state.copyWith(status: FormzSubmissionStatus.inProgress);
    });

    try {
      await submitForm();
      _state = _state.copyWith(status: FormzSubmissionStatus.success);
    } catch (_) {
      _state = _state.copyWith(status: FormzSubmissionStatus.failure);
    }

    if (!mounted) return;

    setState(() {});

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context)
        ..nextFocus()
        ..unfocus();
    });

    const successSnackBar = SnackBar(
      content: Text('Transaction added successfully! 🎉'),
    );
    const failureSnackBar = SnackBar(
      content: Text('Transaction failed to add! 😢'),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      _state.status.isSuccess ? successSnackBar : failureSnackBar,
    );

    if (_state.status.isSuccess) _resetForm();
  }

  Future submitForm() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (widget.seed.nextInt(2) == 0) throw Exception();
  }

  void _resetForm() {
    _key.currentState!.reset();
    _dateController.clear();
    _amountController.clear();
    _descriptionController.clear();
    setState(() => _state = AddTransactionFormState());
  }

  @override
  void initState() {
    super.initState();
    _state = AddTransactionFormState();
    _dateController = TextEditingController(text: _state.date.value)
      ..addListener(_onDateChanged);
    _amountController = TextEditingController(text: _state.amount.value)
      ..addListener(_onAmountChanged);
    _descriptionController =
        TextEditingController(text: _state.description.value)
          ..addListener(_onDescriptionChanged);
    _transactionTypeController =
        TextEditingController(text: widget.transactionType);
  }

  @override
  void dispose() {
    _dateController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _transactionTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add ${widget.transactionType} Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _key,
            child: Column(
              children: [
                const SizedBox(height: 16),
                TextFormField(
                  controller: _transactionTypeController,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Transaction Type',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('addTransaction_dateInput'),
                  controller: _dateController,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.calendar_today),
                    labelText: 'Date',
                    errorMaxLines: 3,
                  ),
                  validator: (value) =>
                      _state.date.validator(value ?? '')?.text(),
                  textInputAction: TextInputAction.done,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context, //context of current state
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2015),
                      lastDate: DateTime(2100),
                    );

                    if (pickedDate != null) {
                      String formattedDate =
                          DateFormat('dd MMM yyyy').format(pickedDate);
                      setState(() {
                        _dateController.text = formattedDate;
                      });
                    } else {
                      setState(() {
                        _dateController.text = _dateController.text;
                      });
                    }
                    setState(() {
                      FocusScope.of(context).requestFocus(FocusNode());
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('addTransaction_amountInput'),
                  controller: _amountController,
                  inputFormatters: [
                    CurrencyTextInputFormatter(
                      locale: 'id',
                      decimalDigits: 0,
                      symbol: 'Rp. ',
                    ),
                  ],
                  decoration: const InputDecoration(
                    icon: Icon(Icons.attach_money),
                    labelText: 'Amount',
                    errorMaxLines: 2,
                  ),
                  validator: (value) =>
                      _state.amount.validator(value ?? '')?.text(),
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('addTransaction_descriptionInput'),
                  maxLines: 2,
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.description),
                    labelText: 'Description',
                    errorMaxLines: 2,
                  ),
                  validator: (value) =>
                      _state.description.validator(value ?? '')?.text(),
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _state.status.isInProgress ? null : onSubmit,
                      child: const Text('Submit'),
                    ),
                    ElevatedButton(
                        onPressed:
                            _state.status.isInProgress ? null : _resetForm,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.redAccent,
                          ),
                        ),
                        child: const Text(' Reset ')),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum DateValidationError { invalid, empty }

class Date extends FormzInput<String, DateValidationError>
    with FormzInputErrorCacheMixin {
  Date.pure([super.value = '']) : super.pure();

  Date.dirty([super.value = '']) : super.dirty();

  @override
  DateValidationError? validator(String value) {
    if (value.isEmpty) {
      return DateValidationError.empty;
    }
    try {
      DateFormat('dd MMM yyyy').parse(value);
    } catch (e) {
      return DateValidationError.invalid;
    }

    return null;
  }
}

enum DescriptionValidationError { invalid, empty }

class Description extends FormzInput<String, DescriptionValidationError>
    with FormzInputErrorCacheMixin {
  Description.pure([super.value = '']) : super.pure();

  Description.dirty([super.value = '']) : super.dirty();

  @override
  DescriptionValidationError? validator(String value) {
    if (value.isEmpty) {
      return DescriptionValidationError.empty;
    } else if (value.length < 3) {
      return DescriptionValidationError.invalid;
    }

    return null;
  }
}

enum AmountValidationError { invalid, empty }

class Amount extends FormzInput<String, AmountValidationError>
    with FormzInputErrorCacheMixin {
  Amount.pure([super.value = '']) : super.pure();

  Amount.dirty([super.value = '']) : super.dirty();

  @override
  AmountValidationError? validator(String value) {
    if (value.isEmpty) {
      return AmountValidationError.empty;
    }

    try {
      value = value.replaceAll('Rp. ', '');
      double.parse(value);
    } catch (e) {
      return AmountValidationError.invalid;
    }

    return null;
  }
}

class AddTransactionFormState with FormzMixin {
  AddTransactionFormState({
    Date? date,
    Amount? amount,
    Description? description,
    this.status = FormzSubmissionStatus.initial,
  })  : date = date ?? Date.pure(),
        amount = amount ?? Amount.pure(),
        description = description ?? Description.pure();

  final Date date;
  final Amount amount;
  final Description description;
  final FormzSubmissionStatus status;

  AddTransactionFormState copyWith({
    Date? date,
    Amount? amount,
    Description? description,
    FormzSubmissionStatus? status,
  }) {
    return AddTransactionFormState(
      date: date ?? this.date,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      status: status ?? this.status,
    );
  }

  @override
  List<FormzInput<dynamic, dynamic>> get inputs => [date, amount, description];
}

extension on DateValidationError {
  String text() {
    switch (this) {
      case DateValidationError.invalid:
        return 'Invalid date';
      case DateValidationError.empty:
        return 'Please enter a date';
    }
  }
}

extension on AmountValidationError {
  String text() {
    switch (this) {
      case AmountValidationError.invalid:
        return 'Invalid amount';
      case AmountValidationError.empty:
        return 'Please enter an amount';
    }
  }
}

extension on DescriptionValidationError {
  String text() {
    switch (this) {
      case DescriptionValidationError.invalid:
        return 'Invalid description';
      case DescriptionValidationError.empty:
        return 'Please enter a description, minimum 3 characters';
    }
  }
}
