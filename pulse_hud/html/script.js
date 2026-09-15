function polarToCartesian(centerX, centerY, radius, angleInDegrees) {
  var angleInRadians = (angleInDegrees - 90) * Math.PI / 180.0;
  return {
    x: centerX + (radius * Math.cos(angleInRadians)),
    y: centerY + (radius * Math.sin(angleInRadians))
  };
}

function describeArcSegment(x, y, radiusIn, radiusOut, startAngle, endAngle) {
    var startIn = polarToCartesian(x, y, radiusIn, endAngle);
    var endIn = polarToCartesian(x, y, radiusIn, startAngle);
    var startOut = polarToCartesian(x, y, radiusOut, endAngle);
    var endOut = polarToCartesian(x, y, radiusOut, startAngle);
    var largeArcFlag = endAngle - startAngle <= 180 ? '0' : '1';
    return [
        'M', startOut.x, startOut.y,
        'A', radiusOut, radiusOut, 0, largeArcFlag, 0, endOut.x, endOut.y,
        'L', endIn.x, endIn.y,
        'A', radiusIn, radiusIn, 0, largeArcFlag, 1, startIn.x, startIn.y,
        'Z'
    ].join(' ');
}

const svg = document.getElementById('pulse-svg');
const angles = [
    { start: 160, end: 212 },
    { start: 218, end: 270 },
    { start: 276, end: 328 },
    { start: 334, end: 386 },
    { start: 392, end: 444 }
];

const segments = [];
angles.forEach((angle, index) => {
    const path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
    path.setAttribute('d', describeArcSegment(50, 50, 28, 46, angle.start, angle.end));
    path.setAttribute('class', 'segment');
    path.setAttribute('id', 'seg-' + index);
    svg.appendChild(path);
    segments.push(path);
});

window.addEventListener('message', function(event) {
    let data = event.data;
    if (data.action === 'update') {
        document.getElementById('hud-container').classList.remove('hidden');
        
        let pulse = data.pulse;
        document.getElementById('pulse-value').innerText = Math.round(pulse);
        
        let wrapper = document.querySelector('.pulse-wrapper');
        
        // Color logic based on pulse
        if (pulse >= 100) {
            wrapper.classList.remove('color-cyan');
            wrapper.classList.add('color-red');
            wrapper.classList.add('beating');
        } else {
            wrapper.classList.remove('color-red');
            wrapper.classList.add('color-cyan');
            wrapper.classList.remove('beating');
        }
        
        // Fill logic for 5 segments
        let fillCount = 0;
        if (pulse < 80) fillCount = 1;
        else if (pulse < 95) fillCount = 2;
        else if (pulse < 110) fillCount = 3;
        else if (pulse < 125) fillCount = 4;
        else fillCount = 5;
        
        segments.forEach((seg, i) => {
            if (i < fillCount) {
                seg.classList.add('filled');
            } else {
                seg.classList.remove('filled');
            }
        });
    } else if (data.action === 'hide') {
        document.getElementById('hud-container').classList.add('hidden');
    }
});
