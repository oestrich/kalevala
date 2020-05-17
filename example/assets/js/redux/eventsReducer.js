import { createReducer, Types } from "../kalevala";

const INITIAL_STATE = {
  room: null
};

const eventReceived = (state, action) => {
  const { event } = action.data;

  switch (event.topic) {
    case "Room.Info":
      return {...state, room: event.data};

    default:
      return state;
  }
};

const HANDLERS = {
  [Types.SOCKET_RECEIVED_EVENT]: eventReceived,
};

export const eventsReducer = createReducer(INITIAL_STATE, HANDLERS);
