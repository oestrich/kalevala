import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';

import { getSocketConnectionState } from "../redux";

class ConnectionStatus extends React.Component {
  connectionClassName() {
    if (this.props.connected) {
      return "bg-green-500";
    } else {
      return "bg-red-500";
    }
  }

  connectionTitle() {
    if (this.props.connected) {
      return "Connected";
    } else {
      return "Disconnected";
    }
  }

  render() {
    return (
      <div className="flex items-center justify-center">
        <div
          style={{borderRadius: "100%", width: "16px", height: "16px"}}
          title={this.connectionTitle()}
          className={this.connectionClassName()} />
      </div>
    );
  }
}

ConnectionStatus.contextTypes = {
  socket: PropTypes.object,
};

let mapStateToProps = (state) => {
  const connected = getSocketConnectionState(state);
  return { connected };
};

export default ConnectionStatus = connect(mapStateToProps)(ConnectionStatus);
