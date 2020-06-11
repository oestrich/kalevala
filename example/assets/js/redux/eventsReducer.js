import { createReducer, Types as KalevalaTypes } from "../kalevala";

import { Types } from "./actions";

const INITIAL_STATE = {
  room: null
};

const characterEntered = (state, action) => {
  const { character } = action.data;

  const characters = [...state.room.characters, character];

  return { ...state, room: { ...state.room, characters } };
};

const characterLeft = (state, action) => {
  const { character } = action.data;

  const characters = state.room.characters.filter((existingCharacter) => {
    return existingCharacter.id != character.id;
  });

  return { ...state, room: { ...state.room, characters } };
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
  [KalevalaTypes.SOCKET_RECEIVED_EVENT]: eventReceived,
  [Types.ROOM_CHARACTER_ENTERED]: characterEntered,
  [Types.ROOM_CHARACTER_LEFT]: characterLeft,
};

export const eventsReducer = createReducer(INITIAL_STATE, HANDLERS);
