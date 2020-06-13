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

  switch (event.topic) {
    case "system/display":
      const lastTags = state.tags[state.tags.length - 1];

      let { data } = event;

      if (lastTags && typeof lastTags == 'object' && lastTags.name == "sent-text") {
        if (data instanceof Array) {
          let first = data.shift();

          if (first.startsWith("\n")) {
            first = first.replace(/\n/, "");
          }

          data = [first, ...data];
        } else if (typeof data == "string") {
          if (first.startsWith("\n")) {
            data = data.replace(/\n/, "");
          }
        };
      }

      return {...state, tags: state.tags.concat(data)};

    case "system/pong":
      console.log("Pong");

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

      return {...state, tags: state.tags.concat([tag])};

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
