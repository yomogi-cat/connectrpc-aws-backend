import { server } from "./interfaces/server";
import { logger } from "./infrastructure/logging/logger";
import { config } from "./config";

const start = async () => {
  try {
    await server.listen({
      port: config.server.port,
      host: config.server.host,
    });

    logger.info(`Server is running on port ${config.server.port}`);
  } catch (err) {
    logger.error(err);
    process.exit(1);
  }
};

start();
