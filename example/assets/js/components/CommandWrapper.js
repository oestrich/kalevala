import React from "react";
import { connect } from 'react-redux';

import { Creators, Tooltip } from "../kalevala";

let CommandWrapper = ({ children, dispatch, send }) => {
  const onClick = (e) => {
    dispatch(Creators.socketSendEvent({
      topic: "system/send",
      data: {
        text: send
      }
    }));
  };

  return (
    <Tooltip text={`Send "${send}"`}>
      <span className="underline cursor-pointer" onClick={onClick}>
        {children}
      </span>
    </Tooltip>
  );
};

CommandWrapper = connect()(CommandWrapper);
export default CommandWrapper;
