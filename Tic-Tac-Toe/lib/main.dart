import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  final ThemeMode themeMode;

  TicTacToeApp({this.themeMode = ThemeMode.light});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        primaryColor: Color(0xff313131),
        scaffoldBackgroundColor: Colors.white,
        textTheme: TextTheme(
          bodyText2: TextStyle(color: Colors.black),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blueAccent,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: Colors.black,
        textTheme: TextTheme(
          bodyText2: TextStyle(color: Colors.white),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blueAccent,
        ),
      ),
      themeMode: themeMode,
      home: StartScreen(),
    );
  }
}

class StartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tic-Tac-Toe By NATUEL'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          TicTacToeGame(isAgainstComputer: false)),
                );
              },
              child: Text('Play Against a Friend'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showDifficultyDialog(context);
              },
              child: Text('Play Against Computer'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
              child: Text('Settings'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDifficultyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Difficulty'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TicTacToeGame(
                          isAgainstComputer: true, difficulty: 'Easy'),
                    ),
                  );
                },
                child: Text('Easy'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TicTacToeGame(
                          isAgainstComputer: true, difficulty: 'Medium'),
                    ),
                  );
                },
                child: Text('Medium'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TicTacToeGame(
                          isAgainstComputer: true, difficulty: 'Hard'),
                    ),
                  );
                },
                child: Text('Hard'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TicTacToeGame extends StatefulWidget {
  final bool isAgainstComputer;
  final String difficulty;

  TicTacToeGame({required this.isAgainstComputer, this.difficulty = 'Easy'});

  @override
  _TicTacToeGameState createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame> {
  List<String> _board = List.filled(9, '', growable: false);
  String _currentPlayer = 'X';
  String _winner = '';
  bool _computerPlaying = false;
  Stopwatch _stopwatch = Stopwatch();
  bool _vibrationEnabled = true;

  @override
  void initState() {
    super.initState();
    if (widget.isAgainstComputer) {
      _currentPlayer =
          Random().nextBool() ? 'X' : 'O'; // Randomly decide who starts
      if (_currentPlayer == 'O') {
        _computerPlaying = true;
        Future.delayed(Duration(milliseconds: 700), _makeComputerMove);
      }
    }
    _stopwatch.start();
  }

  void _handleTap(int index) {
    if (_board[index] == '' && _winner == '' && !_computerPlaying) {
      setState(() {
        _board[index] = _currentPlayer;
        _winner = _checkWinner();
        if (_winner == '' &&
            widget.isAgainstComputer &&
            _currentPlayer == 'X') {
          _currentPlayer = 'O';
          _computerPlaying = true;
          Future.delayed(Duration(milliseconds: 700), _makeComputerMove);
        } else if (_winner == '') {
          _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';
        }
      });
    }
  }

  void _makeComputerMove() {
    if (_winner != '' || !_board.contains('') || !_computerPlaying) {
      return; // Stop if the game is over or it's not the computer's turn
    }

    int index;

    if (widget.difficulty == 'Easy') {
      index = _easyMove();
    } else if (widget.difficulty == 'Medium') {
      index = _mediumMove();
    } else {
      index = _hardMove();
    }

    if (index != -1) {
      setState(() {
        _board[index] = _currentPlayer;
        _winner = _checkWinner();
        _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';
        _computerPlaying = false;
      });
    }
  }

  int _easyMove() {
    // Just pick a random empty spot
    List<int> emptySpots = [];
    for (int i = 0; i < _board.length; i++) {
      if (_board[i] == '') {
        emptySpots.add(i);
      }
    }
    emptySpots.shuffle();
    return emptySpots.isNotEmpty ? emptySpots.first : -1;
  }

  int _mediumMove() {
    // Try to win, otherwise pick a random empty spot
    int winMove = _getWinningMove('O');
    if (winMove != -1) return winMove;

    return _easyMove();
  }

  int _hardMove() {
    // Try to win, block the opponent, or pick a random empty spot
    int winMove = _getWinningMove('O');
    if (winMove != -1) return winMove;

    int blockMove = _getWinningMove('X');
    if (blockMove != -1) return blockMove;

    return _easyMove();
  }

  int _getWinningMove(String player) {
    for (int i = 0; i < _board.length; i++) {
      if (_board[i] == '') {
        _board[i] = player;
        if (_checkWinner() == player) {
          _board[i] = '';
          return i;
        }
        _board[i] = '';
      }
    }
    return -1;
  }

  String _checkWinner() {
    List<List<int>> winningCombos = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var combo in winningCombos) {
      if (_board[combo[0]] != '' &&
          _board[combo[0]] == _board[combo[1]] &&
          _board[combo[0]] == _board[combo[2]]) {
        _stopwatch.stop();
        return _board[combo[0]];
      }
    }

    if (!_board.contains('')) {
      _stopwatch.stop();
      return 'Draw';
    }

    return '';
  }

  void _resetGame() {
    setState(() {
      _board = List.filled(9, '', growable: false);
      _currentPlayer =
          Random().nextBool() ? 'X' : 'O'; // Randomize who starts again
      _winner = '';
      _computerPlaying = widget.isAgainstComputer && _currentPlayer == 'O';
      if (_computerPlaying) {
        Future.delayed(Duration(milliseconds: 700), _makeComputerMove);
      }
      _stopwatch.reset();
      _stopwatch.start();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tic-Tac-Toe by NATUEL'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Time: ${(_stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(1)} s',
            style: TextStyle(fontSize: 20.0),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _handleTap(index),
                  child: Container(
                    color: Theme.of(context).primaryColor,
                    child: Center(
                      child: Text(
                        _board[index],
                        style: TextStyle(
                          fontSize: 50.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_winner != '')
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _winner == 'Draw' ? 'It\'s a Draw!' : 'Player $_winner Wins!',
                style: TextStyle(fontSize: 30.0),
              ),
            ),
          ElevatedButton(
            onPressed: _resetGame,
            child: Text('Restart Game'),
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _vibrationEnabled = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: Text('Vibration'),
            value: _vibrationEnabled,
            onChanged: (value) {
              setState(() {
                _vibrationEnabled = value;
              });
            },
          ),
          ListTile(
            title: Text('App Information'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('App Information'),
                    content: Text(
                        'Tic-Tac-Toe Game\nVersion 1.0.0 developed by natuel  \     http://t.me/Natuel \ ©NATUEL'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          ListTile(
            title: Text('Send Feedback'),
            onTap: () {
              // Implement feedback functionality
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Send Feedback'),
                    content: Text('Feedback functionality coming soon!'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          SwitchListTile(
            title: Text('Dark Mode'),
            value: _darkMode,
            onChanged: (value) {
              setState(() {
                _darkMode = value;
                (context as Element).markNeedsBuild();
                runApp(TicTacToeApp(
                    themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light));
              });
            },
          ),
        ],
      ),
    );
  }
}
