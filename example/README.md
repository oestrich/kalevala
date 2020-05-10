# Kantele

Kantele is an example implementation of Kalevala. Kantele stresses everything that Kalevala is capable of.

If you want to start your own Kalevala game, copying Kantele is a great place to start until Kalevala ships with a new game generator.

## Game Data

Game data is held in the `data` folder. These files are in the [UCL](https://github.com/vstakhov/libucl) format. They are parsed by [Elias](https://github.com/oestrich/elias), a custom parser for UCL.

### Configuration

General configuration lives in single files in the top level of the folder.

- `emotes.ucl`, definition of emotes/socials for players to use
- `config.ucl`, general configuration of the game, e.g. player initial data

### Zone Files

Zone files are in the `data/world` folder. Each file contains a full zone, including rooms, items, characters, and more.

### Behavior Tree Brain Files

Characters can have behavior tree "brains" and these can be stored directly in the character definition or in separate files and referenced. This is due to the fact that these brains can get quite large.
