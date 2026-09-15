<div align="center">
  <h1>✨ NoPixel-Inspired HUD (Modular FiveM HUD System)</h1>
  <p>A modern, sleek, fully optimized, and modular User Interface (HUD) for FiveM.</p>
</div>

<img width="1919" height="1079" alt="image" src="https://github.com/user-attachments/assets/ba85a6a8-8cb2-4054-8ea2-fd9dcb373abb" />


---

## 📌 Features

NoPixel-Inspired HUD is designed with performance in mind and is completely modular, divided into three standalone standalone scripts (`player_hud`, `car_hud`, `minimap`, `pulse_hud`).

```commands
/cinematic
/togglemap
/broken (test commands)
/blending (test commands)
/developermode
```
---

## 🛠️ Installation

1. Download this repository and extract it to your desktop or directly into your server.
2. Drag and drop the `player_hud`, `car_hud`, and `minimap` folders into your server's `resources` directory.
3. Open your `server.cfg` and add the following lines:
   ```cfg
   ensure minimap
   ensure player_hud
   ensure car_hud
   ensure pulse_hud (Installation is not mandatory.)
   ```
4. Restart your server or type `ensure [hud]` in your server console.

It now works compatibly with qbx_medical.
