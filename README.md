# RandomShop

This project is a way for a DungeonMaster/GameMaster to create a small shop for a town their players arive in.

The idea is that stock and supply will be high/low depending on a variety of circumstances.  This will generate a list of goods for a given type of store, adjust the prices and availability based off of scarcity and settlement size.

## Basic Inputs

Below are listed the basic inputs that will be needed to generate a store.

The basic equation will be:

* **Availability:** Base Availability + Settlement Size Bonus + Events
* **Stock Level:** Base Stock Level * Settlement Size Bonus * Events

### Settlement Size

Select a settlement size.  At first, we'll only support the same settlement sizes as the DMG:

* Village
* Town
* City

We assume that Towns are the most common settlement size.  A village will have a 10% penalty to whether a good is stocked and also impact the number of items in stock.  Citieis will have a 10% boost.

### Scarcity/Plentifulness event

Similar to settlement size, scarcity and plentifulness can be impacted through other things, like:

* Iron Shortage
* The Alchemists Shop closed down
* A recent spat of poisoness snakes attacked

These events will have an attribute associated with them, and these attributes will stack up to determine the scarcity of an item.

For instance, if there's an Iron Shortage _and_ the local Blacksmith is away, those things decrease the chance that a chain is in stock, and if it is, how many are available and its price.  Events will have a primary attribute/tag that they are associated with.  Good associated with that attribute will be effected.  Mutliple events stack up for a given good.

