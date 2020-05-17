import React from 'react';
import { Provider } from 'react-redux';

import { Keys, makeReduxSocket, Prompt, Terminal } from "./kalevala";

import { Room, Sidebar } from "./components";
import { Creators } from "./redux";
import { makeStore } from "./store";

const keys = new Keys();

document.addEventListener('keydown', e => {
  if (!keys.isModifierKeyPressed()) {
    document.getElementById('prompt').focus();
  }
});

let body = document.getElementById("body");

let store = makeStore();

keys.on(["Alt", "ArrowUp"], (e) => {
  e.preventDefault();
  store.dispatch(Creators.moveNorth());
});

keys.on(["Alt", "ArrowDown"], (e) => {
  e.preventDefault();
  store.dispatch(Creators.moveSouth());
});

keys.on(["Alt", "ArrowLeft"], (e) => {
  e.preventDefault();
  store.dispatch(Creators.moveWest());
});

keys.on(["Alt", "ArrowRight"], (e) => {
  e.preventDefault();
  store.dispatch(Creators.moveEast());
});

let reduxSocket = makeReduxSocket("/socket", store);
reduxSocket.join();

export class Client extends React.Component {
  render() {
    return (
      <Provider store={store}>
        <div className="flex flex-row h-full">
          <Sidebar>
            <Room />
          </Sidebar>
          <div className="flex flex-col flex-grow overflow-y-scroll">
            <Terminal />
            <Prompt />
          </div>
        </div>
      </Provider>
    );
  }
}
