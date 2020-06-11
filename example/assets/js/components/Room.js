import React from "react";
import { connect } from 'react-redux';

import { Creators, getEventsRoom } from "../redux";

class Exit extends React.Component {
  render() {
    const activeClassName = this.props.active ? "bg-teal-500 cursor-pointer" : "bg-gray-500 cursor-not-allowed";
    const className = `${this.props.className} ${activeClassName} text-white font-bold py-2 px-4 m-1 text-center rounded`;

    return (
      <div className={className} onClick={this.props.move}>
        {this.props.direction}
      </div>
    );
  }
}

class Exits extends React.Component {
  render() {
    const { exits } = this.props;

    return (
      <div className="grid grid-cols-3">
        <Exit
          className="col-start-1"
          direction="up"
          move={this.props.moveUp}
          active={exits.includes("up")} />

        <Exit
          className="col-start-2"
          direction="north"
          move={this.props.moveNorth}
          active={exits.includes("north")} />

        <Exit
          className="col-start-1"
          direction="west"
          move={this.props.moveWest}
          active={exits.includes("west")} />

        <Exit
          className="col-start-3"
          direction="east"
          move={this.props.moveEast}
          active={exits.includes("east")} />

        <Exit
          className="col-start-1"
          direction="down"
          move={this.props.moveDown}
          active={exits.includes("down")} />

        <Exit
          className="col-start-2"
          direction="south"
          move={this.props.moveSouth}
          active={exits.includes("south")} />
      </div>
    );
  }
}

Exits = connect(null, {
  moveNorth: Creators.moveNorth,
  moveSouth: Creators.moveSouth,
  moveWest: Creators.moveWest,
  moveEast: Creators.moveEast,
  moveUp: Creators.moveUp,
  moveDown: Creators.moveDown,
})(Exits);

const Character = ({ name }) => {
  return (
    <li style={{color: "#cfad00"}}>{name}</li>
  );
};

const Characters = ({ characters }) => {
  return (
    <ul>
      {characters.map((character) => {
        return (
          <Character key={character.id} name={character.name} />
        );
      })}
    </ul>
  );
}

let Room = ({ room }) => {
  if (!room) {
    return null;
  }

  return (
    <div>
      <div className="text-gray-300 text-xl p-4">{room.name}</div>
      <Exits exits={room.exits} />
      <Characters characters={room.characters} />
    </div>
  );
}

let mapStateToProps = (state) => {
  const room = getEventsRoom(state);

  return { room };
};

export default Room = connect(mapStateToProps)(Room);
