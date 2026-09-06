window.addEventListener("message", function(e) {
    if (e.data.action === "updateCarHud") {
        document.getElementById("vehicle-hud").style.display = "flex";
        let d = e.data;
        
        // RPM SVG Logic
        let rpmPath = document.getElementById("rpm-path");
        let offsetRpm = 100 - (d.rpm * 100);
        rpmPath.style.strokeDashoffset = offsetRpm;
        
        if (d.rpm > 0.85) {
            rpmPath.style.stroke = "#e74c3c"; // Redline
        } else {
            rpmPath.style.stroke = "#00ffff"; // Cyan
        }
        
        // Fuel SVG Logic
        let fuelPath = document.getElementById("fuel-path");
        let offsetFuel = 100 - d.fuel; 
        fuelPath.style.strokeDashoffset = offsetFuel;
        
        if (d.fuel <= 20) {
            fuelPath.style.stroke = "#e74c3c"; // Red when low
        } else {
            fuelPath.style.stroke = "#ffffff"; // White normally
        }
        
        // Center info
        let speedStr = d.speed.toString().padStart(3, '0');
        document.getElementById("veh-speed").innerText = speedStr;
        document.getElementById("veh-gear").innerText = d.gear;
        
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
        
    } else if (e.data.action === "hideCarHud") {
        document.getElementById("vehicle-hud").style.display = "none";
    }
});
