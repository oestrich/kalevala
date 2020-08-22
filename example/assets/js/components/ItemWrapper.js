import React from "react";
import { connect } from 'react-redux';

import { Creators } from "../kalevala";

import { ContextMenu } from "./ContextMenu";
import { getEventsContextVerbs } from "../redux";

class ItemContext extends React.Component {
  componentDidMount() {
    const { context, dispatch, id } = this.props;

    this.props.dispatch(Creators.socketGetContextVerbs(context, "item", id));
  }

  render() {
    const { verbs, dispatch } = this.props;

    if (verbs === undefined) {
      return null;
    }

    return (
      <ContextMenu verbs={verbs} dispatch={dispatch} />
    );
  }
}

const mapStateToProps = (state, ownProps) => {
  const verbs = getEventsContextVerbs(state, ownProps.context, "item", ownProps.id);

  return { verbs };
};

ItemContext = connect(mapStateToProps)(ItemContext);

export default class ItemWrapper extends React.Component {
  constructor(props) {
    super(props);

    this.showTooltip = this.showTooltip.bind(this);
    this.startHoverTimeout = this.startHoverTimeout.bind(this);

    this.state = {
      showTooltip: false,
    };
  }

  showTooltip() {
    clearTimeout(this.timer);

    if (!this.state.showTooltip) {
      this.setState({showTooltip: true});
    }
  }

  startHoverTimeout() {
    this.timer = setTimeout(() => {
      this.setState({showTooltip: false});
    }, 500);
  }

  componentDidUpdate(prevProps, prevState) {
    Object.entries(this.props).forEach(([key, val]) =>
      prevProps[key] !== val && console.log(`ItemWrapper - Prop '${key}' changed`, val)
    );

    if (this.state) {
      Object.entries(this.state).forEach(([key, val]) =>
        prevState[key] !== val && console.log(`ItemWrapper - State '${key}' changed`)
      );
    }
  }

  render() {
    const { attributes, children } = this.props;
    const { showTooltip } = this.state;

    let tooltip = null;

    if (showTooltip) {
      tooltip = (
        <div className="tooltip mt-0 py-2 px-3 font-sans opacity-100 block">
          <h3 className="text-xl">{attributes.name}</h3>
          <p>{attributes.description}</p>
          <ItemContext {...attributes} />
        </div>
      );
    }

    return (
      <div className="tooltip-hover inline-block" onMouseEnter={this.showTooltip} onMouseLeave={this.startHoverTimeout}>
        <span className="cursor-pointer">
          {this.props.children}
        </span>
        {tooltip}
      </div>
    );
  }
}
