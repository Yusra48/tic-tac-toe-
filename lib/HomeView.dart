import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late CollectionReference _gameCollection;
  late List<String> _gameBoard;
  bool _isPlayerOneTurn = true;
  bool _gameOver = false;

  @override
  void initState() {
    super.initState();
    _gameCollection = _firestore.collection('GamesCollection');
    _resetGame();
  }

  void _resetGame() {
    _gameBoard = List.filled(9, '');
    _isPlayerOneTurn = true;
    _gameOver = false;
  }

  void _playMove(int index) {
    if (_gameBoard[index] == '' && !_gameOver) {
      setState(() {
        _gameBoard[index] = _isPlayerOneTurn ? 'X' : 'O';
        _isPlayerOneTurn = !_isPlayerOneTurn;
      });

      if (_checkGameResult()) {
        _gameOver = true;
        _showWinDialog(_isPlayerOneTurn ? 'O' : 'X');
      }
    }
  }

  bool _checkGameResult() {
    List<List<int>> winConditions = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var condition in winConditions) {
      if (_gameBoard[condition[0]] != '' &&
          _gameBoard[condition[0]] == _gameBoard[condition[1]] &&
          _gameBoard[condition[1]] == _gameBoard[condition[2]]) {
        return true;
      }
    }

    return false;
  }

  void _showWinDialog(String winner) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Congratulations!'),
          content: Text('$winner wins the game!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
              child: Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF71B7F0),
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Center(
          child: Text(
            'Tic Tac Toe',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0E62A7),
            ),
          ),
        ),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              if (_gameBoard[index] == '' && !_gameOver) {
                _playMove(index);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(),
              ),
              child: Center(
                child: Text(
                  _gameBoard[index],
                  style: TextStyle(fontSize: 40),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Reset Game'),
                content: Text('Do you want to reset the game?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _resetGame();
                    },
                    child: Text('Reset'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.refresh),
      ),
    );
  }
}
