# Othello Game in MIPS Assembly (Mipsy)

## Overview
This repository contains a MIPS assembly language implementation of the classic board game, Othello. The game is developed to run on the Mipsy simulator, a tool specifically designed for educational purposes to teach and simulate MIPS assembly language programs.

Othello, also known as Reversi, is a strategy board game for two players, played on an 8×8 uncheckered board. Players take turns placing disks on the board with their assigned color facing up. During a play, any disks of the opponent's color that are in a straight line and bounded by the disk just placed and another disk of the current player's color are turned over to the current player's color. The objective is to have the majority of disks turned to display your color when the last playable empty square is filled.

## Playing the Game

### Loading the Game
To play the game, you need to load the provided MIPS assembly file into the [Mipsy Simulator](https://cgi.cse.unsw.edu.au/~cs1521/mipsy/). Mipsy is an online simulator for MIPS assembly language, offering a user-friendly platform to run and test MIPS code in a simulated environment.

### Running the Game
After loading the file into Mipsy, assemble and run the code. The game will prompt you for inputs and display the game board in the console.

### Game Play
- Players alternate turns, placing a colored disk on the board.
- Each move must capture one or more of the opponent's disks.
- The game ends when either the board is filled or neither player can make a valid move.
- The winner is the player with the majority of disks on the board.

## About MIPS and Mipsy

### MIPS Assembly Language
MIPS (Microprocessor without Interlocked Pipeline Stages) is a type of processor architecture and its associated assembly language. Known for its RISC (Reduced Instruction Set Computing) design, MIPS assembly language is widely used in academic settings for teaching low-level programming concepts.

### Mipsy Simulator
Mipsy is an online tool for simulating MIPS assembly language programs. It provides a convenient and accessible platform for learning and experimenting with MIPS code, offering features like syntax highlighting, error detection, and step-through execution.

