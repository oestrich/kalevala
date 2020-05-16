import {combineReducers, createStore, compose} from 'redux';

import {promptReducer} from "./promptReducer";
import {socketReducer} from "./socketReducer";

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
}

export const getSocketTags = (state) => {
  let socketState = getSocketState(state);

  return socketState.tags;
};

// Reducers

let rootReducer = combineReducers({
  prompt: promptReducer,
  socket: socketReducer,
});

const composeEnhancers =
  typeof window === 'object' && window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ ?
    window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__({}) : compose;

const enhancer = composeEnhancers();

export const makeStore = () => {
  return createStore(rootReducer, enhancer);
};
