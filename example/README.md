# Kantele

Kantele is an example implementation of Kalevala. Kantele stresses everything that Kalevala is capable of.

If you want to start your own Kalevala game, copying Kantele is a great place to start until Kalevala ships with a new game generator.

## Setup

Elixir and NodeJS are both required to run Kantele, the versions used are listed below. It's recommended to use [asdf](https://asdf-vm.com/) to install Elixir and NodeJS.

NodeJS is used to compile the web client. 

- Elixir: 1.10
- NodeJS: 12.16

```bash
mix deps.get
mix compile
(cd assets && yarn install && yarn build)
```

Run the game with

```bash
mix run --no-halt
```

The game will be listening on 3 ports:

- telnet 4444
- secure telnet 4443 (using the self signed cert in `priv`)
- http 4500

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
