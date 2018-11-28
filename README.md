# Gossip Algorithm

## Description

The project is implemented in Elixir and uses actor model to build a good solution to Gossip algorithms which can be used both for group communication and for aggregate computation. The goal of this project is to determine
the convergence of such algorithms through a simulator based on actors written
in Elixir. Since actors in Elixir are fully asynchronous, the particular type of
Gossip implemented is the so called Asynchronous Gossip.

### Instructions

#### Build the project

    mix escript.build

This will install and compile all the dependencies for the project.

#### Running the project

    escript gossip <n> <topology> <algorithm>

    n = number of nodes
    topology = full|line|3d_grid|imp_line|sphere|rand_2d
    algorithm = gossip|pushsum

    e.g. escript gossip 10 full gossip

## Largest network

Able to execute the application for 10,000 nodes for different topology and algorithm.

## Project Status

Implemented all the topologies listed below for gossip and push sum algorithm -

* Line
* Imperfect Line
* Sphere
* 3D grid
* Random 2D grid
* Full network

Additionally, failure model has also been implemented where terminating random nodes are terminating to observe their effect on the algorithms.# gossip-protocol
