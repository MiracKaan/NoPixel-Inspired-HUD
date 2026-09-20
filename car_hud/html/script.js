let lastEngineHealth = 1000;
let engineShowTimer = null;

window.addEventListener("message", function(e) {
    if (e.data.action === "updateCarHud") {
        document.getElementById("vehicle-hud").style.display = "flex";
        let d = e.data;
        
        // Electric vs Gas Logic
        let fuelTypeIcon = document.getElementById("fuel-type-icon");
        let rpmPath = document.getElementById("rpm-path");
        
        if (d.isElectric) {
            rpmPath.style.stroke = "url(#elec-grad)";
            fuelTypeIcon.className = "fa-solid fa-plug";
        } else {
            rpmPath.style.stroke = "url(#gas-grad)";
            fuelTypeIcon.className = "fa-solid fa-gas-pump";
        }
        
        // RPM SVG Logic
        let offsetRpm = 100 - (d.rpm * 100);
        rpmPath.style.strokeDashoffset = offsetRpm;
        
        // Center info (Speed)
        let speedStr = d.speed.toString().padStart(3, '0');
        let speedHtml = "";
        let foundNonZero = false;
        for (let i = 0; i < speedStr.length; i++) {
            if (speedStr[i] === '0' && !foundNonZero && i < speedStr.length - 1) {
                speedHtml += `<span class="faded-zero">0</span>`;
            } else {
                foundNonZero = true;
                speedHtml += speedStr[i];
            }
        }
        document.getElementById("veh-speed").innerHTML = speedHtml;
        document.getElementById("veh-gear").innerText = d.gear;
        
        // Fuel SVG Logic
        let fuelPath = document.getElementById("fuel-path");
        let offsetFuel = 100 - d.fuel; 
        fuelPath.style.strokeDashoffset = offsetFuel;
        
        if (d.fuel <= 20) {
            fuelPath.style.stroke = "#e74c3c"; // Red when low
        } else {
            fuelPath.style.stroke = "#ffffff"; // White normally
        }

        // Icons
        let lightsIcon = document.getElementById("icon-lights");
        if (d.lights) {
            lightsIcon.classList.add("active-lights");
        } else {
            lightsIcon.classList.remove("active-lights");
        }
        
        let fuelIcon = document.getElementById("icon-fuel");
        if (d.fuel < 15) {
            fuelIcon.classList.add("active-fuel");
        } else {
            fuelIcon.classList.remove("active-fuel");
        }
        
        let seatbeltIcon = document.getElementById("icon-seatbelt");
        if (d.seatbelt) {
            seatbeltIcon.classList.remove("active-seatbelt");
            seatbeltIcon.classList.add("seatbelt-on");
            seatbeltIcon.innerHTML = '<i class="fa-solid fa-user-check"></i>';
        } else {
            seatbeltIcon.classList.remove("seatbelt-on");
            seatbeltIcon.classList.add("active-seatbelt");
            seatbeltIcon.innerHTML = '<i class="fa-solid fa-user-slash"></i>';
        }
        
        let lockIcon = document.getElementById("icon-lock");
        if (d.locked) {
            lockIcon.classList.remove("unlocked");
            lockIcon.classList.add("locked");
            lockIcon.innerHTML = '<i class="fa-solid fa-lock"></i>';
        } else {
            lockIcon.classList.remove("locked");
            lockIcon.classList.add("unlocked");
            lockIcon.innerHTML = '<i class="fa-solid fa-unlock"></i>';
        }
        
                // Nitro Logic
                let nitroIcon = document.getElementById("icon-nitro");
        let nitroPath = document.getElementById("nitro-path");
        let nitroBg = document.getElementById("nitro-bg");
        let nitroBracket = document.getElementById("nitro-bracket");

        if (d.nitro && d.nitro > 0) {
            if (nitroIcon) nitroIcon.style.display = "flex";
            if (nitroPath) nitroPath.style.display = "block";
            if (nitroBg) nitroBg.style.display = "block";
            if (nitroBracket) nitroBracket.style.display = "block";
            
            if (nitroPath) {
                let offsetNitro = 100 - d.nitro;
                nitroPath.style.strokeDashoffset = offsetNitro;
            }

            if (d.purge >= 100) {
                if (nitroIcon) nitroIcon.classList.add("nitro-purge-alert");
                if (nitroPath) nitroPath.style.stroke = "#ff0000";
            } else {
                if (nitroIcon) nitroIcon.classList.remove("nitro-purge-alert");
                if (nitroPath) nitroPath.style.stroke = "#00d0ff";
            }
        } else {
            if (nitroIcon) {
                nitroIcon.style.display = "none";
                nitroIcon.classList.remove("nitro-purge-alert");
            }
            if (nitroPath) nitroPath.style.display = "none";
            if (nitroBg) nitroBg.style.display = "none";
            if (nitroBracket) nitroBracket.style.display = "none";
        }

        // Engine Health Logic
        let isDamagedNow = false;
        if (d.engine < lastEngineHealth && d.engine < 995) {
            isDamagedNow = true;
        }
        lastEngineHealth = d.engine;
        
        if (d.engine < 995) {
            let enginePct = Math.max(0, Math.min(100, (d.engine / 1000) * 100));
            document.getElementById("engine-fill").style.width = enginePct + "%";
            document.getElementById("engine-icon").style.color = enginePct <= 10 ? "#e74c3c" : "white";
            
            if (enginePct <= 10) {
                // %10'un altÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â±ndaysa kalÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â±cÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â± olarak gÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€Â¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¶ster
                document.getElementById("engine-container").style.display = "flex";
                if (engineShowTimer) clearTimeout(engineShowTimer);
            } else if (isDamagedNow) {
                // Hasar aldÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â±ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â±nda 3 saniye gÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€Â¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¶ster
                document.getElementById("engine-container").style.display = "flex";
                if (engineShowTimer) clearTimeout(engineShowTimer);
                
                engineShowTimer = setTimeout(() => {
                    if (lastEngineHealth > 100) { // 100 (%10)
                        document.getElementById("engine-container").style.display = "none";
                    }
                }, 3000);
            }
        } else {
            document.getElementById("engine-container").style.display = "none";
            if (engineShowTimer) clearTimeout(engineShowTimer);
        }
        
    } else if (e.data.action === "hideCarHud") {
        document.getElementById("vehicle-hud").style.display = "none";
        document.getElementById("engine-container").style.display = "none";
        lastEngineHealth = 1000; // AraÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€Â¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â§tan inince saÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸lÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â±ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¦ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â± sÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â±fÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â±rla ki tekrar binince hasarlÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â±ysa anlÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â±k gÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€Â¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¶zÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€Â¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¼ksÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€Â¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¼n
    }
});
