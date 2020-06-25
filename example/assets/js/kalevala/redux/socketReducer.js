import { Types } from "./actions";
import { createReducer } from "./createReducer";
import parseText from "../parseText";

const MAX_LINES = 500;

const INITIAL_STATE = {
  socket: null,
  connected: false,
  lines: [],
}

export const socketConnected = (state, action) => {
  const { socket } = action.data;

  return {...state, socket: socket, connected: true};
};

export const socketDisconnected = (state, action) => {
  if (!state.connected) {
    return state;
  }

  return {...state, socket: null, connected: false};
};

export const socketReceivedEvent = (state, action) => {
  const { event } = action.data;

  switch (event.topic) {
    case "system/display":
      let lines = parseText(event.data);
      lines = state.lines.concat(lines);
      return {...state, lines: lines.slice(Math.max(0, lines.length - MAX_LINES))};

    case "system/pong":
      return state;

    default:
      return state;
  }
};

export const socketSendEvent = (state, action) => {
  const { event } = action.data;

  switch (event.topic) {
    case "system/send":
      const { text } = event.data;

      const tag = {
        name: "sent-text",
        children: [text, "\n"],
      };

      let lines = parseText(tag);

      return {...state, lines: state.lines.concat(lines)};

    default:
      return state;
  };
};

export const HANDLERS = {
  [Types.SOCKET_CONNECTED]: socketConnected,
  [Types.SOCKET_DISCONNECTED]: socketDisconnected,
  [Types.SOCKET_RECEIVED_EVENT]: socketReceivedEvent,
  [Types.SOCKET_SEND_EVENT]: socketSendEvent,
}

export const socketReducer = createReducer(INITIAL_STATE, HANDLERS);
