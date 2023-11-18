Have you ever wondered if a Discord bot can be run on Godot in headless mode?

Wonder no more.

# DragonfoxGen original bot code, for your viewing pleasure

The .token is not in this repository.  This project was built for Godot 3.4 (and may run on Godot 3.5).

This code may not work, it may not work well, it may simply be broken.

More importantly...

## Please don't run a Discord bot on Godot.

- It's not efficient.
- DiscordGD doesn't support sharding (IIRC) and Godot 3.x was not meant to multithread or await/async (outside of C#).
- It was janky just to get this running.
- Just don't do it.  Go learn any other framework/language of choice.  (I use Typescript & Deno now with Discord.JS)

(half-jokes aside, you could always try to run this bot but I didn't include the final build so you will have to get Godot 3.4 and pray that you can get it built.)

## I offer no support, no warranty, no _anything_ for this repository.  This repository exists solely to share my experiment & provide whatever education you can get out of it.

Have fun!