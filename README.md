Airways3D is a plugin designed for [Godot 4](https://godotengine.org/) that enables spatial navigation. It is particularly useful for implementing flying or swimming behaviors for entities in your game.

## Installation
1. Download the plugin rom here
2. Place the plugin folder in your Godot project's addons directory. 
3. Enable it in you project settings
 
> [!IMPORTANT]
> This plugin verifies point validity by performing a shape cast within the designated area, utilizing the physics engine. While functional, it's worth noting that Godot's native physics system can sometimes miss certain geometries. For improved stability and performance, I highly recommend using [Godot Jolt](https://github.com/godot-jolt/godot-jolt).

## How to Use
I will provide detailed documentation on usage in the future, but here's a basic guide on setting up and using Airways3D:
1. Add an `Airways3D` node to your scene. Adjust its size and cell size parameters, then press `Build navigation Area` to create your navigation area.
2. Attach an `AirAgent3D` node as a child of the entity that will navigate in 3D space. Use the `get_next_point()` and `set_target()` methods to configure and control its movement.


## Contributing
I'm a dumbass and as such contributions are welcome! If you encounter issues or have suggestions for improvements, please submit an issue or pull request.
