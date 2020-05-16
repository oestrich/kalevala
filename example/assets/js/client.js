import React from 'react';
import {Provider} from 'react-redux';
import _ from 'underscore';

import {Creators} from "./redux/actions";
import {makeStore} from "./redux/store";

import { Prompt, SocketProvider, Terminal } from "./components";

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
