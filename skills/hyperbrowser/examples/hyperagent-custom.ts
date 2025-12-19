/**
 * HyperAgent - Custom Actions & MCP Integration Examples
 *
 * Run: npx tsx hyperagent-custom.ts
 * Required: OPENAI_API_KEY (or other LLM provider key) in .env
 */

import { HyperAgent } from "@hyperbrowser/agent";
import type { AgentActionDefinition, ActionContext, ActionOutput } from "@hyperbrowser/agent";
import { z } from "zod";
import { config } from "dotenv";
import fs from "fs/promises";

config();

// ============================================
// Custom Action Definitions
// ============================================

// Custom Action 1: Save content to file
const SaveToFileAction: AgentActionDefinition = {
  type: "saveToFile",
  actionParams: z.object({
    filename: z.string().describe("Name of the file to save"),
    content: z.string().describe("Content to write to the file"),
  }),
  run: async (ctx: ActionContext, params: { filename: string; content: string }): Promise<ActionOutput> => {
    try {
      await fs.writeFile(params.filename, params.content);
      return {
        success: true,
        message: `Successfully saved content to ${params.filename}`,
      };
    } catch (error) {
      return {
        success: false,
        message: `Failed to save file: ${error}`,
      };
    }
  },
  pprintAction: (params) => `Save to file: ${params.filename}`,
};

// Custom Action 2: Send notification (mock)
const NotifyAction: AgentActionDefinition = {
  type: "sendNotification",
  actionParams: z.object({
    title: z.string().describe("Notification title"),
    message: z.string().describe("Notification message"),
    priority: z.enum(["low", "medium", "high"]).describe("Priority level"),
  }),
  run: async (ctx, params): Promise<ActionOutput> => {
    console.log(`[NOTIFICATION - ${params.priority.toUpperCase()}]`);
    console.log(`Title: ${params.title}`);
    console.log(`Message: ${params.message}`);

    // In real implementation, send to Slack, email, etc.
    return {
      success: true,
      message: `Notification sent: ${params.title}`,
    };
  },
};

// Custom Action 3: Search with external API (mock)
const ExternalSearchAction: AgentActionDefinition = {
  type: "externalSearch",
  actionParams: z.object({
    query: z.string().describe("Search query"),
    limit: z.number().optional().describe("Max results to return"),
  }),
  run: async (ctx, params): Promise<ActionOutput> => {
    // Mock external search (e.g., Exa, Tavily, etc.)
    const mockResults = [
      { title: "Result 1", url: "https://example.com/1" },
      { title: "Result 2", url: "https://example.com/2" },
      { title: "Result 3", url: "https://example.com/3" },
    ];

    const results = mockResults.slice(0, params.limit || 3);

    return {
      success: true,
      message: `Found ${results.length} results for "${params.query}":\n${results.map(r => `- ${r.title}: ${r.url}`).join("\n")}`,
    };
  },
};

// Custom Action 4: Take screenshot and save
const ScreenshotAction: AgentActionDefinition = {
  type: "takeScreenshot",
  actionParams: z.object({
    filename: z.string().describe("Filename to save screenshot"),
    fullPage: z.boolean().optional().describe("Capture full page"),
  }),
  run: async (ctx, params): Promise<ActionOutput> => {
    try {
      const buffer = await ctx.page.screenshot({
        fullPage: params.fullPage ?? false,
      });
      await fs.writeFile(params.filename, buffer);
      return {
        success: true,
        message: `Screenshot saved to ${params.filename}`,
      };
    } catch (error) {
      return {
        success: false,
        message: `Failed to take screenshot: ${error}`,
      };
    }
  },
};

// Custom Action 5: Store variable for later use
const StoreVariableAction: AgentActionDefinition = {
  type: "storeVariable",
  actionParams: z.object({
    key: z.string().describe("Variable name"),
    value: z.string().describe("Value to store"),
    description: z.string().describe("What this variable represents"),
  }),
  run: async (ctx, params): Promise<ActionOutput> => {
    // Access agent's variable storage via context
    // Note: This is a simplified example
    console.log(`Storing variable: ${params.key} = ${params.value}`);

    return {
      success: true,
      message: `Stored variable "${params.key}" with value "${params.value}"`,
    };
  },
};

// ============================================
// Examples
// ============================================

// Example 1: Using custom actions
async function customActionsExample() {
  console.log("=== Custom Actions Example ===");

  const agent = new HyperAgent({
    llm: { provider: "openai", model: "gpt-4o" },
    customActions: [SaveToFileAction, NotifyAction, ScreenshotAction],
  });

  try {
    const result = await agent.executeTask(
      "Go to Hacker News, get the top 3 story titles, save them to 'hn-stories.txt', and send a notification about what you found"
    );

    console.log("Result:", result.output);
  } finally {
    await agent.closeAgent();
  }
}

// Example 2: Custom action with external search
async function externalSearchExample() {
  console.log("\n=== External Search Action ===");

  const agent = new HyperAgent({
    llm: { provider: "openai", model: "gpt-4o" },
    customActions: [ExternalSearchAction],
  });

  try {
    const result = await agent.executeTask(
      "Search externally for 'AI news today' and summarize the results"
    );

    console.log("Result:", result.output);
  } finally {
    await agent.closeAgent();
  }
}

// Example 3: MCP Server Integration
async function mcpIntegrationExample() {
  console.log("\n=== MCP Server Integration ===");

  const agent = new HyperAgent({
    llm: { provider: "openai", model: "gpt-4o" },
  });

  try {
    // Initialize MCP client with servers
    await agent.initializeMCPClient({
      servers: [
        {
          id: "filesystem",
          command: "npx",
          args: ["-y", "@modelcontextprotocol/server-filesystem", "/tmp"],
        },
        // Add more MCP servers as needed
        // {
        //   id: "weather",
        //   command: "npx",
        //   args: ["@anthropic/weather-mcp"],
        // },
      ],
    });

    // Check connected servers
    const serverInfo = agent.getMCPServerInfo();
    console.log("Connected MCP servers:", serverInfo);

    // Agent now has access to MCP tools
    const result = await agent.executeTask(
      "List the files in the /tmp directory using the filesystem tools"
    );

    console.log("Result:", result.output);
  } finally {
    await agent.closeAgent();
  }
}

// Example 4: Dynamic MCP server connection
async function dynamicMcpConnection() {
  console.log("\n=== Dynamic MCP Connection ===");

  const agent = new HyperAgent({
    llm: { provider: "openai", model: "gpt-4o" },
  });

  try {
    // Connect to MCP server at runtime
    const serverId = await agent.connectToMCPServer({
      command: "npx",
      args: ["-y", "@modelcontextprotocol/server-memory"],
    });

    if (serverId) {
      console.log(`Connected to server: ${serverId}`);
      console.log("Server info:", agent.getMCPServerInfo());

      // Use the server
      const result = await agent.executeTask(
        "Store a note 'Remember to review the PR' using the memory tools"
      );
      console.log("Result:", result.output);

      // Disconnect when done
      agent.disconnectFromMCPServer(serverId);
      console.log("Disconnected from server");
    }
  } finally {
    await agent.closeAgent();
  }
}

// Example 5: Combining custom actions with browser automation
async function combinedExample() {
  console.log("\n=== Combined Custom Actions + Browser ===");

  const agent = new HyperAgent({
    llm: { provider: "openai", model: "gpt-4o" },
    customActions: [SaveToFileAction, ScreenshotAction, NotifyAction],
  });

  try {
    const page = await agent.newPage();
    await page.goto("https://news.ycombinator.com");

    // Multi-step workflow combining browser actions and custom actions
    const result = await page.ai(
      "1. Take a screenshot and save it as 'hn-homepage.png'. " +
      "2. Extract the top 5 story titles. " +
      "3. Save them to 'top-stories.txt'. " +
      "4. Send a high priority notification summarizing what you found."
    );

    console.log("Workflow result:", result.output);
  } finally {
    await agent.closeAgent();
  }
}

// Example 6: Agent variables
async function agentVariablesExample() {
  console.log("\n=== Agent Variables ===");

  const agent = new HyperAgent({
    llm: { provider: "openai", model: "gpt-4o" },
  });

  try {
    // Add variables that the agent can reference
    agent.addVariable({
      key: "username",
      value: "testuser",
      description: "The username to use for login",
    });

    agent.addVariable({
      key: "search_term",
      value: "AI automation",
      description: "The term to search for",
    });

    // Check variables
    console.log("Variables:", agent.getVariables());

    const result = await agent.executeTask(
      "Go to Google and search for the search_term variable value"
    );

    console.log("Result:", result.output);

    // Clean up variable
    agent.deleteVariable("search_term");
  } finally {
    await agent.closeAgent();
  }
}

// Run examples
async function main() {
  try {
    await customActionsExample();
    // Uncomment to run other examples:
    // await externalSearchExample();
    // await mcpIntegrationExample();
    // await dynamicMcpConnection();
    // await combinedExample();
    // await agentVariablesExample();
  } catch (error) {
    console.error("Error:", error);
  }
}

main();
