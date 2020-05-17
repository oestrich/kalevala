import { combineReducers, compose, createStore } from 'redux';

import { kalevalaMiddleware, promptReducer, socketReducer } from "./kalevala";

import { eventsReducer } from "./redux";

const composeEnhancers =
  typeof window === 'object' && window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ ?
  window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__({}) : compose;

const middleware = compose(kalevalaMiddleware, composeEnhancers());

const reducers = combineReducers({
  prompt: promptReducer,
  socket: socketReducer,
  events: eventsReducer
});

export const makeStore = () => {
  return createStore(reducers, middleware);
}
