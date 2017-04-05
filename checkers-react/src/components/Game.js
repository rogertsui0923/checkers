import React, { Component } from 'react';
import { ActionCable } from 'actioncable-js';
import Board from './Board';
import Background from '../images/checkers.jpg'

const URL = 'http://localhost:3000/games/';
const HEADERS = {
  'Accept': 'application/json',
  'Content-Type': 'application/json',
};
const parse = function(n) { return parseInt(n, 10); }

export default class Game extends Component {
  constructor(props) {
    super(props);

    this.state = {
      openGames: [],

      game: null,
      isWhite: true,

      AI: false,

      board: [],
      player: null,
      moves: [],

      selected: null,
      filteredMoves: [],
    };

    this.filterMoves  = this.filterMoves.bind(this);
    this.updateState  = this.updateState.bind(this);
    this.games        = this.games.bind(this);
    this.start        = this.start.bind(this);
    this.startAI      = this.startAI.bind(this);
    this.clickHandler = this.clickHandler.bind(this);
    this.sendMove     = this.sendMove.bind(this);
  }

  games(event) {
    fetch(URL)
      .then(function(response) { return response.json() })
      .then((response) => { this.setState({ openGames: response }); })
      .catch(console.error);
  }

  /**
   * updateState updates the board, player, moves of this.state given a response
   * from the backend.
   */
  updateState(response) {
    this.setState({
      board: response.board,
      player: response.player,
      moves: response.moves,
    });
  }

  /**
   * initializeState updates the board, player, moves, game of this.state given
   * a response from the backend.
   * It also sets isWhite of this.state. Players who create a new game play as
   * white; players who join an existing game play as black.
   * Players play as white against an AI.
   */
  initializeState(response, isWhite) {
    this.updateState(response);
    this.setState({ game: response.game, isWhite: isWhite });
  }

  setupWebSocket(id) {
    const cable = ActionCable.createConsumer("ws://localhost:3000/cable");
    cable.subscriptions.create({channel: "GameChannel", id: id}, {
      connected: () => { alert(`Connecting to Game #${id}`); },
      disconnected: () => { alert(`Disconnecting from Game #${id}`); },
      received: (data) => {
        this.updateState(data);
        this.setState({ selected: null, filteredMoves: [] });
      },
    });
  }

  start() {
    fetch(URL, {
      method: 'POST',
      headers: HEADERS,
      body: JSON.stringify({ black_id: 1, white_id: 2 }),
    })
      .then(function(response) { return response.json(); })
      .then((response) => { this.initializeState(response, true) })
      .then(() => { this.setupWebSocket(this.state.game); })
      .catch(console.error);
  }

  join(id) {
    return (event) => {
      event.preventDefault();
      fetch(URL + `${id}/`)
        .then(function(response) { return response.json(); })
        .then((response) => { this.initializeState(response, false) })
        .catch(console.error);
      this.setupWebSocket(id);
    }
  }

  startAI() {
    this.start();
    this.setState({ AI: true });
  }

  clickHandler(event) {
    const s = this.state;
    if ((s.isWhite ? 'W' : 'B') !== s.player) return;

    const id = event.currentTarget.id;

    // Clicking on your own piece
    const owner = s.board[parse(id[0])][parse(id[1])].toUpperCase();
    if (owner === s.player) {
      if (s.selected === id) {
        this.setState({ selected: null, filteredMoves: [] });
      } else {
        this.setState({ selected: id });
        this.filterMoves(id);
      }
    }

    // Performing a valid move
    if (s.selected && s.filteredMoves.includes(id)) {
      const move = s.moves.filter(function(move) {
        return move.substring(0, 4) === (s.selected + id);
      })[0];
      this.sendMove(move);
    }
  }

  filterMoves(origin) {
    const moves = this.state.moves
      .filter(function(move) { return origin === move.substring(0, 2); })
      .map(function(move) { return move.substring(2, 4); });
    this.setState({ filteredMoves: moves });
  }

  sendMove(move) {
    let url = URL + `${this.state.game}/moves`;
    if (this.state.AI) url += '/ai';

    fetch(url, {
      method: 'POST',
      headers: HEADERS,
      body: JSON.stringify({ move: move }),
    });
  }

  render() {
    const page = {
      backgroundImage: `url(${Background})`,
      display: 'flex',
      justifyContent: 'center',
      alignItems: 'center',
      flexDirection: 'column',
      height: '100vh'
    };

    const title = {
      fontSize: '100px',
      color: 'white'
    };

    const btnContainer = {
      width: '30em',
      display: 'flex',
      justifyContent: 'space-between',
      alignItems: 'center',
    };

    const btn = {
      width: '7em',
      height: '80px',
      borderRadius: '10px',
      fontSize: '20px',
      backgroundColor: 'black',
      color: 'white',
    };

    const gameList = {

    }

    const gamePage = {
      backgroundColor: 'black',
      display: 'flex',
      height: '100vh',
      justifyContent: 'center',
      alignItems: 'center',
    }

    if (this.state.game) return (
      <div style={gamePage}>
        <Board isWhite={this.state.isWhite}
               board={this.state.board}
               selected={this.state.selected}
               moves={this.state.filteredMoves}
               onClick={this.clickHandler}/>
      </div>
    );

    if (this.state.openGames.length > 0) return (
      <div style={gameList}>
        <h3>Open Games</h3>
        <ul>
          {this.state.openGames.map((game) => {
            return (
              <li key={game}><a href='#' onClick={this.join(game)}>
                Game #{game}
              </a></li>
            );
          })}
        </ul>
      </div>
    );

    return (
      <div style={page}>
        <h1 style={title}>Checkrs</h1>
        <div style={btnContainer}>
          <button onClick={this.start} style={btn}>Start new game</button>
          <button onClick={this.games} style={btn}>Join existing game</button>
          <button onClick={this.startAI} style={btn}>Play against an AI</button>
        </div>
      </div>
    )
  }
}
