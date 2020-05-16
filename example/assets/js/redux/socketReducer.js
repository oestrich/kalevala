import _ from "underscore";
import {createReducer} from "reduxsauce";

import {Types} from "./actions";

const MAX_LINES = 1000;

const INITIAL_STATE = {
  connected: false,
  tags: [],
}

export const socketConnected = (state, action) => {
  return {...state, connected: true};
};

export const socketDisconnected = (state, action) => {
  if (!state.connected) {
    return state;
  }

  return {...state, connected: false};
};

export const socketSentEvent = (state, action) => {
  console.log("Send event", action);

  return state;
};

export const socketReceivedEvent = (state, action) => {
  const {event} = action;

  switch (event.type) {
    case "system/display":
      return {...state, tags: state.tags.concat(event.data)};

    case "system/pong":
      console.log("Pong");

      return state;

    default:
      return state;
  }
};

export const HANDLERS = {
  [Types.SOCKET_CONNECTED]: socketConnected,
  [Types.SOCKET_DISCONNECTED]: socketDisconnected,
  [Types.SOCKET_RECEIVED_EVENT]: socketReceivedEvent,
  [Types.SOCKET_SENT_EVENT]: socketSentEvent,
}

export const socketReducer = createReducer(INITIAL_STATE, HANDLERS);
