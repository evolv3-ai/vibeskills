/**
 * Hyperbrowser SDK - Agent API Examples
 *
 * Run: npx tsx sdk-agents.ts
 * Required: HYPERBROWSER_API_KEY in .env
 * Optional: OPENAI_API_KEY, ANTHROPIC_API_KEY for custom API keys
 */

import { Hyperbrowser } from "@hyperbrowser/sdk";
import { config } from "dotenv";

config();

const hb = new Hyperbrowser({
  apiKey: process.env.HYPERBROWSER_API_KEY,
});

// Example 1: Browser Use Agent (OpenAI-based)
async function browserUseAgent() {
  console.log("=== Browser Use Agent ===");

  const result = await hb.agents.browserUse.startAndWait({
    task: "Go to Hacker News (news.ycombinator.com) and tell me the titles of the top 3 stories",
    llm: "gpt-4o",
    useVision: true,
    maxSteps: 15,
    sessionOptions: {
      useStealth: true,
      acceptCookies: true,
    },
  });

  console.log("Status:", result.status);
  console.log("Result:", result.data?.finalResult);
}

// Example 2: CUA (OpenAI Computer Use Agent)
async function cuaAgent() {
  console.log("\n=== CUA Agent ===");

  const result = await hb.agents.cua.startAndWait({
    task: "Navigate to example.com and describe what you see on the page",
    maxSteps: 10,
    sessionOptions: {
      useStealth: true,
      acceptCookies: true,
      adblock: true,
    },
  });

  console.log("Status:", result.status);
  console.log("Result:", result.data?.finalResult);
}

// Example 3: Claude Computer Use Agent
async function claudeAgent() {
  console.log("\n=== Claude Computer Use Agent ===");

  const result = await hb.agents.claudeComputerUse.startAndWait({
    task: "Go to example.com and summarize the page content",
    llm: "claude-sonnet-4-20250514",
    maxSteps: 10,
    sessionOptions: {
      useStealth: true,
    },
  });

  console.log("Status:", result.status);
  console.log("Result:", result.data?.finalResult);
}

// Example 4: HyperAgent via SDK
async function hyperAgentViaSdk() {
  console.log("\n=== HyperAgent via SDK ===");

  const result = await hb.agents.hyperAgent.startAndWait({
    task: "Navigate to Hacker News and extract the top story title",
    llm: "gpt-4o",
    maxSteps: 10,
    sessionOptions: {
      useStealth: true,
    },
  });

  console.log("Status:", result.status);
  console.log("Result:", result.data?.finalResult);
}

// Example 5: Session reuse pattern
async function sessionReusePattern() {
  console.log("\n=== Session Reuse Pattern ===");

  // Create a persistent session
  const session = await hb.sessions.create({
    useStealth: true,
    useProxy: true,
    acceptCookies: true,
  });

  console.log("Created session:", session.id);
  console.log("Live URL:", session.liveUrl);

  try {
    // First task: Navigate and authenticate
    console.log("\nTask 1: Initial navigation...");
    const task1 = await hb.agents.cua.startAndWait({
      task: "Go to example.com",
      sessionId: session.id,
      keepBrowserOpen: true,
      maxSteps: 5,
    });
    console.log("Task 1 result:", task1.data?.finalResult);

    // Second task: Continue in same session
    console.log("\nTask 2: Continue in same session...");
    const task2 = await hb.agents.cua.startAndWait({
      task: "Now describe what links are available on this page",
      sessionId: session.id,
      keepBrowserOpen: true,
      maxSteps: 5,
    });
    console.log("Task 2 result:", task2.data?.finalResult);

  } finally {
    // Always clean up
    await hb.sessions.stop(session.id);
    console.log("\nSession stopped");
  }
}

// Example 6: Agent with live view
async function agentWithLiveView() {
  console.log("\n=== Agent with Live View ===");

  // Start agent (non-blocking)
  const { jobId, liveUrl } = await hb.agents.cua.start({
    task: "Go to Google, search for 'OpenAI', and summarize the first result",
    maxSteps: 20,
    sessionOptions: {
      useStealth: true,
      acceptCookies: true,
    },
  });

  console.log(`Job ID: ${jobId}`);
  console.log(`Watch live at: ${liveUrl}`);

  // Poll for completion
  let response = await hb.agents.cua.getStatus(jobId);
  while (response.status === "pending" || response.status === "running") {
    console.log(`Status: ${response.status}...`);
    await new Promise(r => setTimeout(r, 3000));
    response = await hb.agents.cua.getStatus(jobId);
  }

  // Get final result
  const result = await hb.agents.cua.get(jobId);
  console.log("\nFinal status:", result.status);
  console.log("Result:", result.data?.finalResult);
}

// Example 7: Agent with custom API keys
async function agentWithCustomKeys() {
  console.log("\n=== Agent with Custom API Keys ===");

  const result = await hb.agents.browserUse.startAndWait({
    task: "Navigate to example.com and describe the page",
    llm: "gpt-4o",
    useCustomApiKeys: true,
    apiKeys: {
      openai: process.env.OPENAI_API_KEY,
    },
    maxSteps: 10,
    sessionOptions: {
      useStealth: true,
    },
  });

  console.log("Result:", result.data?.finalResult);
}

// Run examples
async function main() {
  try {
    await browserUseAgent();
    // Uncomment to run other examples:
    // await cuaAgent();
    // await claudeAgent();
    // await hyperAgentViaSdk();
    // await sessionReusePattern();
    // await agentWithLiveView();
    // await agentWithCustomKeys();
  } catch (error) {
    console.error("Error:", error);
  }
}

main();
