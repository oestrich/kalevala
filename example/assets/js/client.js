import React from 'react';
import { Provider } from 'react-redux';

import { makeReduxSocket, Prompt, Terminal } from "./kalevala";

import { makeStore } from "./store.js";

let body = document.getElementById("body");

let store = makeStore();

let reduxSocket = makeReduxSocket("/socket", store);
reduxSocket.join();

export class Client extends React.Component {
  render() {
    return (
      <Provider store={store}>
        <div className="flex h-full flex-col">
          <Terminal />
          <Prompt />
        </div>
      </Provider>
    );
  }
}
