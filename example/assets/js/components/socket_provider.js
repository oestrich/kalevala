import PropTypes from 'prop-types';
import React, {Fragment} from "react";
import {connect} from 'react-redux';

import {Creators} from "../redux/actions";

import {ClientSocket} from "../socket";

class SocketProvider extends React.Component {
  constructor(props) {
    super(props);

    this.socket = new ClientSocket(this);
    this.socket.join();
  }

  connected() {
    this.props.socketConnected();
  }

  disconnected() {
    this.props.socketDisconnected();
  }

  receivedEvent(event) {
    this.props.socketReceivedEvent(event);
  }

  getChildContext() {
    return {
      socket: this.socket,
    };
  }

  render() {
    return (
      <Fragment>{this.props.children}</Fragment>
    );
  }
}

SocketProvider.childContextTypes = {
  socket: PropTypes.object,
}

export default SocketProvider = connect(null, {
  socketConnected: Creators.socketConnected,
  socketDisconnected: Creators.socketDisconnected,
  socketReceivedEvent: Creators.socketReceivedEvent,
})(SocketProvider);
