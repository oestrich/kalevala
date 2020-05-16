export const Types = {
  PROMPT_CLEAR: "PROMPT_CLEAR",
  PROMPT_HISTORY_ADD: "PROMPT_HISTORY_ADD",
  PROMPT_HISTORY_SCROLL_BACKWARD: "PROMPT_HISTORY_SCROLL_BACKWARD",
  PROMPT_HISTORY_SCROLL_FORWARD: "PROMPT_HISTORY_SCROLL_FORWARD",
  PROMPT_SET_CURRENT_TEXT: "PROMPT_SET_CURRENT_TEXT",
  SOCKET_CONNECTED: "SOCKET_CONNECTED",
  SOCKET_DISCONNECTED: "SOCKET_DISCONNECTED",
  SOCKET_RECEIVED_EVENT: "SOCKET_RECEIVED_EVENT",
  SOCKET_SENT_EVENT: "SOCKET_SENT_EVENT",
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
  socketConnected: () => {
    return { type: Types.SOCKET_CONNECTED };
  },
  socketDisconnected: () => {
    return { type: Types.SOCKET_DISCONNECTED };
  },
  socketReceivedEvent: (event) => {
    return { type: Types.SOCKET_RECEIVED_EVENT, data: { event } };
  },
  socketSentEvent: (event) => {
    return { type: Types.SOCKET_SENT_EVENT, data: { event } };
  },
};
