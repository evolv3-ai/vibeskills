/**
 * Hyperbrowser SDK - Crawling Examples
 *
 * Run: npx tsx sdk-crawling.ts
 * Required: HYPERBROWSER_API_KEY in .env
 */

import { Hyperbrowser } from "@hyperbrowser/sdk";
import { config } from "dotenv";

config();

const hb = new Hyperbrowser({
  apiKey: process.env.HYPERBROWSER_API_KEY,
});

// Example 1: Basic crawl
async function basicCrawl() {
  console.log("=== Basic Crawl ===");

  const result = await hb.crawl.startAndWait({
    url: "https://example.com",
    maxPages: 5,
    followLinks: true,
    scrapeOptions: {
      formats: ["markdown"],
      onlyMainContent: true,
    },
  });

  console.log(`Crawled ${result.totalCrawledPages} pages:`);
  for (const page of result.data || []) {
    console.log(`- ${page.url}`);
    console.log(`  Content: ${page.markdown?.slice(0, 100)}...`);
  }
}

// Example 2: Crawl with URL patterns
async function crawlWithPatterns() {
  console.log("\n=== Crawl with URL Patterns ===");

  const result = await hb.crawl.startAndWait({
    url: "https://docs.example.com",
    maxPages: 20,
    followLinks: true,
    includePatterns: [
      "/docs/*",
      "/guide/*",
      "/api/*",
    ],
    excludePatterns: [
      "/blog/*",
      "/changelog/*",
      "*.pdf",
    ],
    scrapeOptions: {
      formats: ["markdown"],
      onlyMainContent: true,
    },
  });

  console.log(`Crawled ${result.totalCrawledPages} documentation pages`);
  for (const page of result.data || []) {
    console.log(`- ${page.url}: ${page.markdown?.length || 0} chars`);
  }
}

// Example 3: Crawl with sitemap
async function crawlWithSitemap() {
  console.log("\n=== Crawl with Sitemap ===");

  const result = await hb.crawl.startAndWait({
    url: "https://example.com",
    maxPages: 50,
    ignoreSitemap: false,  // Use sitemap.xml if available
    scrapeOptions: {
      formats: ["markdown", "links"],
    },
  });

  console.log(`Found ${result.totalCrawledPages} pages from sitemap`);
}

// Example 4: Crawl with stealth options
async function stealthCrawl() {
  console.log("\n=== Stealth Crawl ===");

  const result = await hb.crawl.startAndWait({
    url: "https://example.com",
    maxPages: 10,
    followLinks: true,
    scrapeOptions: {
      formats: ["markdown"],
      waitFor: 2000,
    },
    sessionOptions: {
      useStealth: true,
      useProxy: true,
      acceptCookies: true,
      adblock: true,
      annoyances: true,
    },
  });

  console.log(`Stealthily crawled ${result.totalCrawledPages} pages`);
}

// Example 5: Crawl and collect all links
async function crawlAndCollectLinks() {
  console.log("\n=== Crawl and Collect Links ===");

  const result = await hb.crawl.startAndWait({
    url: "https://example.com",
    maxPages: 10,
    followLinks: true,
    scrapeOptions: {
      formats: ["links"],
    },
  });

  const allLinks = new Set<string>();
  for (const page of result.data || []) {
    for (const link of page.links || []) {
      allLinks.add(link);
    }
  }

  console.log(`Found ${allLinks.size} unique links across ${result.totalCrawledPages} pages`);
  console.log("Sample links:");
  Array.from(allLinks).slice(0, 10).forEach(link => console.log(`- ${link}`));
}

// Example 6: Monitor crawl progress (non-blocking)
async function crawlWithProgress() {
  console.log("\n=== Crawl with Progress Monitoring ===");

  // Start crawl (non-blocking)
  const { jobId } = await hb.crawl.start({
    url: "https://example.com",
    maxPages: 20,
    followLinks: true,
    scrapeOptions: {
      formats: ["markdown"],
    },
  });

  console.log(`Started crawl job: ${jobId}`);

  // Poll for status
  let status = await hb.crawl.getStatus(jobId);
  while (status.status === "running" || status.status === "pending") {
    console.log(`Progress: ${status.totalCrawledPages} pages crawled...`);
    await new Promise(r => setTimeout(r, 2000));
    status = await hb.crawl.getStatus(jobId);
  }

  // Get final results
  const result = await hb.crawl.get(jobId);
  console.log(`Completed! Total pages: ${result.totalCrawledPages}`);
}

// Run examples
async function main() {
  try {
    await basicCrawl();
    // Uncomment to run other examples:
    // await crawlWithPatterns();
    // await crawlWithSitemap();
    // await stealthCrawl();
    // await crawlAndCollectLinks();
    // await crawlWithProgress();
  } catch (error) {
    console.error("Error:", error);
  }
}

main();
