window.addEventListener("message", function(event) {
    if (event.data.action === "update") {
        document.getElementById("hud").style.display = "flex";
        
        let d = event.data.data;
        
        document.getElementById("health-fill").style.width = d.health + "%";
        document.getElementById("armor-fill").style.width = d.armor + "%";
        
        let hungerColor = d.hunger < 20 ? "red" : "white";
        document.getElementById("hunger-icon").style.background = `linear-gradient(to top, ${hungerColor} ${d.hunger}%, rgba(255,255,255,0.15) ${d.hunger}%)`;
        document.getElementById("hunger-icon").style.webkitBackgroundClip = "text";
        document.getElementById("hunger-icon").style.webkitTextFillColor = "transparent";

        let thirstColor = d.thirst < 20 ? "red" : "white";
        document.getElementById("thirst-icon").style.background = `linear-gradient(to top, ${thirstColor} ${d.thirst}%, rgba(255,255,255,0.15) ${d.thirst}%)`;
        document.getElementById("thirst-icon").style.webkitBackgroundClip = "text";
        document.getElementById("thirst-icon").style.webkitTextFillColor = "transparent";
        
        if (d.stamina < 100) {
            document.getElementById("stamina-container").style.display = "flex";
            document.getElementById("stamina-fill").style.width = d.stamina + "%";
            document.getElementById("stamina-icon").style.color = d.stamina < 20 ? "red" : "white";
        } else {
            document.getElementById("stamina-container").style.display = "none";
        }
        
        if (d.isUnderwater) {
            document.getElementById("oxygen-container").style.display = "flex";
            document.getElementById("oxygen-fill").style.width = d.oxygen + "%";
            document.getElementById("oxygen-icon").style.color = d.oxygen < 20 ? "red" : "white";
        } else {
            document.getElementById("oxygen-container").style.display = "none";
        }

        let mic = document.getElementById("mic-bg");
        let micIcon = document.getElementById("mic-icon");
        
        let fill = 0;
        if (d.voice <= 1) fill = 33;
        else if (d.voice == 2) fill = 66;
        else if (d.voice >= 3) fill = 100;
        
        if (d.isTalking) {
            micIcon.style.color = "#b026ff";
            mic.style.background = `linear-gradient(to top, rgba(176, 38, 255, 0.4) ${fill}%, rgba(15, 15, 15, 0.8) ${fill}%)`;
        } else {
            micIcon.style.color = "white";
            mic.style.background = `linear-gradient(to top, rgba(255, 255, 255, 0.2) ${fill}%, rgba(15, 15, 15, 0.8) ${fill}%)`;
        }
        
        // Custom Crosshair
        if (d.isAiming) {
            document.getElementById("crosshair").style.display = "block";
        } else {
            document.getElementById("crosshair").style.display = "none";
        }
        
        // Weapon Ammo
        if (d.hasWeapon) {
            document.getElementById("weapon-container").style.display = "flex";
            document.getElementById("ammo-clip").innerText = d.ammoClip;
            document.getElementById("ammo-total").innerText = d.ammoTotal;
        } else {
            document.getElementById("weapon-container").style.display = "none";
        }
    } else if (event.data.action === "hide") {
        document.getElementById("hud").style.display = "none";
        document.getElementById("stamina-container").style.display = "none";
        document.getElementById("oxygen-container").style.display = "none";
        document.getElementById("weapon-container").style.display = "none";
        document.getElementById("crosshair").style.display = "none";
    } else if (event.data.action === "cinematicBars") {
        let isCinematic = event.data.state;
        document.getElementById("cinematic-top").style.height = isCinematic ? "12vh" : "0";
        document.getElementById("cinematic-bottom").style.height = isCinematic ? "12vh" : "0";
    }
});
