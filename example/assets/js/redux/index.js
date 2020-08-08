import { Creators } from "./actions";
import { channelReducer } from "./channelReducer";
import { eventsReducer } from "./eventsReducer";
import { loginReducer } from "./loginReducer";

export const getChannel = (state) => {
  return state.channel;
};

export const getChannelMessages = (state) => {
  return getChannel(state).messages;
};

export const getEvents = (state) => {
  return state.events;
};

export const getEventsInventory = (state) => {
  return getEvents(state).inventory;
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

export const getLoginStatus = (state) => {
  return getLogin(state).loggedIn;
};

export {
  Creators,
  channelReducer,
  eventsReducer,
  loginReducer
};
