import React from 'react';
import {connect} from 'react-redux';
import PropTypes from 'prop-types';

import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faCircle } from '@fortawesome/free-solid-svg-icons'

import {getSocketConnectionState} from "../redux/store";

class ConnectionStatus extends React.Component {
  connectionClassName() {
    if (this.props.connected) {
      return "text-green-500";
    } else {
      return "text-red-500";
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
        <FontAwesomeIcon icon={faCircle} title={this.connectionTitle()} className={this.connectionClassName()} />
      </div>
    );
  }
}

ConnectionStatus.contextTypes = {
  socket: PropTypes.object,
};

let mapStateToProps = (state) => {
  const connected = getSocketConnectionState(state);
  return {connected};
};

export default ConnectionStatus = connect(mapStateToProps)(ConnectionStatus);
