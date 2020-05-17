import { compose, createStore } from 'redux';

import { kalevalaMiddleware, kalevalaReducer } from "./kalevala";

const composeEnhancers =
  typeof window === 'object' && window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ ?
  window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__({}) : compose;

const middleware = compose(kalevalaMiddleware, composeEnhancers());

export const makeStore = () => {
  return createStore(kalevalaReducer, middleware);
}
