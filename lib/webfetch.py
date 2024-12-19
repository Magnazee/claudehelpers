#!/usr/bin/env python3
import argparse
import sys
import asyncio
from playwright.async_api import async_playwright
import httpx
from bs4 import BeautifulSoup
from urllib.parse import urlparse
import logging

logging.basicConfig(level=logging.INFO, format='%(message)s')
logger = logging.getLogger(__name__)

async def fetch_with_browser(url, selector=None, timeout=30000):
    """Fetch content using browser automation for JavaScript-rendered pages."""
    async with async_playwright() as p:
        browser = await p.chromium.launch()
        page = await browser.new_page()
        try:
            logger.info("Fetching with browser automation...")
            await page.goto(url, wait_until='networkidle')
            
            if selector:
                logger.info(f"Waiting for selector: {selector}")
                await page.wait_for_selector(selector, timeout=timeout)
            else:
                # Wait for any main content
                await page.wait_for_selector('main, article, .content, #content', timeout=timeout)
            
            content = await page.content()
            return content
        finally:
            await browser.close()

async def fetch_webpage_content(url, selector=None, timeout=30000):
    """Fetch webpage content using either direct HTTP requests or browser automation."""
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
    }
    
    # First try direct HTTP request
    async with httpx.AsyncClient() as client:
        try:
            logger.info("Attempting direct HTTP request...")
            response = await client.get(url, headers=headers, follow_redirects=True)
            response.raise_for_status()
            
            if selector and selector not in response.text:
                logger.info("Required content not found in direct response, trying browser automation...")
                return await fetch_with_browser(url, selector, timeout)
            
            return response.text
        except Exception as e:
            logger.info(f"Direct request failed ({str(e)}), trying browser automation...")
            return await fetch_with_browser(url, selector, timeout)

def extract_content(html_content, selector=None):
    """Extract relevant content from HTML."""
    soup = BeautifulSoup(html_content, 'html.parser')
    
    if selector:
        content = soup.select_one(selector)
    else:
        content = soup.select_one('main, article, .content, #content')
    
    if content:
        return content.get_text(separator='\n', strip=True)
    return html_content

async def main(url, selector=None, output=None, timeout=30000, raw=False):
    try:
        content = await fetch_webpage_content(url, selector, timeout)
        
        if not raw:
            content = extract_content(content, selector)
        
        if output:
            with open(output, 'w', encoding='utf-8') as f:
                f.write(content)
            logger.info(f"Content saved to {output}")
        else:
            print(content)
            
    except Exception as e:
        logger.error(f"Error: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Fetch web content with support for JavaScript-rendered pages")
    parser.add_argument("url", help="URL to fetch")
    parser.add_argument("-s", "--selector", help="CSS selector to target specific content")
    parser.add_argument("-o", "--output", help="Output file (prints to stdout if not specified)")
    parser.add_argument("-t", "--timeout", type=int, default=30000, help="Timeout in milliseconds (default: 30000)")
    parser.add_argument("--raw", action="store_true", help="Output raw HTML instead of extracted text")
    
    args = parser.parse_args()
    
    asyncio.run(main(
        url=args.url,
        selector=args.selector,
        output=args.output,
        timeout=args.timeout,
        raw=args.raw
    ))
