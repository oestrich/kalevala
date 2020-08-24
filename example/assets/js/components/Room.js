import React from "react";
import { connect } from 'react-redux';
import { Tooltip } from "../kalevala";

import { Creators, getEventsRoom } from "../redux";

const exitTooltip = ({ active, direction }) => {
  if (active) {
    return `Move ${direction}`;
  } else {
    return null;
  }
}

const Exit = ({ active, className, direction, move }) => {
  const activeClassName = active ? "bg-teal-600 cursor-pointer" : "bg-gray-700 border border-teal-800 cursor-not-allowed";
  const fullClassName = `${className} ${activeClassName} text-white font-bold py-2 text-center rounded`;

  return (
    <Tooltip tip={exitTooltip({ active, direction })} className={fullClassName}>
      <div onClick={move}>
        {direction}
      </div>
    </Tooltip>
  );
};

class Exits extends React.Component {
  render() {
    const { exits } = this.props;

    return (
      <div className="grid grid-cols-3 gap-1 text-sm w-64 h-32 items-center">
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

const Character = ({ description, name }) => {
  return (
    <div className="mr-2 bg-gray-800 border border-teal-800 rounded p-2" style={{color: "#cfad00"}}>
      <Tooltip tip={description}>
        {name}
      </Tooltip>
    </div>
  );
};

const Characters = ({ characters }) => {
  return (
    <div className="flex">
      {characters.map((character) => {
        return (
          <Character key={character.id} description={character.description} name={character.name} />
        );
      })}
    </div>
  );
}

let trimTags = (line) => {
  if (line instanceof Array) {
    return line.map(trimTags);
  }

  return line.replace(/{.*}/g, "");
};

let Room = ({ room }) => {
  if (!room) {
    return null;
  }

  let { characters, description, exits, name } = room;

  description = trimTags(description);

  return (
    <div className="flex m-4">
      <div className="w-full mr-4">
        <div className="p-4 bg-gray-800 text-gray-200 border border-teal-800 rounded">
          <div className="text-xl">{name}</div>
          <div>{description}</div>
        </div>
        <div className="pt-2">
          <Characters characters={characters} />
        </div>
      </div>
      <Exits exits={exits} />
    </div>
  );
}

let mapStateToProps = (state) => {
  const room = getEventsRoom(state);

  return { room };
};

export default Room = connect(mapStateToProps)(Room);
