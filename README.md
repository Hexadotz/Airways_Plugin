![Airways Logo](https://github.com/user-attachments/assets/ee28bb18-fd90-4382-aa1f-7ad7d383950a)
**Airways3D** is a plugin designed for [Godot 4](https://godotengine.org/) that enables spatial navigation. It is particularly useful for implementing flying or swimming behaviors for entities in your game.

<!-- ![Capture](https://github.com/user-attachments/assets/4c7c9d2e-4fbf-4bae-b7d9-2103e52005f7)-->

## Installation
1. Download the plugin rom here
2. Place the plugin folder in your Godot project's addons directory. 
3. Enable it in you project settings
 
> [!IMPORTANT]
> This plugin verifies point validity by performing a shape cast within the designated area, utilizing the physics engine in the process. While functional, Godot's native physics system can sometimes miss certain geometries and is a sin in terms of a physics engine. For improved stability and performance, I _**highly**_ recommend using [Godot Jolt](https://github.com/godot-jolt/godot-jolt) regardless if you're going to use this plugin or not.

## How to Use
I will provide detailed documentation on usage in the future, but here's a basic guide on setting up and using Airways3D:
1. Add an `Airways3D` node to your scene. Adjust its size and cell size parameters, then press `Build navigation Area` to create your navigation area.
2. Attach an `AirAgent3D` node as a child of the entity that will navigate in 3D space. First set the target the node is going to travel to and then use the `get_next_point()` method, which returns the next point in the array.

> [!WARNING]
> As of now you can only use one Airways node in literaly the entier game which is unacceptable, i'm currently focusing on that.

## Contributing
I'm a dumbass and as such contributions are welcome! If you encounter issues or have suggestions for improvements, please submit an issue or pull request.
