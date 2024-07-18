import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const TikTakToeApp());
}

class TikTakToeApp extends StatelessWidget {
  const TikTakToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TickTackToe',
      home: TikTakToe(),
    );
  }
}

enum Player {
  round('O'), // consider this as a max player
  cross('X'); // consider this as a min player

  final String symbol;
  const Player(this.symbol);
}

class TikTakToe extends StatefulWidget {
  const TikTakToe({super.key});

  @override
  State<TikTakToe> createState() => _TikTakToeState();
}

class _TikTakToeState extends State<TikTakToe> {
  final size = 600.0;
  var gameState = List.generate(9, (index) => '');
  Player? winner;
  var isDraw = false;

  final rand = Random();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _gridBuilder(),
            const SizedBox(
              height: 30.0,
            ),
            _gameOverBuilder(),
          ],
        ),
      ),
    );
  }

  Widget _gridBuilder() {
    return SizedBox(
      width: size,
      height: size,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => _playMove(index),
            child: Container(
              width: 100.0,
              height: 100.0,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                ),
              ),
              child: Center(
                child: Text(
                  gameState[index],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 100.0,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _gameOverBuilder() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _resetGameState,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
          ),
          child: const Text(
            'Restart',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(
          height: 20.0,
        ),
        if (isDraw || winner != null)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'GAME OVER',
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.white,
                ),
              ),
              isDraw
                  ? const Text(
                      'DRAW!',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      '${winner?.symbol} WON!',
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.white,
                      ),
                    ),
            ],
          ),
      ],
    );
  }

  /// Plays the move based on the index.
  void _playMove(final int index) {
    if (gameState[index].isNotEmpty) return;

    _playPlayerMove(index);
    final isOver = _checkIfGameOver();

    if (!isOver) {
      _playBotMove();
      _checkIfGameOver();
    }
  }

  /// Plays the player's move.
  void _playPlayerMove(final int index) {
    if (gameState[index].isNotEmpty) return;

    final turn = getTurn(gameState);
    setState(() {
      gameState[index] = turn.symbol;
    });
  }

  /// Plays the bot's move.
  void _playBotMove() {
    var bestVal = 1000;
    var bestMove = -1;
    for (final move in getAvailableMoves(gameState)) {
      final newState = applyMove(gameState, move);
      var moveVal = minMaxAlgo(newState);
      if (moveVal < bestVal) {
        bestMove = move;
        bestVal = moveVal;
      }
    }
    setState(() {
      gameState[bestMove] = Player.cross.symbol;
    });
  }

  /// Checks if the game is won by O or X or the game is draw.
  bool _checkIfGameOver() {
    final result = evaluate(gameState);
    final draw = !gameState.contains('');
    if (draw) {
      setState(() {
        isDraw = true;
      });

      return true;
    } else {
      if (result == -1) {
        setState(() {
          winner = Player.cross;
        });

        return true;
      } else if (result == 1) {
        setState(() {
          winner = Player.round;
        });

        return true;
      }
    }

    return false;
  }

  /// Resets the game state.
  void _resetGameState() {
    setState(() {
      gameState = List.generate(9, (index) => '');
      winner = null;
      isDraw = false;
    });
  }

  /// Start the min max algorithm.
  int minMaxAlgo(final List<String> gameState) {
    if (isTerminal(gameState)) {
      return evaluate(gameState);
    }

    if (getTurn(gameState) == Player.round) {
      var val = -1000;

      for (final move in getAvailableMoves(gameState)) {
        final newState = applyMove(gameState, move);
        val = max(val, minMaxAlgo(newState));
      }

      return val;
    }

    if (getTurn(gameState) == Player.cross) {
      var val = 1000;

      for (final move in getAvailableMoves(gameState)) {
        final newState = applyMove(gameState, move);
        val = min(val, minMaxAlgo(newState));
      }

      return val;
    }

    return 0;
  }

  /// Check if the game state is in the terminal state.
  bool isTerminal(final List<String> gameState) {
    return !gameState.contains('');
  }

  /// Gets the player turn based on the game state.
  Player getTurn(final List<String> gameState) {
    final roundCount =
        gameState.where((element) => element == Player.round.symbol).length;
    final crossCount =
        gameState.where((element) => element == Player.cross.symbol).length;

    return roundCount > crossCount ? Player.cross : Player.round;
  }

  /// Gets the available moves based on the game state.
  List<int> getAvailableMoves(final List<String> gameState) {
    var moves = <int>[];

    for (var i = 0; i < gameState.length; i++) {
      if (gameState[i].isEmpty) {
        moves.add(i);
      }
    }

    return moves;
  }

  /// Gets a new gameState after applying a move to the current gameState.
  List<String> applyMove(final List<String> gameState, final int move) {
    final turn = getTurn(gameState);

    final newState = List<String>.from(gameState);
    newState[move] = turn.symbol;

    return newState;
  }

  /// Returns the value of the game state.
  int evaluate(final List<String> gameState) {
    //0  1  2
    //-------
    //3  4  5
    //-------
    //6  7  8

    final winningPatterns = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (final pattern in winningPatterns) {
      final a = gameState[pattern[0]];
      final b = gameState[pattern[1]];
      final c = gameState[pattern[2]];

      if (a == b && b == c && a != '') {
        return a == Player.round.symbol ? 1 : -1;
      }
    }

    return 0;
  }
}
