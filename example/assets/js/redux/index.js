import { Creators } from "./actions";
import { eventsReducer } from "./eventsReducer";
import { loginReducer } from "./loginReducer";

export const getEvents = (state) => {
  return state.events;
};

export const getEventsRoom = (state) => {
  return getEvents(state).room;
};

export const getLogin = (state) => {
  return state.login;
};

export const getLoginActive = (state) => {
  return getLogin(state).active;
};

export {
  Creators,
  eventsReducer,
  loginReducer
};
