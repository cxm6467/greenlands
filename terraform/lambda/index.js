const { BedrockRuntimeClient, InvokeModelCommand } = require("@aws-sdk/client-bedrock-runtime");
const { SSMClient, GetParameterCommand } = require("@aws-sdk/client-ssm");
const axios = require("axios");

// Environment variables
const SSM_PARAM_NAME = process.env.SSM_PARAM_NAME;
const BEDROCK_MODEL = process.env.BEDROCK_MODEL || "anthropic.claude-3-haiku-20240307-v1:0";

// AWS clients
const bedrockClient = new BedrockRuntimeClient({ region: process.env.AWS_REGION || "us-east-1" });
const ssmClient = new SSMClient({ region: process.env.AWS_REGION || "us-east-1" });

// Cache for Bedrock API key (avoid repeated SSM calls)
let cachedBedrockKey = null;

/**
 * Get Bedrock API key from SSM Parameter Store
 */
async function getBedrockApiKey() {
  if (cachedBedrockKey) {
    return cachedBedrockKey;
  }

  try {
    const command = new GetParameterCommand({
      Name: SSM_PARAM_NAME,
      WithDecryption: true,
    });
    const response = await ssmClient.send(command);
    cachedBedrockKey = response.Parameter.Value;
    return cachedBedrockKey;
  } catch (error) {
    console.error("Failed to retrieve Bedrock API key from SSM:", error);
    throw new Error("Bedrock API key not configured");
  }
}

/**
 * Build CORS headers
 */
function getCorsHeaders() {
  return {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type",
    "Content-Type": "application/json",
  };
}

/**
 * Health check endpoint
 */
async function handleHealth() {
  return {
    statusCode: 200,
    headers: getCorsHeaders(),
    body: JSON.stringify({
      status: "ok",
      service: "greenlands-proxy",
      provider: "bedrock",
      model: BEDROCK_MODEL,
    }),
  };
}

/**
 * Messages endpoint - proxy to Bedrock
 */
async function handleMessages(event) {
  try {
    const body = typeof event.body === "string" ? JSON.parse(event.body) : event.body;
    const { model, max_tokens, messages, temperature } = body;

    // Validate required fields
    if (!model || !Array.isArray(messages) || messages.length === 0) {
      return {
        statusCode: 400,
        headers: getCorsHeaders(),
        body: JSON.stringify({
          error: "Missing required fields: model, messages",
        }),
      };
    }

    console.log(`Invoking Bedrock: ${model}`);

    // Get Bedrock API key
    const apiKey = await getBedrockApiKey();

    // Create Bedrock client with bearer token
    const bedrockClientWithAuth = new BedrockRuntimeClient({
      region: process.env.AWS_REGION || "us-east-1",
      credentials: {
        accessKeyId: "temp",
        secretAccessKey: "temp",
      },
    });

    // Actually, use IAM role credentials directly (no bearer token needed for Lambda)
    // The Lambda execution role has permission to invoke Bedrock

    const params = {
      modelId: model,
      contentType: "application/json",
      accept: "application/json",
      body: JSON.stringify({
        messages: messages,
        max_tokens: max_tokens || 1024,
        ...(temperature && { temperature }),
      }),
    };

    const command = new InvokeModelCommand(params);
    const response = await bedrockClient.send(command);

    // Parse Bedrock response
    const responseBody = JSON.parse(
      new TextDecoder().decode(response.body)
    );

    console.log("Bedrock response received successfully");

    // Transform to Claude-compatible format
    const transformedResponse = {
      id: responseBody.id || `bedrock-${Date.now()}`,
      type: "message",
      role: "assistant",
      content: responseBody.content || [
        {
          type: "text",
          text: responseBody.text || "",
        },
      ],
      model: model,
      stop_reason: responseBody.stop_reason || "end_turn",
      stop_sequence: responseBody.stop_sequence || null,
      usage: {
        input_tokens: responseBody.usage?.input_tokens || 0,
        output_tokens: responseBody.usage?.output_tokens || 0,
      },
    };

    return {
      statusCode: 200,
      headers: getCorsHeaders(),
      body: JSON.stringify(transformedResponse),
    };
  } catch (error) {
    console.error("Error processing messages request:", error);

    if (error.response) {
      // API error
      return {
        statusCode: error.response.status || 500,
        headers: getCorsHeaders(),
        body: JSON.stringify({
          error: error.response.data?.error?.message || error.message,
        }),
      };
    }

    // Server error
    return {
      statusCode: 500,
      headers: getCorsHeaders(),
      body: JSON.stringify({
        error: "Proxy server error",
        message: error.message,
      }),
    };
  }
}

/**
 * Lambda handler - API Gateway HTTP API event
 */
exports.handler = async (event) => {
  console.log("Received event:", JSON.stringify(event, null, 2));

  const method = event.requestContext?.http?.method;
  const path = event.rawPath;

  // Handle preflight requests
  if (method === "OPTIONS") {
    return {
      statusCode: 204,
      headers: getCorsHeaders(),
    };
  }

  // Route to appropriate handler
  if (path === "/api/claude/health" && method === "GET") {
    return await handleHealth();
  } else if (path === "/api/claude/messages" && method === "POST") {
    return await handleMessages(event);
  } else {
    return {
      statusCode: 404,
      headers: getCorsHeaders(),
      body: JSON.stringify({
        error: "Not found",
      }),
    };
  }
};
