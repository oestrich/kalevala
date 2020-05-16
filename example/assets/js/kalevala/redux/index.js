import { combineReducers } from 'redux';

import { Types, Creators } from "./actions";
import { promptReducer } from "./promptReducer";
import { socketReducer } from "./socketReducer";

// Selectors

export const getPromptState = (state) => {
  return state.prompt;
};

export const getPromptDisplayText = (state) => {
  return getPromptState(state).displayText;
};

export const getSocketState = (state) => {
  return state.socket;
};

export const getSocketConnectionState = (state) => {
  return getSocketState(state).connected;
};

export const getSocketTags = (state) => {
  let socketState = getSocketState(state);

  return socketState.tags;
};

// Reducers

export const kalevalaReducer = combineReducers({
  prompt: promptReducer,
  socket: socketReducer,
});

export {
  Creators,
  Types
};
