<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <title>Level Devil - Java Web Replica</title>
    <style>
        :root {
            --bg-dark: #050816;
            --bg-mid: #161b3b;
            --bg-light: #272b5a;
            --accent: #ffde3b;
            --danger: #ff3366;
            --safe: #4ade80;
            --player: #38bdf8;
            --text: #e5e7eb;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            background: radial-gradient(circle at top, #18181b 0, #020617 55%, #000 100%);
            color: var(--text);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .frame {
            width: 100%;
            max-width: 960px;
            padding: 24px;
        }

        .panel {
            background: linear-gradient(145deg, rgba(15,23,42,0.96), rgba(15,23,42,0.98));
            border-radius: 18px;
            border: 1px solid rgba(148,163,184,0.3);
            box-shadow:
                    0 20px 40px rgba(15,23,42,0.7),
                    0 0 0 1px rgba(15,23,42,0.9);
            padding: 18px 18px 14px;
        }

        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 12px;
        }

        .title {
            display: flex;
            flex-direction: column;
            gap: 2px;
        }

        .title h1 {
            font-size: 1.1rem;
            letter-spacing: 0.08em;
            text-transform: uppercase;
            color: var(--accent);
        }

        .title span {
            font-size: 0.78rem;
            color: #9ca3af;
        }

        .hud {
            display: flex;
            gap: 12px;
            align-items: center;
            font-size: 0.78rem;
        }

        .pill {
            padding: 4px 8px;
            border-radius: 999px;
            border: 1px solid rgba(148,163,184,0.4);
            background: radial-gradient(circle at top left, rgba(148,163,184,0.16), rgba(15,23,42,0.95));
        }

        .pill strong {
            color: var(--accent);
        }

        .pill-danger strong {
            color: var(--danger);
        }

        .pill-ok strong {
            color: var(--safe);
        }

        .layout {
            display: grid;
            grid-template-columns: minmax(0, 3fr) minmax(0, 2fr);
            gap: 14px;
        }

        @media (max-width: 800px) {
            .layout {
                grid-template-columns: minmax(0, 1fr);
            }
        }

        .game-shell {
            position: relative;
            border-radius: 14px;
            overflow: hidden;
            border: 1px solid rgba(148,163,184,0.5);
            background: radial-gradient(circle at top, var(--bg-mid), var(--bg-dark));
        }

        #gameCanvas {
            display: block;
            width: 100%;
            height: auto;
            background: linear-gradient(#020617 0, #020617 60%, #0f172a 60%, #020617 100%);
        }

        .game-overlay {
            position: absolute;
            inset: 0;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            pointer-events: none;
            text-align: center;
            padding: 16px;
        }

        .badge-row {
            display: flex;
            flex-wrap: wrap;
            gap: 6px;
            margin-bottom: 8px;
            justify-content: center;
        }

        .badge {
            font-size: 0.68rem;
            text-transform: uppercase;
            letter-spacing: 0.12em;
            padding: 4px 8px;
            border-radius: 999px;
            border: 1px solid rgba(148,163,184,0.6);
            background: rgba(15,23,42,0.92);
            color: #e5e7eb;
        }

        .badge-rng {
            border-color: rgba(96,165,250,0.9);
            box-shadow: 0 0 0 1px rgba(96,165,250,0.3);
        }

        .badge-hard {
            border-color: rgba(248,113,113,0.9);
            box-shadow: 0 0 0 1px rgba(248,113,113,0.3);
        }

        .badge-levels {
            border-color: rgba(52,211,153,0.9);
            box-shadow: 0 0 0 1px rgba(52,211,153,0.3);
        }

        .overlay-title {
            font-size: 1.1rem;
            margin-bottom: 6px;
        }

        .overlay-sub {
            font-size: 0.82rem;
            color: #d1d5db;
            margin-bottom: 10px;
        }

        .overlay-hint {
            font-size: 0.75rem;
            color: #9ca3af;
        }

        .overlay-hint span {
            color: var(--accent);
        }

        .overlay-bottom-hint {
            position: absolute;
            bottom: 8px;
            left: 0;
            right: 0;
            font-size: 0.7rem;
            color: #6b7280;
        }

        .side-panel {
            border-radius: 14px;
            border: 1px solid rgba(148,163,184,0.5);
            background: radial-gradient(circle at top left, rgba(30,64,175,0.48), rgba(15,23,42,0.98));
            padding: 12px 12px 10px;
            display: flex;
            flex-direction: column;
            gap: 10px;
            font-size: 0.78rem;
        }

        .side-panel h2 {
            font-size: 0.9rem;
            margin-bottom: 4px;
        }

        .step-list {
            list-style: none;
            display: flex;
            flex-direction: column;
            gap: 6px;
        }

        .step {
            display: flex;
            gap: 8px;
            align-items: flex-start;
        }

        .step-index {
            width: 18px;
            height: 18px;
            border-radius: 999px;
            background: rgba(15,23,42,0.9);
            border: 1px solid rgba(148,163,184,0.7);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.66rem;
            color: #e5e7eb;
            flex-shrink: 0;
        }

        .step strong {
            color: var(--accent);
        }

        .legend {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 8px;
            margin-top: 4px;
        }

        .legend-item {
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .legend-swatch {
            width: 14px;
            height: 14px;
            border-radius: 4px;
        }

        .legend-swatch.player {
            background: var(--player);
        }

        .legend-swatch.spike {
            background: var(--danger);
        }

        .legend-swatch.goal {
            background: var(--safe);
        }

        .metrics {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
            margin-top: 4px;
        }

        .metric {
            padding: 4px 8px;
            border-radius: 999px;
            border: 1px dashed rgba(148,163,184,0.6);
            font-size: 0.7rem;
            color: #e5e7eb;
        }

        .metric span {
            color: var(--accent);
        }

        .footer-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 6px;
            font-size: 0.7rem;
            color: #9ca3af;
        }

        .footer-row code {
            font-size: 0.72rem;
            background: rgba(15,23,42,0.9);
            padding: 2px 5px;
            border-radius: 4px;
            border: 1px solid rgba(55,65,81,0.9);
        }
    </style>
</head>
<body>
<div class="frame">
    <div class="panel">
        <div class="header">
            <div class="title">
                <h1>LEVEL DEVIL // WEB BUILD</h1>
                <span>Random spike hell with multi-level rage logic</span>
            </div>
            <div class="hud">
                <div class="pill"><strong>LEVEL:</strong> <span id="hudLevel">1</span> / <span id="hudMaxLevel">5</span></div>
                <div class="pill pill-danger"><strong>DEATHS:</strong> <span id="hudDeaths">0</span></div>
                <div class="pill pill-ok"><strong>BEST:</strong> <span id="hudBest">–</span></div>
            </div>
        </div>

        <div class="layout">
            <div class="game-shell">
                <canvas id="gameCanvas" width="640" height="360"></canvas>
                <div class="game-overlay" id="gameOverlay">
                    <div class="badge-row">
                        <div class="badge badge-rng">Randomized traps</div>
                        <div class="badge badge-hard">Instant death</div>
                        <div class="badge badge-levels">5 procedural levels</div>
                    </div>
                    <div class="overlay-main">
                        <div class="overlay-title" id="overlayTitle">Press SPACE to start</div>
                        <div class="overlay-sub" id="overlaySub">Survive the spikes. Each level rerolls a fresh pattern.</div>
                        <div class="overlay-hint" id="overlayHint">
                            <span>SPACE</span> to jump · <span>R</span> to restart level · <span>Q</span> to rage-quit
                        </div>
                    </div>
                    <div class="overlay-bottom-hint" id="overlayBottomHint">
                        Hint: Holding JUMP gives you a higher arc. You cannot change direction.
                    </div>
                </div>
            </div>

            <aside class="side-panel">
                <div>
                    <h2>How this build works</h2>
                    <ul class="step-list">
                        <li class="step">
                            <div class="step-index">1</div>
                            <div>
                                <strong>Random logic.</strong> Each level seeds a pseudo-random generator so spike layouts are unpredictable but reproducible.
                            </div>
                        </li>
                        <li class="step">
                            <div class="step-index">2</div>
                            <div>
                                <strong>Levels.</strong> Five phases with increasing speed, spike density, and fake-out "safe" gaps.
                            </div>
                        </li>
                        <li class="step">
                            <div class="step-index">3</div>
                            <div>
                                <strong>Assets.</strong> Player, spikes, and goal rendered as neon blocks; easy to swap for real art in <code>src/main/webapp/assets</code>.
                            </div>
                        </li>
                    </ul>
                </div>

                <div>
                    <h2>Legend</h2>
                    <div class="legend">
                        <div class="legend-item">
                            <div class="legend-swatch player"></div>
                            <span>Runner</span>
                        </div>
                        <div class="legend-item">
                            <div class="legend-swatch spike"></div>
                            <span>Spike trap</span>
                        </div>
                        <div class="legend-item">
                            <div class="legend-swatch goal"></div>
                            <span>Exit portal</span>
                        </div>
                    </div>
                    <div class="metrics">
                        <div class="metric">Seed: <span id="hudSeed">–</span></div>
                        <div class="metric">Speed: <span id="hudSpeed">–</span></div>
                        <div class="metric">Traps: <span id="hudTraps">–</span></div>
                    </div>
                </div>

                <div class="footer-row">
                    <span>Tip: Reload the page to re-roll every level seed.</span>
                    <span>Controls: <code>SPACE</code> · <code>R</code> · <code>Q</code></span>
                </div>
            </aside>
        </div>
    </div>
</div>

<script>
    (function () {
        const canvas = document.getElementById('gameCanvas');
        const ctx = canvas.getContext('2d');

        const overlay = document.getElementById('gameOverlay');
        const overlayTitle = document.getElementById('overlayTitle');
        const overlaySub = document.getElementById('overlaySub');
        const overlayHint = document.getElementById('overlayHint');
        const overlayBottomHint = document.getElementById('overlayBottomHint');

        const hudLevel = document.getElementById('hudLevel');
        const hudMaxLevel = document.getElementById('hudMaxLevel');
        const hudDeaths = document.getElementById('hudDeaths');
        const hudBest = document.getElementById('hudBest');
        const hudSeed = document.getElementById('hudSeed');
        const hudSpeed = document.getElementById('hudSpeed');
        const hudTraps = document.getElementById('hudTraps');

        const MAX_LEVEL = 5;
        hudMaxLevel.textContent = String(MAX_LEVEL);

        const GROUND_Y = canvas.height - 60;
        const GRAVITY = 0.55;
        const JUMP_VELOCITY = -11.5;

        let state = {
            running: false,
            inMenu: true,
            gameOver: false,
            win: false,
            level: 1,
            deaths: 0,
            bestLevel: 0,
            seedBase: Math.floor(Math.random() * 1_000_000),
            seedOffset: 0,
            time: 0,
            scrollX: 0,
            levelLength: 2600,
            speed: 4,
            spikes: [],
            goalX: 2400,
            player: {
                x: 120,
                y: GROUND_Y - 32,
                w: 26,
                h: 32,
                vy: 0,
                grounded: true,
                jumpHeld: false
            }
        };

        function mulberry32(a) {
            return function () {
                let t = a += 0x6D2B79F5;
                t = Math.imul(t ^ t >>> 15, t | 1);
                t ^= t + Math.imul(t ^ t >>> 7, t | 61);
                return ((t ^ t >>> 14) >>> 0) / 4294967296;
            };
        }

        function reseedForLevel(level) {
            const seed = (state.seedBase + level * 9973 + state.seedOffset) >>> 0;
            const rng = mulberry32(seed);
            hudSeed.textContent = String(seed);
            return rng;
        }

        function generateLevel(level) {
            const rng = reseedForLevel(level);

            const baseSpeed = 3.4 + level * 0.6;
            const length = 2200 + level * 400;
            const spikeCount = 12 + level * 4;

            const spikes = [];
            const minX = 360;
            const maxX = length - 260;

            for (let i = 0; i < spikeCount; i++) {
                const t = rng();
                const x = minX + t * (maxX - minX);
                const width = 30 + rng() * 20;
                const height = 24 + rng() * 16;

                const fakeGap = rng() < 0.18;
                spikes.push({
                    x,
                    w: width,
                    h: height,
                    fakeGap
                });
            }

            spikes.sort((a, b) => a.x - b.x);

            const lastSpikeX = spikes.length ? spikes[spikes.length - 1].x : maxX;
            const goalX = Math.max(lastSpikeX + 220, length - 160);

            const extraSpeed = (Math.random() < 0.25 ? 0.5 : 0);

            state.level = level;
            state.speed = baseSpeed + extraSpeed;
            state.levelLength = length;
            state.spikes = spikes;
            state.goalX = goalX;
            state.scrollX = 0;
            state.time = 0;
            state.player.x = 120;
            state.player.y = GROUND_Y - state.player.h;
            state.player.vy = 0;
            state.player.grounded = true;
            state.player.jumpHeld = false;

            hudLevel.textContent = String(level);
            hudSpeed.textContent = state.speed.toFixed(1) + 'u';
            hudTraps.textContent = String(spikes.length);
        }

        function rectsCollide(a, b) {
            return !(
                a.x + a.w <= b.x ||
                a.x >= b.x + b.w ||
                a.y + a.h <= b.y ||
                a.y >= b.y + b.h
            );
        }

        function update(dt) {
            state.time += dt;
            state.scrollX += state.speed;

            const p = state.player;

            if (!p.grounded) {
                p.vy += GRAVITY;
            }
            const dy = p.vy;
            p.y += dy;

            if (p.y + p.h >= GROUND_Y) {
                p.y = GROUND_Y - p.h;
                p.vy = 0;
                p.grounded = true;
            } else {
                p.grounded = false;
            }

            const worldX = state.scrollX + p.x;

            for (const spike of state.spikes) {
                const sx = spike.x - state.scrollX;
                if (sx + spike.w < p.x - 40) continue;
                if (sx - spike.w > p.x + 80) break;

                if (spike.fakeGap) {
                    const fakeTop = {
                        x: sx,
                        y: GROUND_Y - spike.h,
                        w: spike.w,
                        h: 6
                    };
                    if (rectsCollide({x: p.x, y: p.y, w: p.w, h: p.h}, fakeTop)) {
                        p.vy = JUMP_VELOCITY * 0.6;
                    }
                    continue;
                }

                const hitbox = {
                    x: sx,
                    y: GROUND_Y - spike.h,
                    w: spike.w,
                    h: spike.h
                };

                if (rectsCollide({x: p.x, y: p.y, w: p.w, h: p.h}, hitbox)) {
                    onDeath();
                    return;
                }
            }

            const goalHitbox = {
                x: state.goalX - state.scrollX,
                y: GROUND_Y - 40,
                w: 40,
                h: 40
            };

            if (rectsCollide({x: p.x, y: p.y, w: p.w, h: p.h}, goalHitbox)) {
                onLevelComplete();
            }

            if (worldX > state.levelLength + 480) {
                onDeath();
            }
        }

        function draw() {
            ctx.clearRect(0, 0, canvas.width, canvas.height);

            const gradient = ctx.createLinearGradient(0, 0, 0, canvas.height);
            gradient.addColorStop(0, '#020617');
            gradient.addColorStop(0.55, '#020617');
            gradient.addColorStop(0.56, '#0f172a');
            gradient.addColorStop(1, '#020617');
            ctx.fillStyle = gradient;
            ctx.fillRect(0, 0, canvas.width, canvas.height);

            for (let i = 0; i < 3; i++) {
                const baseY = 60 + i * 40;
                ctx.strokeStyle = `rgba(148,163,184,${0.12 + i * 0.08})`;
                ctx.lineWidth = 1;
                ctx.beginPath();
                const offset = (state.scrollX * (0.15 + i * 0.06)) % 40;
                for (let x = -40; x < canvas.width + 40; x += 40) {
                    ctx.moveTo(x + offset, baseY);
                    ctx.lineTo(x + 12 + offset, baseY + 6);
                    ctx.lineTo(x + 26 + offset, baseY);
                }
                ctx.stroke();
            }

            ctx.fillStyle = '#020617';
            ctx.fillRect(0, GROUND_Y, canvas.width, canvas.height - GROUND_Y);

            ctx.strokeStyle = '#1e293b';
            ctx.lineWidth = 2;
            ctx.beginPath();
            ctx.moveTo(0, GROUND_Y + 1);
            ctx.lineTo(canvas.width, GROUND_Y + 1);
            ctx.stroke();

            for (let i = 0; i < 2; i++) {
                const offset = (state.scrollX * (0.25 + i * 0.12)) % 160;
                ctx.strokeStyle = `rgba(55,65,81,${0.3 + i * 0.25})`;
                ctx.beginPath();
                for (let x = -offset; x < canvas.width + 80; x += 80) {
                    ctx.moveTo(x, GROUND_Y + 18 + i * 10);
                    ctx.lineTo(x + 40, GROUND_Y + 10 + i * 10);
                    ctx.lineTo(x + 80, GROUND_Y + 18 + i * 10);
                }
                ctx.stroke();
            }

            ctx.save();
            ctx.translate(-state.scrollX, 0);

            for (const spike of state.spikes) {
                if (spike.fakeGap) {
                    ctx.fillStyle = 'rgba(148,163,184,0.32)';
                    ctx.fillRect(spike.x, GROUND_Y - 4, spike.w, 4);
                    ctx.fillStyle = 'rgba(248,250,252,0.08)';
                    ctx.fillRect(spike.x, GROUND_Y - 18, spike.w, 14);
                    continue;
                }

                const x = spike.x;
                const w = spike.w;
                const h = spike.h;

                ctx.fillStyle = '#0f172a';
                ctx.fillRect(x, GROUND_Y - h, w, h);

                const peakCount = Math.max(2, Math.round(w / 12));
                const step = w / peakCount;
                ctx.fillStyle = '#f97373';
                ctx.beginPath();
                ctx.moveTo(x, GROUND_Y);
                for (let i = 0; i < peakCount; i++) {
                    const px = x + i * step + step / 2;
                    ctx.lineTo(px, GROUND_Y - h - 6);
                    ctx.lineTo(x + (i + 1) * step, GROUND_Y);
                }
                ctx.closePath();
                ctx.fill();

                const glowGradient = ctx.createLinearGradient(x, GROUND_Y - h - 14, x, GROUND_Y);
                glowGradient.addColorStop(0, 'rgba(248,113,113,0.75)');
                glowGradient.addColorStop(1, 'rgba(248,113,113,0)');
                ctx.fillStyle = glowGradient;
                ctx.fillRect(x - 4, GROUND_Y - h - 14, w + 8, h + 18);
            }

            const goalX = state.goalX;
            ctx.save();
            ctx.translate(goalX, 0);
            ctx.fillStyle = '#0f172a';
            ctx.fillRect(-6, GROUND_Y - 44, 12, 44);

            const portalGradient = ctx.createLinearGradient(0, GROUND_Y - 56, 0, GROUND_Y - 4);
            portalGradient.addColorStop(0, '#a855f7');
            portalGradient.addColorStop(0.5, '#38bdf8');
            portalGradient.addColorStop(1, '#22c55e');
            ctx.fillStyle = portalGradient;
            ctx.beginPath();
            ctx.moveTo(-18, GROUND_Y - 4);
            ctx.quadraticCurveTo(0, GROUND_Y - 70, 18, GROUND_Y - 4);
            ctx.closePath();
            ctx.fill();

            ctx.globalAlpha = 0.4 + 0.2 * Math.sin(state.time * 0.012);
            ctx.strokeStyle = '#e5e7eb';
            ctx.lineWidth = 2;
            ctx.beginPath();
            ctx.moveTo(-22, GROUND_Y - 2);
            ctx.quadraticCurveTo(0, GROUND_Y - 78, 22, GROUND_Y - 2);
            ctx.stroke();
            ctx.restore();

            ctx.restore();

            const p = state.player;
            ctx.save();
            ctx.translate(p.x, p.y);

            const glow = ctx.createLinearGradient(0, 0, 0, p.h + 16);
            glow.addColorStop(0, 'rgba(56,189,248,0.4)');
            glow.addColorStop(1, 'rgba(56,189,248,0)');
            ctx.fillStyle = glow;
            ctx.fillRect(-6, -10, p.w + 12, p.h + 18);

            const bodyGradient = ctx.createLinearGradient(0, 0, 0, p.h);
            bodyGradient.addColorStop(0, '#38bdf8');
            bodyGradient.addColorStop(1, '#0ea5e9');
            ctx.fillStyle = bodyGradient;
            ctx.fillRect(0, 0, p.w, p.h);

            ctx.fillStyle = '#0f172a';
            ctx.fillRect(5, 6, 7, 6);
            ctx.fillRect(p.w - 12, 6, 7, 6);

            ctx.fillStyle = '#082f49';
            ctx.fillRect(7, 18, p.w - 14, 6);

            ctx.restore();
        }

        let lastTs = 0;

        function loop(ts) {
            const dt = Math.min(32, ts - lastTs || 16);
            lastTs = ts;

            if (state.running) {
                update(dt);
            }

            draw();
            requestAnimationFrame(loop);
        }

        function showOverlay(opts) {
            overlay.style.opacity = '1';
            overlay.style.pointerEvents = opts.interactive ? 'auto' : 'none';
            overlayTitle.textContent = opts.title;
            overlaySub.textContent = opts.sub;
            overlayHint.innerHTML = opts.hint;
            overlayBottomHint.textContent = opts.bottomHint;
        }

        function hideOverlay() {
            overlay.style.opacity = '0';
            overlay.style.pointerEvents = 'none';
        }

        function resetToLevel(level) {
            state.running = false;
            state.gameOver = false;
            state.win = false;
            state.inMenu = false;
            generateLevel(level);
            hideOverlay();
        }

        function onDeath() {
            state.running = false;
            state.gameOver = true;
            state.deaths += 1;
            hudDeaths.textContent = String(state.deaths);

            showOverlay({
                interactive: true,
                title: 'You died on Level ' + state.level,
                sub: 'The spikes were faster than your reflexes. Try again or reroll.',
                hint: '<span>R</span> restart · <span>SPACE</span> continue · <span>Q</span> quit to title',
                bottomHint: 'Hint: Some gaps are fake. Jump a beat earlier than you think.'
            });
        }

        function onLevelComplete() {
            state.running = false;
            state.gameOver = false;
            state.win = state.level >= MAX_LEVEL;

            if (state.level > state.bestLevel) {
                state.bestLevel = state.level;
                hudBest.textContent = 'Lv. ' + state.bestLevel;
            }

            if (state.win) {
                showOverlay({
                    interactive: true,
                    title: 'You cleared all ' + MAX_LEVEL + ' levels!',
                    sub: 'Level Devil grants you temporary mercy. Reload to reroll everything.',
                    hint: '<span>SPACE</span> play again from level 1 · <span>Q</span> quit to title',
                    bottomHint: 'For extra pain, increase MAX_LEVEL or speed in the source.'
                });
            } else {
                showOverlay({
                    interactive: true,
                    title: 'Level ' + state.level + ' cleared!',
                    sub: 'Spikes reroll and speed ramps up on the next level.',
                    hint: '<span>SPACE</span> next level · <span>R</span> replay level · <span>Q</span> quit to title',
                    bottomHint: 'Each level is seeded from a base RNG; reload the page for a new run.'
                });
            }
        }

        function showTitleScreen() {
            state.running = false;
            state.inMenu = true;
            state.gameOver = false;
            state.win = false;

            showOverlay({
                interactive: true,
                title: 'Press SPACE to start',
                sub: 'Survive 5 levels of randomized spike patterns with a single direction runner.',
                hint: '<span>SPACE</span> start · <span>R</span> reroll seeds · <span>Q</span> relax instead',
                bottomHint: 'Built as a Java webapp front-end. All logic runs in this page.'
            });
        }

        function startRun(fromLevel) {
            resetToLevel(fromLevel);
            state.running = true;
        }

        window.addEventListener('keydown', function (e) {
            if (e.code === 'Space') {
                e.preventDefault();
            }

            if (state.inMenu) {
                if (e.code === 'Space') {
                    startRun(1);
                } else if (e.key === 'r' || e.key === 'R') {
                    state.seedBase = Math.floor(Math.random() * 1_000_000);
                    state.seedOffset++;
                    showTitleScreen();
                } else if (e.key === 'q' || e.key === 'Q') {
                    showTitleScreen();
                }
                return;
            }

            if ((state.gameOver || state.win) && !state.running) {
                if (e.code === 'Space') {
                    if (state.win) {
                        startRun(1);
                    } else {
                        startRun(state.level);
                    }
                } else if (e.key === 'r' || e.key === 'R') {
                    startRun(state.level);
                } else if (e.key === 'q' || e.key === 'Q') {
                    showTitleScreen();
                }
                return;
            }

            if (e.key === 'q' || e.key === 'Q') {
                showTitleScreen();
                return;
            }

            if (e.key === 'r' || e.key === 'R') {
                startRun(state.level);
                return;
            }

            if (e.code === 'Space') {
                const p = state.player;
                if (p.grounded) {
                    p.vy = JUMP_VELOCITY;
                    p.grounded = false;
                    p.jumpHeld = true;
                } else if (p.vy < 0) {
                    p.vy += JUMP_VELOCITY * -0.08;
                }
            }
        });

        window.addEventListener('keyup', function (e) {
            if (e.code === 'Space') {
                state.player.jumpHeld = false;
            }
        });

        showTitleScreen();
        requestAnimationFrame(loop);
    })();
</script>
</body>
</html>
