import React from 'react';
import { Provider } from 'react-redux';

import { Prompt, SocketProvider, Terminal } from "./kalevala/components";

import { makeStore } from "./store.js";

let body = document.getElementById("body");


let store = makeStore();

class Client extends React.Component {
  render() {
    return (
      <Provider store={store}>
        <SocketProvider>
          <div className="flex h-full flex-col">
            <Terminal />
            <Prompt />
          </div>
        </SocketProvider>
      </Provider>
    );
  }
}

export {Client}
