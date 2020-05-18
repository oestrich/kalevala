import { combineReducers, compose, createStore } from "redux";

import { Creators, kalevalaMiddleware, promptReducer, socketReducer } from "./kalevala";

import { eventsReducer } from "./redux";

const composeEnhancers =
  typeof window === "object" && window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ ?
  window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__({}) : compose;

const eventTextHandlers = {
  "Login.Welcome": (dispatch, getState, event, { history }) => {
    history.push("/login");
  },
  "Login.PromptCharacter": (dispatch, getState, event, { history }) => {
    history.push("/login/character");
  },
  "Login.EnterWorld": (dispatch, getState, event, { history }) => {
    const { text } = event;
    dispatch(Creators.socketReceivedEvent({ topic: "system/display", data: text }, { history }));

    history.push("/client");
  },
};

const systemEventHandlers = {
  "system/event-text": (dispatch, getState, event, args) => {
    const { topic, data, text } = event.data;

    let handler = eventTextHandlers[topic];

    if (handler) {
      handler(dispatch, getState, event.data, args);
    }

    dispatch(Creators.socketReceivedEvent({ topic, data }, args));
  },
};

const middleware = compose(kalevalaMiddleware(systemEventHandlers), composeEnhancers());

const reducers = combineReducers({
  prompt: promptReducer,
  socket: socketReducer,
  events: eventsReducer
});

export const makeStore = () => {
  return createStore(reducers, middleware);
}
