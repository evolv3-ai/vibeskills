/**
 * Hyperbrowser SDK - Scraping Examples
 *
 * Run: npx tsx sdk-scraping.ts
 * Required: HYPERBROWSER_API_KEY in .env
 */

import { Hyperbrowser } from "@hyperbrowser/sdk";
import { config } from "dotenv";

config();

const hb = new Hyperbrowser({
  apiKey: process.env.HYPERBROWSER_API_KEY,
});

// Example 1: Simple page scrape
async function simpleScrape() {
  console.log("=== Simple Scrape ===");

  const result = await hb.scrape.startAndWait({
    url: "https://news.ycombinator.com",
    scrapeOptions: {
      formats: ["markdown"],
      onlyMainContent: true,
    },
  });

  console.log("Markdown content:");
  console.log(result.data?.markdown?.slice(0, 500));
}

// Example 2: Scrape with all formats
async function multiFormatScrape() {
  console.log("\n=== Multi-Format Scrape ===");

  const result = await hb.scrape.startAndWait({
    url: "https://example.com",
    scrapeOptions: {
      formats: ["markdown", "html", "links", "screenshot"],
      waitFor: 2000,  // Wait for JS to render
    },
  });

  console.log("Formats received:");
  console.log("- Markdown:", result.data?.markdown ? "Yes" : "No");
  console.log("- HTML:", result.data?.html ? "Yes" : "No");
  console.log("- Links:", result.data?.links?.length || 0, "links found");
  console.log("- Screenshot:", result.data?.screenshot ? "Yes" : "No");
}

// Example 3: Scrape with stealth options
async function stealthScrape() {
  console.log("\n=== Stealth Scrape ===");

  const result = await hb.scrape.startAndWait({
    url: "https://httpbin.org/headers",
    scrapeOptions: {
      formats: ["html"],
    },
    sessionOptions: {
      useStealth: true,
      useProxy: true,
      proxyCountry: "US",
    },
  });

  console.log("Headers page content:");
  console.log(result.data?.html?.slice(0, 300));
}

// Example 4: Batch scrape multiple URLs
async function batchScrape() {
  console.log("\n=== Batch Scrape ===");

  const urls = [
    "https://example.com",
    "https://httpbin.org/html",
    "https://news.ycombinator.com",
  ];

  const result = await hb.scrape.batch.startAndWait({
    urls,
    scrapeOptions: {
      formats: ["markdown"],
      onlyMainContent: true,
    },
  });

  console.log(`Scraped ${result.data?.length || 0} pages:`);
  for (const page of result.data || []) {
    console.log(`- ${page.url}: ${page.markdown?.length || 0} chars`);
  }
}

// Example 5: Scrape with screenshot options
async function screenshotScrape() {
  console.log("\n=== Screenshot Scrape ===");

  const result = await hb.scrape.startAndWait({
    url: "https://example.com",
    scrapeOptions: {
      formats: ["screenshot"],
      screenshotOptions: {
        fullPage: true,
        format: "png",
      },
    },
  });

  if (result.data?.screenshot) {
    // Screenshot is base64 encoded
    console.log("Screenshot captured, base64 length:", result.data.screenshot.length);

    // To save:
    // import fs from "fs";
    // fs.writeFileSync("screenshot.png", Buffer.from(result.data.screenshot, "base64"));
  }
}

// Run all examples
async function main() {
  try {
    await simpleScrape();
    await multiFormatScrape();
    await stealthScrape();
    await batchScrape();
    await screenshotScrape();
  } catch (error) {
    console.error("Error:", error);
  }
}

main();
