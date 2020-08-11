import React from "react";
import { Creators, Tooltip } from "./kalevala";
import { Tags } from  "./kalevala/components/Terminal";

export const customTags = {
  "command": (tag, customTags, dispatch) => {
    const send = (e) => {
      dispatch(Creators.socketSendEvent({
        topic: "system/send",
        data: {
          text: tag.attributes.send
        }
      }));
    };

    return (
      <Tooltip text={`Send "${tag.attributes.send}"`}>
        <span className="underline cursor-pointer" onClick={send}>
          <Tags children={tag.children} customTags={customTags} />
        </span>
      </Tooltip>
    );
  },
};
