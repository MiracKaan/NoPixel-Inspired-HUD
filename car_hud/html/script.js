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
                // %10'un altındaysa kalıcı olarak göster
                document.getElementById("engine-container").style.display = "flex";
                if (engineShowTimer) clearTimeout(engineShowTimer);
            } else if (isDamagedNow) {
                // Hasar aldığında 3 saniye göster
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
        
        // GPS Navigation Logic
        let gpsNav = document.getElementById('gps-nav');
        if (d.hasWaypoint) {
            gpsNav.classList.remove('hidden');
            document.getElementById('gps-distance').innerText = d.waypointDistance.toFixed(2) + ' mi';
            
            let arrowHTML = '<i class="fas fa-arrow-up"></i>';
            if (d.waypointDirection === 'left') {
                arrowHTML = '<i class="fas fa-arrow-left"></i>';
            } else if (d.waypointDirection === 'right') {
                arrowHTML = '<i class="fas fa-arrow-right"></i>';
            } else if (d.waypointDirection === 'back') {
                arrowHTML = '<i class="fas fa-arrow-down"></i>';
            } else if (d.waypointDirection === 'straight') {
                arrowHTML = '<i class="fas fa-arrow-up"></i>';
            }
            document.getElementById('gps-arrow').innerHTML = arrowHTML;
        } else {
            gpsNav.classList.add('hidden');
        }
        
    } else if (e.data.action === "hideCarHud") {
        document.getElementById("vehicle-hud").style.display = "none";
        document.getElementById("engine-container").style.display = "none";
        document.getElementById("gps-nav").classList.add("hidden");
        lastEngineHealth = 1000; 
    }
});
