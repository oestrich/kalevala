import _ from "underscore";
import { createReducer } from "reduxsauce";

import {Types} from "./actions";

const INITITAL_STATE = {
  index: -1,
  history: [],
  currentText: "",
  displayText: "",
}

export const promptClear = (state, action) => {
  return {...state, index: -1, currentText: "", displayText: ""};
};

export const promptSetCurrentText = (state, action) => {
  const {text} = action;
  return {...state, index: -1, currentText: text, displayText: text};
}

export const promptHistoryAdd = (state, action) => {
  if (_.first(state.history) == state.displayText) {
    return {...state, index: -1};
  } else {
    let history = [state.displayText, ...state.history];
    history = _.first(history, 10);
    return {...state, history: history};
  }
}

export const promptHistoryScrollBackward = (state, action) => {
  let index = state.index + 1;

  if (state.history[index] != undefined) {
    return {...state, index: index, displayText: state.history[index]};
  }

  return state;
}

export const promptHistoryScrollForward = (state, action) => {
  let index = state.index - 1;

  if (index == -1) {
    return {...state, index: 0, displayText: state.currentText};
  } else if (state.history[index] != undefined) {
    return {...state, index: index, displayText: state.history[index]};
  }

  return state;
}

export const HANDLERS = {
  [Types.PROMPT_CLEAR]: promptClear,
  [Types.PROMPT_HISTORY_ADD]: promptHistoryAdd,
  [Types.PROMPT_HISTORY_SCROLL_BACKWARD]: promptHistoryScrollBackward,
  [Types.PROMPT_HISTORY_SCROLL_FORWARD]: promptHistoryScrollForward,
  [Types.PROMPT_SET_CURRENT_TEXT]: promptSetCurrentText,
}

export const promptReducer = createReducer(INITITAL_STATE, HANDLERS);
