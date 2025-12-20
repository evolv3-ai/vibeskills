/**
 * Hyperbrowser SDK - Data Extraction Examples
 *
 * Run: npx tsx sdk-extraction.ts
 * Required: HYPERBROWSER_API_KEY in .env
 */

import { Hyperbrowser } from "@hyperbrowser/sdk";
import { z } from "zod";
import { config } from "dotenv";

config();

const hb = new Hyperbrowser({
  apiKey: process.env.HYPERBROWSER_API_KEY,
});

// Example 1: Extract structured data with Zod schema
async function extractWithSchema() {
  console.log("=== Extract with Zod Schema ===");

  const HackerNewsSchema = z.object({
    stories: z.array(z.object({
      title: z.string().describe("The story title"),
      url: z.string().describe("Link to the story"),
      points: z.number().describe("Number of points/upvotes"),
      author: z.string().describe("Username of submitter"),
    })).describe("Top stories from the front page"),
  });

  const result = await hb.extract.startAndWait({
    urls: ["https://news.ycombinator.com"],
    prompt: "Extract the top 5 stories from the front page",
    schema: HackerNewsSchema,
  });

  const data = result.data as z.infer<typeof HackerNewsSchema>;
  console.log("Extracted stories:");
  for (const story of data.stories) {
    console.log(`- ${story.title} (${story.points} pts by ${story.author})`);
  }
}

// Example 2: Extract product information
async function extractProductInfo() {
  console.log("\n=== Extract Product Info ===");

  const ProductSchema = z.object({
    name: z.string().describe("Product name"),
    description: z.string().describe("Product description"),
    price: z.string().describe("Current price"),
    availability: z.string().describe("Stock status"),
    features: z.array(z.string()).describe("Key product features"),
  });

  // Note: Replace with actual product URL
  const result = await hb.extract.startAndWait({
    urls: ["https://example.com/product"],
    prompt: "Extract all product details from this page",
    schema: ProductSchema,
    sessionOptions: {
      useStealth: true,
      acceptCookies: true,
    },
  });

  console.log("Product data:", result.data);
}

// Example 3: Extract from multiple URLs
async function extractFromMultipleUrls() {
  console.log("\n=== Extract from Multiple URLs ===");

  const ArticleSchema = z.object({
    title: z.string(),
    author: z.string().optional(),
    date: z.string().optional(),
    summary: z.string().describe("Brief summary of the article"),
  });

  const urls = [
    "https://example.com/article1",
    "https://example.com/article2",
  ];

  const result = await hb.extract.startAndWait({
    urls,
    prompt: "Extract article metadata and a brief summary",
    schema: ArticleSchema,
  });

  console.log("Extracted articles:", result.data);
}

// Example 4: Extract with custom prompt (no schema)
async function extractWithPromptOnly() {
  console.log("\n=== Extract with Prompt Only ===");

  const result = await hb.extract.startAndWait({
    urls: ["https://news.ycombinator.com"],
    prompt: "What are the main topics being discussed on this page today? Provide a brief summary.",
  });

  console.log("Summary:", result.data);
}

// Example 5: Extract contact information
async function extractContactInfo() {
  console.log("\n=== Extract Contact Info ===");

  const ContactSchema = z.object({
    companyName: z.string().describe("Name of the company"),
    email: z.string().optional().describe("Contact email if available"),
    phone: z.string().optional().describe("Phone number if available"),
    address: z.string().optional().describe("Physical address if available"),
    socialLinks: z.array(z.object({
      platform: z.string(),
      url: z.string(),
    })).optional().describe("Social media links"),
  });

  const result = await hb.extract.startAndWait({
    urls: ["https://example.com/contact"],
    prompt: "Extract all contact information from this page",
    schema: ContactSchema,
  });

  console.log("Contact info:", result.data);
}

// Example 6: Extract with wait and session options
async function extractWithOptions() {
  console.log("\n=== Extract with Options ===");

  const DataSchema = z.object({
    items: z.array(z.object({
      name: z.string(),
      value: z.string(),
    })),
  });

  const result = await hb.extract.startAndWait({
    urls: ["https://example.com/dynamic-content"],
    prompt: "Extract all data items from the page",
    schema: DataSchema,
    waitFor: 5000,  // Wait 5s for JS to load
    sessionOptions: {
      useStealth: true,
      useProxy: true,
      acceptCookies: true,
      adblock: true,
    },
  });

  console.log("Extracted items:", result.data);
}

// Run examples
async function main() {
  try {
    await extractWithSchema();
    // Uncomment to run other examples:
    // await extractProductInfo();
    // await extractFromMultipleUrls();
    // await extractWithPromptOnly();
    // await extractContactInfo();
    // await extractWithOptions();
  } catch (error) {
    console.error("Error:", error);
  }
}

main();
