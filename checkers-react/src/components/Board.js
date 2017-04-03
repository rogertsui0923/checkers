import React from 'react';

function King(props) {
  const styles = {
    width: '60%',
    height: '60%',
    backgroundColor: 'Orange',
    borderRadius: '50%',
  };

  return (
    <div style={styles}>
    </div>
  )
}

function Piece(props) {
  const {piece, selected} = props;

  let color = '';
  if (piece.toUpperCase() === 'W') color = 'WhiteSmoke';
  if (piece.toUpperCase() === 'B') color = 'SlateGray';

  const styles = {
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    width: '80%',
    height: '80%',
    backgroundColor: color,
    borderRadius: '50%',
    border: selected ? '5px solid black' : '',
  };



  const is_king = (piece === 'W' || piece === 'B');
  if (is_king) return <div style={styles}><King/></div>;
  return <div style={styles}></div>;
}

function Square(props) {
  const {piece, id, odd, selected, moves, onClick} = props;

  const styles = {
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    height: '100%',
    width: '12.5%',
    backgroundColor: odd ? 'BurlyWood' : 'SaddleBrown',
    boxSizing: 'border-box',
    border: (moves.includes(id)) ? '5px solid blue' : '',
  };

  return (
    <div style={styles} id={id} onClick={onClick}>
      <Piece piece={piece} selected={selected === id}/>
    </div>
  )
}

function Row(props) {
  let {row, id, odd, selected, moves, onClick} = props;

  const styles = {
    display: 'flex',
    height: '12.5%',
    width: '100%',
  };

  function generateSquare(piece, i) {
    const component = <Square piece={piece} id={`${id}${i}`} odd={odd} key={i} selected={selected} moves={moves} onClick={onClick}/>;
    odd = !odd;
    return component;
  }

  return (
    <div style={styles}>
      {row.map(generateSquare)}
    </div>
  )
}


export default function Board(props) {
  let {board, selected, moves, onClick} = props;

  let odd = true;

  const styles = {
    width: '80vh',
    height: '80vh',
  };

  const generateRow = (row, i) => {
    const component = <Row row={row} id={i} odd={odd} selected={selected} moves={moves} onClick={onClick} key={i}/>;
    odd = !odd;
    return component;
  }

  return (
    <div className='board' style={styles}>
      {board.map(generateRow)}
    </div>
  );
}
