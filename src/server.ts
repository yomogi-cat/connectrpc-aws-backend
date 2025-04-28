import { fastify } from "fastify";
import type { FastifyInstance } from "fastify";
import { fastifyConnectPlugin } from "@connectrpc/connect-fastify";
import { routes } from "./connect";
import { loggerConfig } from "./logger";

const fastifyConfig = {
  port: 3000,
  logger: loggerConfig,
};

const buildServer = (): FastifyInstance => {
  const server = fastify({
    logger: fastifyConfig.logger,
  });

  // Connect plugin の登録
  server.register(fastifyConnectPlugin, {
    routes,
  });

  return server;
};

const start = async (server: FastifyInstance) => {
  try {
    await server.listen({ port: fastifyConfig.port });

    server.log.info(`Server is running on port ${fastifyConfig.port}`);
  } catch (err) {
    server.log.error(err);
    process.exit(1);
  }
};

start(buildServer());
