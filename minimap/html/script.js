window.addEventListener("message", function(event) {
    if (event.data.action === "updateCompass") {
        document.getElementById("compass-container").style.display = "flex";
        
        let d = event.data;
        document.getElementById("degree").innerText = d.heading;
        document.getElementById("street").innerText = d.street;
        document.getElementById("zone").innerText = d.zone;
        
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
