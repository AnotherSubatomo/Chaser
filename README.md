<div align="center">

# Chaser
A module that attempts to recreate [@Jam2go](https://www.youtube.com/Jam2go)'s vision of what a second-person view would look like.

[![Release version](https://img.shields.io/github/v/release/AnotherSubatomo/Chaser?color=brightgreen&style=for-the-badge)](#build "Build")
[![Build](https://img.shields.io/badge/-Build-blue.svg?color=brightgreen&style=for-the-badge)](#build "Build")
[![License](https://img.shields.io/badge/-MIT-blue.svg?style=for-the-badge)](LICENSE "License")

</div>

---

A video of the system in action:
[![System Showcase](https://www.youtube.com/watch?v=8W-HuJNAInI/0.jpg)](https://www.youtube.com/watch?v=8W-HuJNAInI&t=9s)

## API
Here are all the things you need to know to work with this module.

#### `Chaser.enable()`
**Params:** nil
**Returns:** nil
Sets the camera to a second-person view mode.


#### `Chaser.disable()`
**Params:** nil
**Returns:** nil
Sets the camera back to it's default behavior (third-person view mode).

#### `Chaser.set()`
**Params:** `Config : ChaserConfig`
**Returns:** nil
Properties affected by this setter function is explain further below.

#### `[TYPE] ChaserConfig`
```
type ChaserConfig = {
	Subject : Player? ;
	Distance : number? ;
	WalkSpeedRatio : number? ;
}
```
* `Subject` — The player who's character will be followed by the camera.

* `Distance` — How far away the camera will be to the subject when it reaches it.

* `WalkSpeedRatio` — The proportion of the cameraman's walk speed to the subject character's walk speed. ( higher = faster )

---

## Build
To build the place from scratch, use:

```bash
rojo build -o "Chaser.rbxlx"
```

Next, open `Chaser.rbxlx` in Roblox Studio and start the Rojo server:

```bash
rojo serve
```

For more help, check out [the Rojo documentation](https://rojo.space/docs).