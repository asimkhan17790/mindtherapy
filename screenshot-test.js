const { chromium } = require('playwright');

async function tap(page, x, y) {
  await page.evaluate(({ x, y }) => {
    const el = document.querySelector('flt-glass-pane') || document.body;
    ['pointerdown', 'pointermove', 'pointerup'].forEach((type, i) => {
      setTimeout(() => el.dispatchEvent(new PointerEvent(type, {
        clientX: x, clientY: y, bubbles: true, cancelable: true,
        pointerId: 1, isPrimary: true, pressure: type === 'pointerup' ? 0 : 0.5,
      })), i * 30);
    });
  }, { x, y });
  await page.waitForTimeout(400);
}

(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();
  await page.setViewportSize({ width: 1280, height: 900 });

  // ─── 01 Login ───────────────────────────────────────────────────
  await page.goto('http://127.0.0.1:8081');
  await page.waitForTimeout(4000);
  await page.screenshot({ path: 'screenshots/01-login.png' });
  console.log('✓ Login');

  // ─── Tap "Continue as guest" button (~640, 771) ──────────────────
  await tap(page, 640, 771);
  await page.waitForTimeout(3000);

  // ─── 02 Home (Today tab) ────────────────────────────────────────
  await page.screenshot({ path: 'screenshots/02-home.png' });
  console.log('✓ Home');

  // ─── 03 Trends tab ──────────────────────────────────────────────
  // Tab bar at bottom: 4 tabs in ~1280px wide. Each ~320px. Centers: 160, 480, 800, 1120
  await tap(page, 480, 865);
  await page.waitForTimeout(5000);
  await page.screenshot({ path: 'screenshots/03-trends.png' });
  console.log('✓ Trends');

  // ─── 04 Library tab ─────────────────────────────────────────────
  await tap(page, 800, 865);
  await page.waitForTimeout(2000);
  await page.screenshot({ path: 'screenshots/04-library.png' });
  console.log('✓ Library');

  // ─── 05 Profile (Me) tab ────────────────────────────────────────
  await tap(page, 1120, 865);
  await page.waitForTimeout(2000);
  await page.screenshot({ path: 'screenshots/05-profile.png' });
  console.log('✓ Profile');

  // ─── 06 Mood screen ─────────────────────────────────────────────
  await tap(page, 160, 865); // back to Today
  await page.waitForTimeout(1500);
  // Try tapping "See all 10 ›" at multiple y offsets
  await tap(page, 988, 430);
  await page.waitForTimeout(500);
  await tap(page, 988, 444);
  await page.waitForTimeout(500);
  await tap(page, 988, 455);
  await page.waitForTimeout(3000);
  await page.screenshot({ path: 'screenshots/06-mood.png' });
  console.log('✓ Mood');

  await browser.close();
  console.log('\nAll screenshots saved to screenshots/');
})().catch(e => { console.error('Error:', e.message); process.exit(1); });
