"""Run against a locally served generated site. Browser install is separate."""
import asyncio,json,os,subprocess,sys,time,urllib.request
from pathlib import Path
from playwright.async_api import async_playwright
ROOT=Path(__file__).resolve().parents[1]
async def main():
    async with async_playwright() as p:
        options={'headless':True}
        if os.environ.get('CHROME_BIN'):options['executable_path']=os.environ['CHROME_BIN']
        browser=await p.chromium.launch(**options)
        page=await browser.new_page(viewport={'width':1440,'height':1000})
        errors=[];page.on('pageerror',lambda e:errors.append(str(e)))
        await page.goto('http://127.0.0.1:8080');await page.locator('.card').first.wait_for()
        assert await page.locator('.card').count()==5
        await page.get_by_role('button',name='Models & visuals').click()
        assert await page.locator('.card').count()==1
        await page.get_by_role('button',name='Field guide').click()
        assert await page.locator('dialog').is_visible()
        assert 'signalkeepers' in await page.locator('#detail-content').inner_text()
        await page.keyboard.press('Escape')
        await page.get_by_role('button',name='Everything',exact=True).click()
        await page.get_by_role('searchbox').fill('no such pack')
        assert await page.locator('.card').count()==0
        await page.get_by_role('searchbox').fill('')
        async with page.expect_download() as info:await page.locator('.card-actions a').first.click()
        dl=await info.value;assert dl.suggested_filename=='signalkeepers-0.1.0-java-1.21.1.zip'
        await page.get_by_role('searchbox').fill('Fieldcraft')
        await page.route('**/downloads/fieldcraft-*.zip',lambda route:route.fulfill(body=b'corrupted archive',content_type='application/zip'))
        await page.locator('.card-actions a').click()
        await page.get_by_role('status').filter(has_text='Checksum mismatch').wait_for()
        await page.unroute('**/downloads/fieldcraft-*.zip')
        async with page.expect_download():await page.locator('.card-actions a').click()
        await page.get_by_role('searchbox').fill('')
        (ROOT/'verification').mkdir(exist_ok=True)
        await page.screenshot(path=str(ROOT/'verification/catalog-desktop.png'),full_page=True)
        await page.set_viewport_size({'width':390,'height':844})
        assert await page.evaluate('document.documentElement.scrollWidth <= window.innerWidth')
        await page.screenshot(path=str(ROOT/'verification/catalog-mobile.png'),full_page=True)
        assert not errors,errors
        (ROOT/'verification/web-results.json').write_text(json.dumps({'passed':True,'checks':['five cards','type filtering','dialog and Escape','empty search','download filename','mobile overflow','no JS errors','browser blocks corrupted archive'],'viewports':[1440,390]},indent=2)+'\n')
        await browser.close()
        print('Website desktop/mobile, filtering, details, search, ZIP download and JS checks passed.')
if __name__=='__main__':
    server=subprocess.Popen([sys.executable,'-m','http.server','8080','--bind','127.0.0.1','--directory',str(ROOT/'site')],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
    try:
        for _ in range(50):
            try:
                urllib.request.urlopen('http://127.0.0.1:8080',timeout=1).close();break
            except OSError:time.sleep(.1)
        asyncio.run(main())
    finally:
        server.terminate();server.wait(timeout=5)
