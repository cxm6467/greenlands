import Fastify from 'fastify';
import cors from '@fastify/cors';
import axios from 'axios';
import { BedrockRuntimeClient, InvokeModelCommand } from '@aws-sdk/client-bedrock-runtime';

const fastify = Fastify({
  logger: true,
});

// Register CORS plugin
await fastify.register(cors, {
  origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:5173', 'http://localhost:8080', 'http://localhost'],
  methods: ['GET', 'POST', 'OPTIONS'],
});

// Configuration
const AI_PROVIDER = process.env.AI_PROVIDER || 'claude';
const CLAUDE_API_KEY = process.env.CLAUDE_API_KEY;
const AWS_REGION = process.env.AWS_REGION || 'us-east-1';
const AWS_ACCESS_KEY_ID = process.env.AWS_ACCESS_KEY_ID;
const AWS_SECRET_ACCESS_KEY = process.env.AWS_SECRET_ACCESS_KEY;
const PORT = parseInt(process.env.PORT || '3001', 10);
const HOST = process.env.HOST || '0.0.0.0';

// Validate configuration
if (AI_PROVIDER === 'claude' && !CLAUDE_API_KEY) {
  fastify.log.error('CLAUDE_API_KEY environment variable is not set');
  process.exit(1);
}

if (AI_PROVIDER === 'bedrock' && (!AWS_ACCESS_KEY_ID || !AWS_SECRET_ACCESS_KEY)) {
  fastify.log.error('AWS credentials (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY) are not set');
  process.exit(1);
}

// Initialize Bedrock client if using Bedrock
let bedrockClient;
if (AI_PROVIDER === 'bedrock') {
  bedrockClient = new BedrockRuntimeClient({
    region: AWS_REGION,
    credentials: {
      accessKeyId: AWS_ACCESS_KEY_ID,
      secretAccessKey: AWS_SECRET_ACCESS_KEY,
    },
  });
}

// Health check endpoint
fastify.get('/health', async (request, reply) => {
  return { status: 'ok', service: 'ai-proxy', provider: AI_PROVIDER };
});

// Messages endpoint - supports both Claude API and Bedrock
fastify.post('/v1/messages', async (request, reply) => {
  try {
    const { model, max_tokens, messages, temperature } = request.body;

    // Validate required fields
    if (!model || !Array.isArray(messages) || messages.length === 0) {
      return reply.status(400).send({
        error: 'Missing required fields: model, messages',
      });
    }

    if (AI_PROVIDER === 'claude') {
      return await invokeClaudeAPI(model, max_tokens, messages, temperature, fastify);
    } else if (AI_PROVIDER === 'bedrock') {
      return await invokeBedrockAPI(model, max_tokens, messages, temperature, fastify);
    }

    return reply.status(400).send({
      error: 'Invalid AI_PROVIDER',
    });
  } catch (error) {
    fastify.log.error(`Request failed: ${error.message}`);

    if (error.response) {
      const status = error.response.status || 500;
      const data = error.response.data || { error: error.message };
      return reply.status(status).send(data);
    }

    return reply.status(500).send({
      error: 'Proxy server error',
      message: error.message,
    });
  }
});

// Claude API invocation
async function invokeClaudeAPI(model, max_tokens, messages, temperature, fastify) {
  fastify.log.info(`Invoking Claude API: ${model}`);

  const response = await axios.post(
    'https://api.anthropic.com/v1/messages',
    {
      model,
      max_tokens: max_tokens || 1024,
      messages,
      ...(temperature && { temperature }),
    },
    {
      headers: {
        'x-api-key': CLAUDE_API_KEY,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      },
      timeout: 30000,
    }
  );

  fastify.log.info(`Claude API response: ${response.status}`);
  return response.data;
}

// Bedrock invocation
async function invokeBedrockAPI(model, max_tokens, messages, temperature, fastify) {
  fastify.log.info(`Invoking Bedrock: ${model}`);

  const bedrockMessages = messages.map((msg) => ({
    role: msg.role,
    content: msg.content,
  }));

  const params = {
    modelId: model,
    contentType: 'application/json',
    accept: 'application/json',
    body: JSON.stringify({
      messages: bedrockMessages,
      max_tokens: max_tokens || 1024,
      ...(temperature && { temperature }),
    }),
  };

  const command = new InvokeModelCommand(params);
  const response = await bedrockClient.send(command);

  const responseBody = JSON.parse(new TextDecoder().decode(response.body));

  fastify.log.info(`Bedrock response received`);

  return {
    id: responseBody.id || `bedrock-${Date.now()}`,
    type: 'message',
    role: 'assistant',
    content: responseBody.content || [
      {
        type: 'text',
        text: responseBody.text || '',
      },
    ],
    model: model,
    stop_reason: responseBody.stop_reason || 'end_turn',
    stop_sequence: responseBody.stop_sequence || null,
    usage: {
      input_tokens: responseBody.usage?.input_tokens || 0,
      output_tokens: responseBody.usage?.output_tokens || 0,
    },
  };
}

// Start server
try {
  await fastify.listen({ port: PORT, host: HOST });
  fastify.log.info(`AI proxy server listening on ${HOST}:${PORT}`);
  fastify.log.info(`Provider: ${AI_PROVIDER}`);
} catch (err) {
  fastify.log.error(err);
  process.exit(1);
}
