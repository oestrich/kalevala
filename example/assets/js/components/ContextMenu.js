import React from "react";

import { Creators } from "../kalevala";

import Icon from "./Icon";

const verbIcons = {
  drop: () => <Icon icon="card-discard.svg" />,
  grab: () => <Icon icon="card-play.svg" />,
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
