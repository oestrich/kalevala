import { Creators } from "./actions";
import { eventsReducer } from "./eventsReducer";

export const getEvents = (state) => {
  return state.events;
};

export const getEventsRoom = (state) => {
  return getEvents(state).room;
};

export {
  Creators,
  eventsReducer
};
