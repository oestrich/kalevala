import React from "react";

export default class Sidebar extends React.Component {
  render() {
    return (
      <div className="bg-gray-900 text-gray-500 border-r-2 border-blue-200 w-64">
        {this.props.children}
      </div>
    );
  }
}
