import React from "react";
import { connect } from 'react-redux';

import { Tooltip } from "../kalevala";

import { getEventsCharacter, getEventsVitals } from "../redux";

let Vitals = ({ character, vitals }) => {
  if (vitals == null) {
    return null;
  }

  const { endurance_points, max_endurance_points } = vitals;
  const { health_points, max_health_points } = vitals;
  const { skill_points, max_skill_points } = vitals;

  const enduranceWidth = endurance_points / max_endurance_points * 100;
  const healthWidth = health_points / max_health_points * 100;
  const skillWidth = skill_points / max_skill_points * 100;

  return (
    <div className="flex flex-col">
      <h3 className="text-xl px-4 pt-4">{character.name}</h3>
      <div className="p-2 w-full">
        <div className="relative my-2 rounded bg-gray-600">
          <Tooltip text="Health Points" className="w-full">
            <div className="bg-red-600 rounded absolute inset-0 z-0" style={{width: `${healthWidth}%`}} />
            <span className="relative z-10 block p-2 text-white text-lg text-center">{health_points} / {max_health_points} hp</span>
          </Tooltip>
        </div>
        <div className="relative my-2 rounded bg-gray-600">
          <Tooltip text="Skill Points" className="w-full">
            <div className="bg-blue-600 rounded absolute inset-0 z-0" style={{width: `${skillWidth}%`}} />
            <span className="relative z-10 block p-2 text-white text-lg text-center">{skill_points} / {max_skill_points} sp</span>
          </Tooltip>
        </div>
        <div className="relative my-2 rounded bg-gray-600">
          <Tooltip text="Endurance Points" className="w-full">
            <div className="bg-purple-600 rounded absolute inset-0 z-0" style={{width: `${enduranceWidth}%`}} />
            <span className="relative z-10 block p-2 text-white text-lg text-center">{endurance_points} / {max_endurance_points} ep</span>
          </Tooltip>
        </div>
      </div>
    </div>
  );
};

let mapStateToProps = (state) => {
  const character = getEventsCharacter(state);
  const vitals = getEventsVitals(state);
  return { character, vitals };
};

export default Vitals = connect(mapStateToProps)(Vitals);
