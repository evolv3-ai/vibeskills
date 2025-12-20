/**
 * HyperAgent - Basic Usage Examples
 *
 * Run: npx tsx hyperagent-basic.ts
 * Required: OPENAI_API_KEY (or other LLM provider key) in .env
 * Optional: HYPERBROWSER_API_KEY for cloud browsers
 */

import { HyperAgent } from "@hyperbrowser/agent";
import { config } from "dotenv";

config();

// Example 1: Basic task execution with OpenAI
async function basicTaskOpenAI() {
  console.log("=== Basic Task (OpenAI) ===");

  const agent = new HyperAgent({
    llm: { provider: "openai", model: "gpt-4o" },
  });

  try {
    const result = await agent.executeTask(
      "Go to Hacker News (news.ycombinator.com) and tell me the top 3 story titles"
    );

    console.log("Output:", result.output);
  } finally {
    await agent.closeAgent();
  }
}

// Example 2: Using Anthropic Claude
async function basicTaskAnthropic() {
  console.log("\n=== Basic Task (Anthropic) ===");

  const agent = new HyperAgent({
    llm: { provider: "anthropic", model: "claude-sonnet-4-20250514" },
  });

  try {
    const result = await agent.executeTask(
      "Navigate to example.com and describe what you see"
    );

    console.log("Output:", result.output);
  } finally {
    await agent.closeAgent();
  }
}

// Example 3: Using Google Gemini
async function basicTaskGemini() {
  console.log("\n=== Basic Task (Gemini) ===");

  const agent = new HyperAgent({
    llm: { provider: "gemini", model: "gemini-2.5-flash" },
  });

  try {
    const result = await agent.executeTask(
      "Go to example.com and list all the links on the page"
    );

    console.log("Output:", result.output);
  } finally {
    await agent.closeAgent();
  }
}

// Example 4: Using cloud browsers (Hyperbrowser)
async function cloudBrowserTask() {
  console.log("\n=== Cloud Browser Task ===");

  const agent = new HyperAgent({
    llm: { provider: "openai", model: "gpt-4o" },
    browserProvider: "Hyperbrowser",  // Uses HYPERBROWSER_API_KEY
  });

  try {
    const result = await agent.executeTask(
      "Go to whatismyip.com and tell me the IP address shown"
    );

    console.log("Output:", result.output);
  } finally {
    await agent.closeAgent();
  }
}

// Example 5: Page-level control with ai() and perform()
async function pageLevelControl() {
  console.log("\n=== Page-Level Control ===");

  const agent = new HyperAgent({
    llm: { provider: "openai", model: "gpt-4o" },
  });

  try {
    const page = await agent.newPage();

    // Navigate to a page
    await page.goto("https://www.google.com");

    // Use ai() for multi-step task (visual mode)
    await page.ai("Accept any cookie banners if present");

    // Use perform() for single actions (a11y mode - faster)
    await page.perform("Click on the search input field");
    await page.perform("Type 'OpenAI' into the search field");
    await page.perform("Press Enter to search");

    // Wait for results
    await page.waitForTimeout(2000);

    // Use ai() to analyze results
    const result = await page.ai("Tell me the title of the first search result");

    console.log("First result:", result.output);
  } finally {
    await agent.closeAgent();
  }
}

// Example 6: Multi-page management
async function multiPageManagement() {
  console.log("\n=== Multi-Page Management ===");

  const agent = new HyperAgent({
    llm: { provider: "openai", model: "gpt-4o" },
  });

  try {
    // Create multiple pages
    const page1 = await agent.newPage();
    const page2 = await agent.newPage();

    // Navigate different pages
    await page1.goto("https://news.ycombinator.com");
    await page2.goto("https://example.com");

    // Work with each page
    const hn = await page1.ai("What is the top story title?");
    const example = await page2.ai("What is the main heading on this page?");

    console.log("HN top story:", hn.output);
    console.log("Example.com heading:", example.output);

    // Get all pages
    const pages = await agent.getPages();
    console.log(`Total pages: ${pages.length}`);
  } finally {
    await agent.closeAgent();
  }
}

// Example 7: Debug mode
async function debugMode() {
  console.log("\n=== Debug Mode ===");

  const agent = new HyperAgent({
    llm: { provider: "openai", model: "gpt-4o" },
    debug: true,  // Enable debug logging
  });

  try {
    const result = await agent.executeTask(
      "Go to example.com and click any link"
    );

    console.log("Output:", result.output);
  } finally {
    await agent.closeAgent();
  }
}

// Example 8: Task with step callbacks
async function taskWithCallbacks() {
  console.log("\n=== Task with Callbacks ===");

  const agent = new HyperAgent({
    llm: { provider: "openai", model: "gpt-4o" },
  });

  try {
    const page = await agent.newPage();
    await page.goto("https://example.com");

    const result = await page.ai("Click on the 'More information' link and describe the new page", {
      onStep: (step) => {
        console.log(`Step ${step.idx}: ${step.agentOutput.thoughts}`);
      },
      onComplete: (output) => {
        console.log("Task completed!");
      },
    });

    console.log("Final output:", result.output);
  } finally {
    await agent.closeAgent();
  }
}

// Run examples
async function main() {
  try {
    await basicTaskOpenAI();
    // Uncomment to run other examples:
    // await basicTaskAnthropic();
    // await basicTaskGemini();
    // await cloudBrowserTask();
    // await pageLevelControl();
    // await multiPageManagement();
    // await debugMode();
    // await taskWithCallbacks();
  } catch (error) {
    console.error("Error:", error);
  }
}

main();
