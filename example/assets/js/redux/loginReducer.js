import { createReducer } from "../kalevala";

import { Types } from "./actions";

const INITIAL_STATE = {
  active: false
};

const loginActive = (state, action) => {
  return {...state, active: true};
};

const HANDLERS = {
  [Types.LOGIN_ACTIVE]: loginActive,
};

export const loginReducer = createReducer(INITIAL_STATE, HANDLERS);
