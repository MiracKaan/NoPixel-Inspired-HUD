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

## 🚀 Release Notes / Update Log

This update brings a major UI overhaul to the HUD systems. Scattered scripts have been consolidated into a single unified resource to improve performance and code maintainability.

### ✨ Added & Changed
* **[Car HUD] Advanced Nitrous (N2O) Integration:** Removed the bulky standalone nitrous script. The system has been natively integrated directly into the `car_hud` resource.
* **[Car HUD] Symmetrical Nitrous Bar:** Added a sleek, minimalist Nitrous (N2O) arc and bottle icon to the left side of the speedometer, working in perfect symmetry with the fuel gauge. (UI automatically hides when the bottle is empty).
* **[Car HUD] Purge Visual Alert:** When engine pressure builds up after nitrous usage, the nitrous bar now flashes red (flash animation) to visually alert the player that a purge is required.
* **[Player HUD] UI Overhaul:** Updated the Player HUD design. Transitioned to a cleaner, more modern, and eye-friendly user interface layout.
* **[Minimap] Radar Compass Ticks:** Added static outer ticks around the minimap border to complement the compass aesthetic. Made fully responsive to flawlessly adapt to different screen resolutions.

### 🐛 Fixed
* **[Car HUD] Seatbelt Bug:** Fixed an issue where players could exit or jump out of the vehicle while their seatbelt was still fastened. The exit vehicle key is now strictly blocked while buckled up.

