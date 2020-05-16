import { compose, createStore } from 'redux';

import { Creators, kalevalaReducer } from "./kalevala/redux";

const composeEnhancers =
  typeof window === 'object' && window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ ?
  window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__({}) : compose;

const enhancer = composeEnhancers();

export const makeStore = () => {
  return createStore(kalevalaReducer, enhancer);
}
