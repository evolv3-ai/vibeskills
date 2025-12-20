/**
 * HyperAgent - Data Extraction Examples
 *
 * Run: npx tsx hyperagent-extract.ts
 * Required: OPENAI_API_KEY (or other LLM provider key) in .env
 */

import { HyperAgent } from "@hyperbrowser/agent";
import { z } from "zod";
import { config } from "dotenv";

config();

// Example 1: Basic extraction with Zod schema
async function basicExtraction() {
  console.log("=== Basic Extraction ===");

  const agent = new HyperAgent({
    llm: { provider: "openai", model: "gpt-4o" },
  });

  const StorySchema = z.object({
    stories: z.array(z.object({
      title: z.string().describe("The story headline"),
      points: z.number().describe("Number of upvotes"),
      comments: z.number().describe("Number of comments"),
    })),
  });

  try {
    const page = await agent.newPage();
    await page.goto("https://news.ycombinator.com");

    const data = await page.extract(
      "Extract the top 5 stories with their points and comment counts",
      StorySchema
    );

    console.log("Extracted stories:");
    for (const story of data.stories) {
      console.log(`- ${story.title} (${story.points} pts, ${story.comments} comments)`);
    }
  } finally {
    await agent.closeAgent();
  }
}

// Example 2: Extract product information
async function extractProductInfo() {
  console.log("\n=== Extract Product Info ===");

  const ProductSchema = z.object({
    name: z.string(),
    price: z.number(),
    currency: z.string(),
    rating: z.number().optional(),
    reviewCount: z.number().optional(),
    availability: z.enum(["in_stock", "out_of_stock", "limited"]),
    features: z.array(z.string()),
  });

  const agent = new HyperAgent({
    llm: { provider: "openai", model: "gpt-4o" },
  });

  try {
    const page = await agent.newPage();
    // Note: Replace with actual product URL
    await page.goto("https://example.com/product");

    const product = await page.extract(
      "Extract all product details including price, rating, and features",
      ProductSchema
    );

    console.log("Product:", product);
  } finally {
    await agent.closeAgent();
  }
}

// Example 3: Extract after navigation
async function extractAfterNavigation() {
  console.log("\n=== Extract After Navigation ===");

  const FlightSchema = z.object({
    flights: z.array(z.object({
      airline: z.string(),
      departure: z.string(),
      arrival: z.string(),
      duration: z.string(),
      price: z.number(),
      stops: z.number(),
    })),
  });

  const agent = new HyperAgent({
    llm: { provider: "openai", model: "gpt-4o" },
  });

  try {
    const page = await agent.newPage();
    await page.goto("https://www.google.com/travel/flights");

    // Navigate and search
    await page.ai("Search for flights from New York to Los Angeles next week");

    // Wait for results
    await page.waitForTimeout(3000);

    // Extract structured data
    const flights = await page.extract(
      "Extract the first 5 flight options with airline, times, duration, price, and stops",
      FlightSchema
    );

    console.log("Flights found:");
    for (const flight of flights.flights) {
      console.log(`- ${flight.airline}: ${flight.departure} -> ${flight.arrival}, $${flight.price}`);
    }
  } finally {
    await agent.closeAgent();
  }
}

// Example 4: Extract without schema (returns string)
async function extractWithoutSchema() {
  console.log("\n=== Extract Without Schema ===");

  const agent = new HyperAgent({
    llm: { provider: "openai", model: "gpt-4o" },
  });

  try {
    const page = await agent.newPage();
    await page.goto("https://news.ycombinator.com");

    // Extract returns a string when no schema provided
    const summary = await page.extract(
      "Summarize the main topics being discussed on this page today"
    );

    console.log("Summary:", summary);
  } finally {
    await agent.closeAgent();
  }
}

// Example 5: Output schema with executeTask
async function taskWithOutputSchema() {
  console.log("\n=== Task with Output Schema ===");

  const MovieSchema = z.object({
    title: z.string(),
    year: z.number(),
    director: z.string(),
    rating: z.string(),
    genres: z.array(z.string()),
    plot: z.string(),
  });

  const agent = new HyperAgent({
    llm: { provider: "openai", model: "gpt-4o" },
  });

  try {
    const result = await agent.executeTask(
      "Go to IMDb, search for 'The Matrix', and get the movie details",
      { outputSchema: MovieSchema }
    );

    const movie = JSON.parse(result.output);
    console.log("Movie:", movie);
  } finally {
    await agent.closeAgent();
  }
}

// Example 6: Extract contact information
async function extractContacts() {
  console.log("\n=== Extract Contacts ===");

  const ContactSchema = z.object({
    company: z.string(),
    email: z.string().optional(),
    phone: z.string().optional(),
    address: z.object({
      street: z.string().optional(),
      city: z.string().optional(),
      state: z.string().optional(),
      zip: z.string().optional(),
      country: z.string().optional(),
    }).optional(),
    socialMedia: z.array(z.object({
      platform: z.string(),
      url: z.string(),
    })).optional(),
  });

  const agent = new HyperAgent({
    llm: { provider: "openai", model: "gpt-4o" },
  });

  try {
    const page = await agent.newPage();
    await page.goto("https://example.com/contact");

    const contact = await page.extract(
      "Extract all contact information from this page",
      ContactSchema
    );

    console.log("Contact info:", contact);
  } finally {
    await agent.closeAgent();
  }
}

// Example 7: Extract table data
async function extractTableData() {
  console.log("\n=== Extract Table Data ===");

  const TableSchema = z.object({
    headers: z.array(z.string()),
    rows: z.array(z.array(z.string())),
  });

  const agent = new HyperAgent({
    llm: { provider: "openai", model: "gpt-4o" },
  });

  try {
    const page = await agent.newPage();
    await page.goto("https://example.com/data-table");

    const table = await page.extract(
      "Extract the data table including headers and all rows",
      TableSchema
    );

    console.log("Headers:", table.headers);
    console.log("Rows:", table.rows.length);
  } finally {
    await agent.closeAgent();
  }
}

// Run examples
async function main() {
  try {
    await basicExtraction();
    // Uncomment to run other examples:
    // await extractProductInfo();
    // await extractAfterNavigation();
    // await extractWithoutSchema();
    // await taskWithOutputSchema();
    // await extractContacts();
    // await extractTableData();
  } catch (error) {
    console.error("Error:", error);
  }
}

main();
