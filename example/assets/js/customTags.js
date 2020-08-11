import React from "react";
import { Tooltip } from "./kalevala";
import { Tags } from  "./kalevala/components/Terminal";

export const tooltipTag = (tag) => {
  return (
    <Tooltip text={tag.attributes.description}>
      <Tags children={tag.children} customTags={customTags} />
    </Tooltip>
  );
};

export const customTags = {
};
