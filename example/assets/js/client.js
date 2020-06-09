import React, { Fragment } from "react";
import { connect, Provider } from "react-redux";
import {
  BrowserRouter as Router,
  Route,
  Redirect,
  Switch,
  withRouter
} from "react-router-dom";

import { Keys, makeReduxSocket, Prompt, Terminal } from "./kalevala";

import { CharacterSelect, Home, Login, Room, Sidebar } from "./components";
import { Creators, getLoginStatus } from "./redux";
import { makeStore } from "./store";

const keys = new Keys();

document.addEventListener("keydown", e => {
  if (!keys.isModifierKeyPressed()) {
    let textPrompt = document.getElementById("prompt");

    if (textPrompt) {
      textPrompt.focus();
    }
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

class SocketProvider extends React.Component {
  constructor(props) {
    super(props);

    const { history } = props;

    this.socket = makeReduxSocket("/socket", store, { history });
    this.socket.join();
  }

  render() {
    return (
      <Fragment>{this.props.children}</Fragment>
    );
  }
}

SocketProvider = withRouter(SocketProvider);

class ValidateLoggedIn extends React.Component {
  render() {
    if (this.props.loggedIn) {
      return null;
    } else {
      return (
        <Redirect to="/" />
      );
    }
  }
}

const mapStateToProps = (state) => {
  const loggedIn = getLoginStatus(state);
  return { loggedIn };
};

ValidateLoggedIn = connect(mapStateToProps)(ValidateLoggedIn);

export class Client extends React.Component {
  render() {
    return (
      <Provider store={store}>
        <Router>
          <SocketProvider>
            <Switch>
              <Route path="/login/character">
                <CharacterSelect />
              </Route>
              <Route path="/login">
                <Login />
              </Route>
              <Route path="/client">
                <ValidateLoggedIn />
                <div className="flex flex-row h-full">
                  <Sidebar>
                    <Room />
                  </Sidebar>
                  <div className="flex flex-col flex-grow overflow-y-scroll">
                    <Terminal />
                    <Prompt />
                  </div>
                </div>
              </Route>
              <Route>
                <Home />
              </Route>
            </Switch>
          </SocketProvider>
        </Router>
      </Provider>
    );
  }
}
