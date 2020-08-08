import { createReducer, Types as KalevalaTypes } from "../kalevala";

import { Types } from "./actions";

const INITIAL_STATE = {
  inventory: [],
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
    case "Inventory.All":
      const { item_instances } = event.data;
      return {...state, inventory: item_instances};

    case "Inventory.Drop":
      return dropItem(state, event);

    case "Inventory.PickupItem":
      return pickupItem(state, event);

    case "Room.Info":
      return {...state, room: event.data};

    default:
      return state;
  }
};

const dropItem = (state, event) => {
  const { item_instance } = event.data;
  console.log(item_instance);
  return state;
};

const pickupItem = (state, event) => {
  const { item_instance } = event.data;
  console.log({...state, inventory: [item_instance, ...state.inventory]});
  return {...state, inventory: [item_instance, ...state.inventory]};
};

const HANDLERS = {
  [KalevalaTypes.SOCKET_RECEIVED_EVENT]: eventReceived,
  [Types.ROOM_CHARACTER_ENTERED]: characterEntered,
  [Types.ROOM_CHARACTER_LEFT]: characterLeft,
};

export const eventsReducer = createReducer(INITIAL_STATE, HANDLERS);
