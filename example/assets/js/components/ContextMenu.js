import React from "react";

import { Creators } from "../kalevala";

export const Verb = ({ verb, dispatch }) => {
  const onClick = (e) => {
    dispatch(Creators.socketSendEvent({
      topic: "system/send",
      data: {
        text: verb.send
      }
    }));
  };

  return (
    <span className="inline-block bg-teal-600 cursor-pointer rounded p-2 px-4 mr-2" onClick={onClick}>
      {verb.text}
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
