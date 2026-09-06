<div align="center">
  <h1>✨ NoPixel-Inspired HUD (Modular FiveM HUD System)</h1>
  <p>A modern, sleek, fully optimized, and modular User Interface (HUD) for FiveM.</p>
</div>

---

## 📌 Features

NoPixel-Inspired HUD is designed with performance in mind and is completely modular, divided into three standalone standalone scripts (`player_hud`, `car_hud`, `minimap`).

---

## 🛠️ Installation

1. Download this repository and extract it to your desktop or directly into your server.
2. Drag and drop the `player_hud`, `car_hud`, and `minimap` folders into your server's `resources` directory.
3. Open your `server.cfg` and add the following lines:
   ```cfg
   ensure minimap
   ensure player_hud
   ensure car_hud
   ```
4. Restart your server or type `ensure [script-name]` in your server console.

> [!NOTE]
> The `player_hud` and `car_hud` logic relies on standard StateBags (e.g., `LocalPlayer.state.seatbelt`) and natively integrates flawlessly with `QBCore` and `Qbox` frameworks.

