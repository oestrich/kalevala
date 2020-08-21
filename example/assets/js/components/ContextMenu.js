import React from "react";

import { Creators } from "../kalevala";

export const Action = ({ action, dispatch }) => {
  const onClick = (e) => {
    dispatch(Creators.socketSendEvent({
      topic: "system/send",
      data: {
        text: action.send
      }
    }));
  };

  return (
    <span className="inline-block bg-teal-600 cursor-pointer rounded p-2 px-4 mr-2" onClick={onClick}>
      {action.text}
    </span>
  );
};

export const ContextMenu = ({ actions, dispatch }) => {
  return (
    <>
      {actions.map(action => {
        return (
          <Action key={action.send} action={action} dispatch={dispatch} />
        );
      })}
    </>
  );
}
