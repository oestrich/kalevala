import React from "react";
import { connect } from "react-redux";
import { Link } from "react-router-dom";

import { getLoginActive } from "../redux";

class Home extends React.Component {
  render() {
    const renderLogin = () => {
      if (this.props.loginActive) {
        return (<Link className="btn-primary" to="/login">Login</Link>);
      } else {
        return (<a className="btn-inactive">Login</a>);
      }
    };

    return (
      <div>
        <nav className="bg-teal-600 p-2 mt-0 fixed w-full z-10 top-0">
          <div className="container mx-auto flex flex-wrap items-center">
            <div className="flex w-full md:w-1/2 justify-center md:justify-start text-white font-extrabold">
              <Link to="/" className="text-white no-underline hover:text-white hover:no-underline">
                <span className="text-2xl pl-2">Kantele</span>
              </Link>
            </div>

            <div className="flex w-full content-center justify-between md:w-1/2 md:justify-end">
              <ul className="list-reset flex justify-between flex-1 md:flex-none items-center">
                <li className="mr-3">{renderLogin()}</li>
              </ul>
            </div>
          </div>
        </nav>

        <div className="container mx-auto mt-24 md:mt-16 h-screen">
          <div className="bg-gray-200 p-8 rounded">
            <p className="text-4xl">Kantele is a text multiplayer adventure game.</p>
            <p>This is the sample game for <a className="underline text-gray-700" href="https://github.com/oestrich/kalevala" target="_blank">Kalevala</a>, a world building toolkit written in Elixir.</p>
          </div>
        </div>
      </div>
    );
  }
}

const mapStateToProps = (state) => {
  const loginActive = getLoginActive(state);
  return { loginActive };
};

export default Home = connect(mapStateToProps)(Home);
