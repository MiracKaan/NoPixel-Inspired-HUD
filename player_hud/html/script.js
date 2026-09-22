window.addEventListener("message", function(event) {
    if (event.data.action === "update") {
        document.getElementById("hud").style.display = "flex";
        document.getElementById("player-info-hud").style.display = "flex";
        let d = event.data.data;

        let formatMoney = (amount) => {
            return "$" + amount.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
        };

        if (d.pId !== undefined) document.getElementById("player-id").innerText = d.pId;
        if (d.pName !== undefined) document.getElementById("player-name").innerText = d.pName;
        if (d.pJob !== undefined) document.getElementById("player-job").innerText = d.pJob;
        if (d.pCash !== undefined) document.getElementById("player-cash").innerText = formatMoney(d.pCash);
        if (d.pBank !== undefined) document.getElementById("player-bank").innerText = formatMoney(d.pBank);
        
        
        
        document.getElementById("health-fill").style.width = d.health + "%";
        document.getElementById("armor-fill").style.width = d.armor + "%";
        
        document.getElementById("hunger-fill").style.width = d.hunger + "%";
        document.getElementById("thirst-fill").style.width = d.thirst + "%";
        
        let hungerColor = d.hunger < 20 ? "red" : "rgba(255,255,255,0.7)";
        document.getElementById("hunger-icon").style.color = hungerColor;

        let thirstColor = d.thirst < 20 ? "red" : "rgba(255,255,255,0.7)";
        document.getElementById("thirst-icon").style.color = thirstColor;
        
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
        
        if (d.isRadio) {
            micIcon.className = "fa-solid fa-walkie-talkie";
        } else {
            micIcon.className = "fa-solid fa-microphone";
        }

        if (d.isTalking || d.isRadio) {
            micIcon.style.color = (d.isRadio) ? "#e74c3c" : "#b026ff";
            mic.style.background = `linear-gradient(to top, rgba(176, 38, 255, 0.4) ${fill}%, rgba(15, 15, 15, 0.85) ${fill}%)`;
        } else {
            micIcon.style.color = "white";
            mic.style.background = `linear-gradient(to top, rgba(255, 255, 255, 0.2) ${fill}%, rgba(15, 15, 15, 0.85) ${fill}%)`;
        }
        
        let stressBg = document.getElementById("stress-bg");
        let stressIcon = document.getElementById("stress-icon");
        if (d.showStress && d.stress > 0) {
            stressBg.style.display = "flex";
            stressBg.style.background = `linear-gradient(to top, rgba(231, 76, 60, 0.4) ${d.stress}%, rgba(15, 15, 15, 0.85) ${d.stress}%)`;
            stressIcon.style.color = d.stress > 50 ? "#e74c3c" : "white";
        } else {
            stressBg.style.display = "none";
        }

        if (d.bleed) {
            let bleedContainer = document.getElementById("bleed-container");
            bleedContainer.style.display = "flex";
            bleedContainer.style.background = `linear-gradient(to top, rgba(139, 0, 0, 0.6) ${d.bleedLevel}%, rgba(15, 15, 15, 0.85) ${d.bleedLevel}%)`;
            
            if (d.bleedLevel > 80) {
                bleedContainer.classList.add("bleed-critical");
            } else {
                bleedContainer.classList.remove("bleed-critical");
            }
        } else {
            document.getElementById("bleed-container").style.display = "none";
            document.getElementById("bleed-container").classList.remove("bleed-critical");
        }

        if (d.bone) {
            document.getElementById("bone-container").style.display = "flex";
        } else {
            document.getElementById("bone-container").style.display = "none";
        }

        if (d.devmode) {
            document.getElementById("devmode-container").style.display = "flex";
        } else {
            document.getElementById("devmode-container").style.display = "none";
        }

        if ((d.showStress && d.stress > 0) || d.bleed || d.bone || d.devmode) {
            document.getElementById("status-separator").style.display = "block";
        } else {
            document.getElementById("status-separator").style.display = "none";
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
        document.getElementById("player-info-hud").style.display = "none";
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
