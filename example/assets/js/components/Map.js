import PropTypes from "prop-types";
import React from "react";
import { connect } from "react-redux";

import { getEventsRoom } from "../redux";

const rows = [2, 1, 0, -1, -2];
const cols = [-2, -1, 0, 1, 2];

let Map = ({ room }) => {
  if (room === null) {
    return null;
  }

  const cells = room.mini_map;

  const currentX = room.x;
  const currentY = room.y;
  const currentZ = room.z;

  return (
    <div className="flex flex-col items-center" style={{ height: 310 }}>
      <svg className="h-full" style={{ width: 310 }} version="1.1" xmlns="http://www.w3.org/2000/svg">
        {rows.map((row) => {
          const y = 20 + (-1 * row + 2) * 60; // eslint-disable-line no-mixed-operators

          return (
            <g key={row} transform={`translate(0, ${y})`}>
              {cols.map((col) => {
                const x = 20 + (col + 2) * 60; // eslint-disable-line no-mixed-operators

                const cell = cells.find((cell) => {
                  return cell.x == col + currentX && cell.y == row + currentY && cell.z == currentZ;
                });

                if (!cell) {
                  return null;
                }

                let className = "";

                if (cell.x == currentX && cell.y == currentY && cell.z == currentZ) {
                  className = `${className} active`;
                }

                className = `${className} ${cell.map_color}`;

                return (
                  <React.Fragment key={x}>
                    <rect className={className} x={x}>
                      <title>{cell.name}</title>
                    </rect>

                    {cell.connections.north && <line x1={x + 15} y1="-10" x2={x + 15} y2="-20" />}
                    {cell.connections.south && <line x1={x + 15} y1="40" x2={x + 15} y2="50" />}
                    {cell.connections.west && <line x1={x - 20} y1="15" x2={x - 10} y2="15" />}
                    {cell.connections.east && <line x1={x + 40} y1="15" x2={x + 50} y2="15" />}
                  </React.Fragment>
                );
              })}
            </g>
          );
        })}
      </svg>
    </div>
  );
};

Map.propTypes = {
  room: PropTypes.shape({
    x: PropTypes.number(),
    y: PropTypes.number(),
    z: PropTypes.number(),
    mini_map: PropTypes.array(
      PropTypes.shape({
        connections: PropTypes.shape({
          north: PropTypes.string(),
          south: PropTypes.string(),
          east: PropTypes.string(),
          west: PropTypes.string(),
        }),
      }),
    ),
  }),
};

let mapStateToProps = (state) => {
  const room = getEventsRoom(state);

  return { room };
};

export default connect(mapStateToProps)(Map);
