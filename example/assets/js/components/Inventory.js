import React from "react";
import { connect } from 'react-redux';
import { Tooltip } from "../kalevala";

import { getEventsInventory } from "../redux";

const Item = ({ itemInstance }) => {
  return (
    <div className="m-2 block bg-gray-800 border border-teal-800 rounded p-4 relative">
      <Tooltip text={itemInstance.item.description}>
        <span className="text-gray-100">{itemInstance.item.name}</span>
      </Tooltip>
    </div>
  );
};

let Inventory = ({ inventory }) => {
  return (
    <div className="flex flex-col h-full">
      <h3 className="text-xl text-gray-200 px-4 pt-4">Inventory</h3>
      <div className="flex-grow overflow-y-scroll">
        {inventory.map((itemInstance) => {
          return (
            <Item key={itemInstance.id} itemInstance={itemInstance} />
          );
        })}
      </div>
    </div>
  );
};

let mapStateToProps = (state) => {
  const inventory = getEventsInventory(state);
  return { inventory };
};

export default Inventory = connect(mapStateToProps)(Inventory);
