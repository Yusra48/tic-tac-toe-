import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:expressions/expressions.dart';

class CalculatorView extends StatefulWidget {
  const CalculatorView({Key? key}) : super(key: key);

  @override
  _CalculatorViewState createState() => _CalculatorViewState();
}

class _CalculatorViewState extends State<CalculatorView> {
  String _expression = '';
  String _result = '';

  void _onButtonPressed(String buttonText) {
    setState(() {
      if (buttonText == '=') {
        _calculateResult();
      } else if (buttonText == 'C') {
        _clearResult();
      } else {
        _expression += buttonText;
      }
    });
  }

  void _calculateResult() {
    try {
      double eval = evalExpression(_expression);
      _result = eval.toString();
      saveCalculation(_expression, eval);
    } catch (e) {
      print('Error calculating result: $e');
      setState(() {
        _result = 'Error';
      });
    }
  }

  double evalExpression(String expression) {
    try {
      Expression exp = Expression.parse(expression);
      final evaluator = ExpressionEvaluator();
      final result = evaluator.eval(exp, {});
      if (result is double) {
        return result;
      } else {
        throw Exception('Invalid expression result');
      }
    } catch (e) {
      print('Error evaluating expression: $e');
      throw Exception('Invalid expression');
    }
  }

  void _clearResult() {
    setState(() {
      _expression = '';
      _result = '';
    });
  }

  Future<void> saveCalculation(String expression, double result) async {
    try {
      await FirebaseFirestore.instance.collection('calculations').add({
        'expression': expression,
        'result': result,
        'timestamp': DateTime.now(),
      });
    } catch (e) {
      print('Error saving calculation: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: Text(
          'Calculator',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _expression,
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
          SizedBox(height: 10),
          Text(
            _result,
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 20),
          _buildKeypad(),
        ],
      ),
    );
  }

  Widget _buildKeypad() {
    List<List<String>> keypad = [
      ['7', '8', '9', '/'],
      ['4', '5', '6', '*'],
      ['1', '2', '3', '+'],
      ['=', '0', 'C', '-']
    ];

    return Column(
      children: keypad.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.map((buttonText) {
            return _buildButton(buttonText);
          }).toList(),
        );
      }).toList(),
    );
  }

  Widget _buildButton(String buttonText) {
    return Container(
      padding: EdgeInsets.all(10),
      child: ElevatedButton(
        onPressed: () => _onButtonPressed(buttonText),
        child: Text(
          buttonText,
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
