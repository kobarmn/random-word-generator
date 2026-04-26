import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:hiragana_converter/data.dart';
import 'package:http/http.dart' as http;

class InputForm extends StatefulWidget {
  const InputForm({super.key});

  @override
  State<InputForm> createState() => _InputFormState();
}

class _InputFormState extends State<InputForm> {
  final _formKey = GlobalKey<FormState>();

  // TextFiled Widgetにて入力された値を取得、変更する機能を持つ。
  final _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextFormField(
              controller: _textEditingController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: '文章を入力してください',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  print('文章が入力されいません。');
                  return '文章が入力されていません';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
              onPressed: () {
                final formState = _formKey.currentState!;
                if (!formState.validate()) {
                  return;
                }
                debugPrint('text = ${_textEditingController}');
              },
              child: Text('変換'))
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}
