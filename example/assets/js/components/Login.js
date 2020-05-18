import React from "react";
import { connect } from "react-redux";

import { Creators } from "../redux";

class Login extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      username: "",
      password: ""
    };
  }

  render() {
    const submitLogin = () => {
      this.props.login(this.state.username, this.state.password);
    };

    const loginClick = (e) => {
      e.preventDefault();
      submitLogin();
    };

    const onKeyDown = (e) => {
      if (e.key === "Enter") {
        e.preventDefault();
        submitLogin();
      };
    };

    return (
      <div className="h-full bg-white rounded-t-lg overflow-hidden border-t border-l border-r border-gray-400 p-4 px-3 py-10 bg-gray-200 flex justify-center">
        <div className="w-full max-w-xs">
          <h1 className="text-6xl text-center">Kantele</h1>

          <form className="bg-white shadow-md rounded px-8 pt-6 pb-8 mb-4">
            <div className="mb-4">
              <input
                autoFocus={true}
                className="input"
                id="username"
                type="text"
                placeholder="Username"
                value={this.state.username}
                onKeyDown={onKeyDown}
                onChange={(e) => { this.setState({ username: e.target.value }) }}/>
            </div>

            <div className="mb-4">
              <input
                className="input"
                id="password"
                type="password"
                placeholder="Password"
                value={this.state.password}
                onKeyDown={onKeyDown}
                onChange={(e) => { this.setState({password: e.target.value}); }}/>
            </div>

            <div className="mb-4">
              <input type="button" className="btn-primary" value="Login" onClick={loginClick} />
            </div>
          </form>
        </div>
      </div>
    );
  }
}

export default Login = connect(null, {
  login: Creators.login
})(Login);
