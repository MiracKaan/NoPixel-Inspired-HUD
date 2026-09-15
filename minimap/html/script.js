window.addEventListener("message", function(event) {
    if (event.data.action === "updateCompass") {
        document.getElementById("compass-container").style.display = "flex";
        
        let d = event.data;
        document.getElementById("degree").innerText = d.heading;
        document.getElementById("street").innerText = d.street;
        document.getElementById("zone").innerText = d.zone;
        
        if (d.waypoint) {
            document.getElementById("waypoint-box").style.display = "flex";
            document.getElementById("waypoint-dist").innerText = d.waypoint;
            
            let arrowClass = "fa-arrow-up";
            if (d.waypointDir === "left") arrowClass = "fa-arrow-left";
            else if (d.waypointDir === "right") arrowClass = "fa-arrow-right";
            else if (d.waypointDir === "down") arrowClass = "fa-arrow-down";
            
            document.querySelector("#waypoint-box i").className = "fa-solid " + arrowClass;
        } else {
            document.getElementById("waypoint-box").style.display = "none";
        }
        
        document.getElementById("compass-letters").style.transform = `rotate(${-d.heading}deg)`;
        
        const letters = document.querySelectorAll(".letter");
        letters.forEach(letter => {
            letter.style.transform = `translate(-50%, -50%) rotate(${d.heading}deg)`;
        });
    } else if (event.data.action === "hideCompass") {
        document.getElementById("compass-container").style.display = "none";
    } else if (event.data.action === "showSafezoneWarning") {
        document.getElementById("safezone-warning").style.display = "flex";
    } else if (event.data.action === "hideSafezoneWarning") {
        document.getElementById("safezone-warning").style.display = "none";
    }
});

