import React from "react";

import { Hand, Save } from "heroicons-react";

import { Creators } from "../kalevala";

const verbIcons = {
  hand: () => <Hand />,
  save: () => <Save />,
};

export const Verb = ({ verb, dispatch }) => {
  const onClick = (e) => {
    dispatch(Creators.socketSendEvent({
      topic: "system/send",
      data: {
        text: verb.send
      }
    }));
  };

  const verbIcon = verbIcons[verb.icon];

  return (
    <span className="inline-block border-b border-teal-600 cursor-pointer p-2 flex hover:bg-teal-600" onClick={onClick}>
      {verbIcon && verbIcon()} {verb.text}
    </span>
  );
};

export const ContextMenu = ({ verbs, dispatch }) => {
  return (
    <>
      {verbs.map(verb => {
        return (
          <Verb key={verb.send} verb={verb} dispatch={dispatch} />
        );
      })}
    </>
  );
}
