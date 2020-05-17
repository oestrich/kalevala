import { combineReducers, compose, createStore } from 'redux';

import { Creators, kalevalaMiddleware, promptReducer, socketReducer } from "./kalevala";

import { eventsReducer } from "./redux";

const composeEnhancers =
  typeof window === 'object' && window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ ?
  window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__({}) : compose;

const eventHandlers = {
  "system/event-text": (dispatch, getState, event) => {
    const { topic, data, text } = event.data;

    dispatch(Creators.socketReceivedEvent({ topic: "system/display", data: text }));
    dispatch(Creators.socketReceivedEvent({ topic, data }));
  },
};

const middleware = compose(kalevalaMiddleware(eventHandlers), composeEnhancers());

const reducers = combineReducers({
  prompt: promptReducer,
  socket: socketReducer,
  events: eventsReducer
});

export const makeStore = () => {
  return createStore(reducers, middleware);
}
