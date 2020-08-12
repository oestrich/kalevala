import React from 'react';

export default class Tooltip extends React.Component {
  render() {
    if (this.props.text === null) {
      return (
        <span className={`inline-block ${this.props.className}`}>
          {this.props.children}
        </span>
      );
    }

    return (
      <span className={`tooltip-hover inline-block ${this.props.className}`}>
        {this.props.children}
        <div className="tooltip">{this.props.text}</div>
      </span>
    );
  }
}
