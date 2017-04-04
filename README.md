# Dun-Gen, a Lua Dungeon Generator
A simple Lua library for randomly generating grid-based dungeon maps that appear handcrafted

## Features
- A Love2D script for demonstrating the library

## Usage
- TODO

## To-do
- Hallway generation
- Dungeon:getRooms()
- Dungeon:getHallways()

## Issues
- Rooms occasionally generate connected to each other

## How it works
The goal in mind is producing dungeons that look more handcrafted rather than noisy. Some inspiration can be taken from cyclical dungeon generation and TinyKeep's generation algorithm. To achieve this, I've used the following method:

* Make random sized rooms that are mostly square
* Place them all in the center of the screen within around a 4x4-tile space ideally
* LOOP until no rooms overlap:
    * Sort the room array, making the first index the room farthest from the center of the screen
    * FOR each room A:
        * FOR each room B:
            * IF A and B are overlapping and A and B are not the same room:
                * Move A away from B on the furthest overlap axis
            * Break out of the loop, as we were only comparing with the closest overlapping room of A
* TODO: Hallway generation
