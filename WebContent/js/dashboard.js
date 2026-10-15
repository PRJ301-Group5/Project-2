/* Spirit Dashboard charts - uses Chart.js loaded in dashboard.jsp */

(function () {
    if (typeof scores === 'undefined' || scores.length === 0) {
        console.log('[Spirit] No scores to render');
        return;
    }

    // Color by status
    function color(status) {
        if (status === 'LOW')    return '#e74c3c';
        if (status === 'HIGH')   return '#27ae60';
        return '#3498db';
    }

    const pieCtx = document.getElementById('pieChart').getContext('2d');
    new Chart(pieCtx, {
        type: 'pie',
        data: {
            labels: scores.map(s => s.name),
            datasets: [{
                data: scores.map(s => s.pct),
                backgroundColor: scores.map(s => color(s.status)),
                borderColor: '#fff',
                borderWidth: 2
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: { position: 'bottom' },
                tooltip: {
                    callbacks: {
                        label: (ctx) => ctx.label + ': ' + ctx.parsed.toFixed(2) + '%'
                    }
                }
            }
        }
    });

    const barCtx = document.getElementById('barChart').getContext('2d');
    new Chart(barCtx, {
        type: 'bar',
        data: {
            labels: scores.map(s => s.code + ' - ' + s.name),
            datasets: [{
                label: 'Commits',
                data: scores.map(s => s.commits),
                backgroundColor: scores.map(s => color(s.status))
            }]
        },
        options: {
            responsive: true,
            plugins: { legend: { display: false } },
            scales: {
                y: { beginAtZero: true, ticks: { precision: 0 } }
            }
        }
    });
})();
