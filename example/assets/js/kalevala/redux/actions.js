export const Types = {
  PROMPT_CLEAR: "PROMPT_CLEAR",
  PROMPT_HISTORY_ADD: "PROMPT_HISTORY_ADD",
  PROMPT_HISTORY_SCROLL_BACKWARD: "PROMPT_HISTORY_SCROLL_BACKWARD",
  PROMPT_HISTORY_SCROLL_FORWARD: "PROMPT_HISTORY_SCROLL_FORWARD",
  PROMPT_SET_CURRENT_TEXT: "PROMPT_SET_CURRENT_TEXT",
  SOCKET_CONNECTED: "SOCKET_CONNECTED",
  SOCKET_DISCONNECTED: "SOCKET_DISCONNECTED",
  SOCKET_RECEIVED_EVENT: "SOCKET_RECEIVED_EVENT",
  SOCKET_SEND_EVENT: "SOCKET_SEND_EVENT",
};

export const Creators = {
  promptClear: () => {
    return { type: Types.PROMPT_CLEAR };
  },
  promptHistoryAdd: () => {
    return { type: Types.PROMPT_HISTORY_ADD };
  },
  promptHistoryScrollBackward: () => {
    return { type: Types.PROMPT_HISTORY_SCROLL_BACKWARD };
  },
  promptHistoryScrollForward: () => {
    return { type: Types.PROMPT_HISTORY_SCROLL_FORWARD };
  },
  promptSetCurrentText: (text) => {
    return { type: Types.PROMPT_SET_CURRENT_TEXT, data: { text } };
  },
  socketConnected: (socket) => {
    return { type: Types.SOCKET_CONNECTED, data: { socket } };
  },
  socketDisconnected: () => {
    return { type: Types.SOCKET_DISCONNECTED };
  },
  socketReceivedEvent: (event) => {
    return { type: Types.SOCKET_RECEIVED_EVENT, data: { event } };
  },
  socketSendEvent: (event) => {
    return (dispatch, getState) => {
      const { socket } = getState().socket;

      socket.send(event);

      dispatch({ type: Types.SOCKET_SEND_EVENT, data: { event } });
    };
  },
};
