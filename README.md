# Dun-Gen, a Lua Dungeon Generator
A simple Lua library for randomly generating grid-based dungeons

## Features
- A Love2D script for demonstrating the library

## Usage
- TODO

## TODO
- Everything
- Hallways in the "How it works" section of this readme

## Missing
- Everything

## How it works
The goal in mind is producing much less loose dungeons. To achieve this, I've used the following method:

* Make random sized rooms that are mostly square
* Place them all in the center of the screen within around a 4x4-tile space ideally
* LOOP until no rooms overlap:
    * Sort the room array, making the first index the room farthest from the center of the screen
    * FOR each room A:
        * FOR each room B:
            * IF A is not B:
                * WHILE A is overlapping B AND A is farther from the center of the screen than B:
                    * Move A away from B on the furthest overlap axis
                * Break out of the loop, as we were only comparing with the closest overlapping room of A

