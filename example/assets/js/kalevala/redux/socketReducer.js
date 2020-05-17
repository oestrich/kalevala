import { Types } from "./actions";
import { createReducer } from "./createReducer";

const INITIAL_STATE = {
  socket: null,
  connected: false,
  tags: [],
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
}

export const socketReducer = createReducer(INITIAL_STATE, HANDLERS);
