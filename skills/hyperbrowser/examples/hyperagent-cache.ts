/**
 * HyperAgent - Action Caching & Replay Examples
 *
 * Run: npx tsx hyperagent-cache.ts
 * Required: OPENAI_API_KEY (or other LLM provider key) in .env
 */

import { HyperAgent, TaskStatus } from "@hyperbrowser/agent";
import type { ActionCacheOutput } from "@hyperbrowser/agent";
import { config } from "dotenv";
import fs from "fs";

config();

// Example 1: Record and save action cache
async function recordActionCache() {
  console.log("=== Record Action Cache ===");

  const agent = new HyperAgent({
    llm: { provider: "openai", model: "gpt-4o" },
  });

  try {
    const page = await agent.newPage();
    await page.goto("https://example.com");

    // Execute task - actions will be recorded
    const result = await page.ai(
      "Click on the 'More information' link"
    );

    // Get the action cache
    const cache = result.actionCache;

    if (cache) {
      console.log("Task ID:", cache.taskId);
      console.log("Steps recorded:", cache.steps.length);

      // Save cache to file for later replay
      fs.writeFileSync("action-cache.json", JSON.stringify(cache, null, 2));
      console.log("Cache saved to action-cache.json");

      // Print recorded steps
      for (const step of cache.steps) {
        console.log(`Step ${step.stepIndex}: ${step.actionType} - ${step.method || "N/A"}`);
        if (step.xpath) {
          console.log(`  XPath: ${step.xpath}`);
        }
      }
    }
  } finally {
    await agent.closeAgent();
  }
}

// Example 2: Replay from saved cache
async function replayFromCache() {
  console.log("\n=== Replay from Cache ===");

  // Load saved cache
  if (!fs.existsSync("action-cache.json")) {
    console.log("No cache file found. Run recordActionCache() first.");
    return;
  }

  const cache: ActionCacheOutput = JSON.parse(
    fs.readFileSync("action-cache.json", "utf-8")
  );

  const agent = new HyperAgent({
    llm: { provider: "openai", model: "gpt-4o" },
  });

  try {
    const page = await agent.newPage();
    await page.goto("https://example.com");

    // Replay cached actions (no LLM calls if XPaths match)
    const replayResult = await page.runFromActionCache(cache, {
      maxXPathRetries: 3,  // Retry XPath resolution up to 3 times
    });

    console.log("Replay ID:", replayResult.replayId);
    console.log("Source Task ID:", replayResult.sourceTaskId);
    console.log("Status:", replayResult.status);

    // Check each step result
    for (const step of replayResult.steps) {
      console.log(`Step ${step.stepIndex}:`);
      console.log(`  Success: ${step.success}`);
      console.log(`  Used XPath: ${step.usedXPath}`);
      console.log(`  Fallback used: ${step.fallbackUsed}`);
      if (step.retries > 0) {
        console.log(`  Retries: ${step.retries}`);
      }
    }
  } finally {
    await agent.closeAgent();
  }
}

// Example 3: Generate executable script from cache
async function generateScriptFromCache() {
  console.log("\n=== Generate Script from Cache ===");

  // Load saved cache
  if (!fs.existsSync("action-cache.json")) {
    console.log("No cache file found. Run recordActionCache() first.");
    return;
  }

  const cache: ActionCacheOutput = JSON.parse(
    fs.readFileSync("action-cache.json", "utf-8")
  );

  const agent = new HyperAgent({
    llm: { provider: "openai", model: "gpt-4o" },
  });

  try {
    // Generate TypeScript script from cache
    const script = agent.createScriptFromActionCache(cache.steps, cache.taskId);

    console.log("Generated Script:");
    console.log("================");
    console.log(script);

    // Save to file
    fs.writeFileSync("generated-workflow.ts", script);
    console.log("\nScript saved to generated-workflow.ts");
  } finally {
    await agent.closeAgent();
  }
}

// Example 4: Async task with pause/resume
async function asyncTaskControl() {
  console.log("\n=== Async Task Control ===");

  const agent = new HyperAgent({
    llm: { provider: "openai", model: "gpt-4o" },
  });

  try {
    const page = await agent.newPage();
    await page.goto("https://news.ycombinator.com");

    // Start async task
    const task = await page.aiAsync(
      "Extract the titles of all stories on this page"
    );

    console.log("Task started, ID:", task.id);
    console.log("Initial status:", task.getStatus());

    // Monitor task
    let iterations = 0;
    while (true) {
      const status = task.getStatus();
      console.log(`Status: ${status}`);

      if (status === TaskStatus.COMPLETED) {
        console.log("Task completed!");
        break;
      }

      if (status === TaskStatus.FAILED) {
        console.log("Task failed!");
        break;
      }

      // Demo: Pause after 2 iterations
      if (iterations === 2 && status === TaskStatus.RUNNING) {
        console.log("Pausing task...");
        task.pause();
        console.log("Status after pause:", task.getStatus());

        // Wait a bit
        await new Promise(r => setTimeout(r, 2000));

        // Resume
        console.log("Resuming task...");
        task.resume();
        console.log("Status after resume:", task.getStatus());
      }

      iterations++;
      await new Promise(r => setTimeout(r, 1000));

      // Safety limit
      if (iterations > 30) {
        console.log("Cancelling task (timeout)...");
        task.cancel();
        break;
      }
    }
  } finally {
    await agent.closeAgent();
  }
}

// Example 5: Error handling in async tasks
async function asyncTaskErrorHandling() {
  console.log("\n=== Async Task Error Handling ===");

  const agent = new HyperAgent({
    llm: { provider: "openai", model: "gpt-4o" },
  });

  try {
    const page = await agent.newPage();
    await page.goto("https://example.com");

    const task = await page.aiAsync("Click on a non-existent button");

    // Register error handler
    task.emitter.on("error", (error) => {
      console.error("Task error:", error);
    });

    // Wait for completion
    while (true) {
      const status = task.getStatus();
      if ([TaskStatus.COMPLETED, TaskStatus.FAILED, TaskStatus.CANCELLED].includes(status)) {
        console.log("Final status:", status);
        break;
      }
      await new Promise(r => setTimeout(r, 1000));
    }
  } finally {
    await agent.closeAgent();
  }
}

// Example 6: Record multi-step workflow
async function recordComplexWorkflow() {
  console.log("\n=== Record Complex Workflow ===");

  const agent = new HyperAgent({
    llm: { provider: "openai", model: "gpt-4o" },
  });

  try {
    const page = await agent.newPage();
    await page.goto("https://www.google.com");

    // Execute multi-step task
    const result = await page.ai(
      "1. Accept any cookie banners. " +
      "2. Type 'OpenAI' in the search box. " +
      "3. Press Enter to search. " +
      "4. Wait for results to load."
    );

    const cache = result.actionCache;

    if (cache) {
      console.log("Recorded workflow with", cache.steps.length, "steps:");

      for (const step of cache.steps) {
        const desc = step.instruction || step.actionType;
        console.log(`${step.stepIndex + 1}. ${desc}`);
        console.log(`   Method: ${step.method || "N/A"}`);
        console.log(`   Success: ${step.success}`);
      }

      // Save for later
      fs.writeFileSync("google-search-workflow.json", JSON.stringify(cache, null, 2));
      console.log("\nWorkflow saved to google-search-workflow.json");
    }
  } finally {
    await agent.closeAgent();
  }
}

// Example 7: Cache with step callbacks
async function cacheWithCallbacks() {
  console.log("\n=== Cache with Step Callbacks ===");

  const agent = new HyperAgent({
    llm: { provider: "openai", model: "gpt-4o" },
  });

  try {
    const page = await agent.newPage();
    await page.goto("https://example.com");

    const result = await page.ai("Click on any link on this page", {
      onStep: (step) => {
        console.log(`Executing step ${step.idx}...`);
        console.log(`  Thoughts: ${step.agentOutput.thoughts}`);
        console.log(`  Action: ${step.agentOutput.action.type}`);
      },
      onComplete: (output) => {
        console.log("Task completed!");
        console.log("Output:", output.output);
      },
    });

    // Cache is still available
    console.log("\nCached steps:", result.actionCache?.steps.length);
  } finally {
    await agent.closeAgent();
  }
}

// Run examples
async function main() {
  try {
    await recordActionCache();
    // Uncomment to run other examples:
    // await replayFromCache();
    // await generateScriptFromCache();
    // await asyncTaskControl();
    // await asyncTaskErrorHandling();
    // await recordComplexWorkflow();
    // await cacheWithCallbacks();
  } catch (error) {
    console.error("Error:", error);
  }
}

main();
