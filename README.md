Airways3D is a plugin designed for [Godot 4](https://godotengine.org/) that enables spatial navigation. It is particularly useful for implementing flying or swimming behaviors for entities in your game.
##Installation
1. Download the plugin rom here
2. Place the plugin folder in your Godot project's addons directory. 
3. Enable it in you project settings
[!IMPORTANT]
This plugin verifies point validity by performing a shape cast within the designated area, utilizing the physics engine. While functional, it's worth noting that Godot's native physics system can sometimes miss certain geometries. For improved stability and performance, I highly recommend using [Godot Jolt](https://github.com/godot-jolt/godot-jolt).
