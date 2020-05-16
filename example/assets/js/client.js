import React from 'react';
import { Provider } from 'react-redux';
import { compose, createStore } from 'redux';

import { Creators } from "./redux/actions";
import { kalevalaReducer } from "./redux";

import { Prompt, SocketProvider, Terminal } from "./components";

let body = document.getElementById("body");

const makeStore = () => {
  const composeEnhancers =
    typeof window === 'object' && window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ ?
      window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__({}) : compose;

  const enhancer = composeEnhancers();

  return createStore(kalevalaReducer, enhancer);
}

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
