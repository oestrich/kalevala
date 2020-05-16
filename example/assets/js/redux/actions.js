import {createActions} from 'reduxsauce';

export const { Types, Creators } = createActions({
  promptClear: null,
  promptHistoryAdd: null,
  promptHistoryScrollBackward: null,
  promptHistoryScrollForward: null,
  promptSetCurrentText: ["text"],
  socketConnected: null,
  socketDisconnected: null,
  socketReceivedEvent: ["event"],
  socketSentEvent: ["event"],
});
