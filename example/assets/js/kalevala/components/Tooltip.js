import React from 'react';

export default class Tooltip extends React.Component {
  render() {
    return (
      <span className={`tooltip-hover inline-block ${this.props.className}`}>
        {this.props.children}
        <div className="tooltip">{this.props.text}</div>
      </span>
    );
  }
}
