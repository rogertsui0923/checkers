import React, { Component } from 'react';
import {ActionCable} from 'actioncable-js';
import Board from './Board';

export default class Game extends Component {
  constructor(props) {
    super(props);

    this.state = {
      openGames: [],
      game: null,
      AI: false,
      playAsWhite: true,
      board: [],
      player: null,
      moves: [],
      selected: null,
      movesFromSelected: [],
    };

    this.clickHandler = this.clickHandler.bind(this);
    this.piece        = this.piece.bind(this);
    this.filterMoves  = this.filterMoves.bind(this);
    this.startGame    = this.startGame.bind(this);
    this.startAIGame    = this.startAIGame.bind(this);
  }

  componentDidMount(event) {
    fetch('http://localhost:3000/games/')
    .then(function(response) { return response.json() })
    .then((response) => {
      this.setState({ openGames: response });
    })
    .catch(console.error);
  }

  startGame() {
    fetch('http://localhost:3000/games/', {
      method: 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        black_id: 1,
        white_id: 2,
      })
    })
    .then(function(response) { return response.json(); })
    .then((response) => {
      this.setState({ game: response.game, board: response.board, player: response.player, moves: response.moves, playAsWhite: true });
    })
    .then(() => {
      const cable = ActionCable.createConsumer("ws://localhost:3000/cable");
      const channel = cable.subscriptions.create({channel: "GameChannel", id: this.state.game}, {
        connected: () => {
          console.log(`Connecting to Game ${this.state.game}`);
        },
        disconnected: () => {
          console.log(`Disconnecting from Game ${this.state.game}`);
        },
        received: (data) => {
          this.setState({ board: data.board, player: data.player, moves: data.moves, selected: null, movesFromSelected: [] });
        },
      });
    })
    .catch(console.error);
  }

  joinGame(id) {
    return (event) => {
      event.preventDefault();
      const cable = ActionCable.createConsumer("ws://localhost:3000/cable");
      const channel = cable.subscriptions.create({channel: "GameChannel", id: id}, {
        connected: function() {
          console.log(`Connecting to Game ${id}`)
        },
        disconnected: function() {
          console.log(`Disconnecting from Game ${id}`);
        },
        received: (data) => {
          this.setState({ board: data.board, player: data.player, moves: data.moves, selected: null, movesFromSelected: [] });
        },
      });
      fetch(`http://localhost:3000/games/${id}/`)
      .then(function(response) { return response.json(); })
      .then((response) => {
        this.setState({ game: id, board: response.board, player: response.player, moves: response.moves, playAsWhite: false });
      })
      .catch(console.error);
    }
  }

  startAIGame() {
    fetch('http://localhost:3000/games/', {
      method: 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        black_id: 1,
        white_id: 2,
      })
    })
    .then(function(response) { return response.json(); })
    .then((response) => {
      this.setState({ game: response.game, board: response.board, player: response.player, moves: response.moves, playAsWhite: true, AI: true });
    })
    .then(() => {
      const cable = ActionCable.createConsumer("ws://localhost:3000/cable");
      const channel = cable.subscriptions.create({channel: "GameChannel", id: this.state.game}, {
        connected: () => {
          console.log(`Connecting to Game ${this.state.game}`);
        },
        disconnected: () => {
          console.log(`Disconnecting from Game ${this.state.game}`);
        },
        received: (data) => {
          this.setState({ board: data.board, player: data.player, moves: data.moves, selected: null, movesFromSelected: [] });
        },
      });
    })
    .catch(console.error);
  }

  clickHandler(event) {
    if (this.state.playAsWhite && this.state.player === 'B') return;
    if (!this.state.playAsWhite && this.state.player === 'W') return;

    const selection = event.currentTarget.id;
    const piece = this.piece(selection);
    const owner = this.owner(piece);
    if (owner === this.state.player) {
      if (this.state.selected === selection) {
        this.setState({ selected: null, movesFromSelected: [] });
      } else {
        this.setState({ selected: selection });
        this.filterMoves(selection);
      }
    }

    if (this.state.selected && this.state.movesFromSelected.includes(selection)) {
      let decision = '';
      for (let move of this.state.moves) {
        if (move.substring(0, 4) === (this.state.selected + selection)) {
          decision = move;
        }
      }

      let url = `http://localhost:3000/games/${this.state.game}/moves`;
      if (this.state.AI) url += '/ai';

      fetch(url, {
        method: 'POST',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          move: decision,
        })
      });

    }
  }


  piece(id) {
    return this.state.board[parseInt(id[0], 10)][parseInt(id[1], 10)];
  }

  owner(piece) {
    return piece.toUpperCase();
  }

  filterMoves(origin) {
    const movesFromOrigin = this.state.moves
      .filter((move) => {
        return origin === move.substring(0, 2);
      })
      .map(function(move) {
        return move.substring(2, 4);
      });
    this.setState({ movesFromSelected: movesFromOrigin });
  }


  render() {
    const styles = {
    };

    if (this.state.game) {
      return (
        <div style={styles}>
          <h1>GAME</h1>
          <Board board={this.state.board} selected={this.state.selected} moves={this.state.movesFromSelected} onClick={this.clickHandler}/>
        </div>
      );
    } else {
      return (
        <div>
          <h1>Start a new game or join an existing game!</h1>
          <button onClick={this.startGame}>Start your own game</button>
          <button onClick={this.startAIGame}>Play against an AI</button>
          <h3>Open Games</h3>
          <ul>
            {this.state.openGames.map((game) => {
              return (<li key={game}><a href='#' onClick={this.joinGame(game)}>Game{game}</a></li>);
            })}
          </ul>
        </div>
      )
    }
  }
}
