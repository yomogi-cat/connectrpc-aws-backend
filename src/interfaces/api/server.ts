import { fastify } from "fastify";
import type { FastifyInstance } from "fastify";
import { fastifyConnectPlugin } from "@connectrpc/connect-fastify";
import { logger, loggerConfig } from "../../infrastructure/logging/logger";
import { config } from "../../config";
import { TodoService } from "../../usecase/services/TodoService";
import { InMemoryTodoRepository } from "../../infrastructure/persistence/repositories/TodoRepository";
import { TodoHandler } from "./handlers/TodoHandler";
import { TodoService as ProtoTodoService } from "../../infrastructure/proto/todo/v1/todo_pb";

const buildServer = (): FastifyInstance => {
  // 依存関係の注入
  const todoRepository = new InMemoryTodoRepository();
  const todoService = new TodoService(todoRepository);
  const todoHandler = new TodoHandler(todoService);

  // Fastifyサーバーの構築
  const server = fastify({
    logger: loggerConfig,
  });

  // AppRunnerデプロイ時のヘルスチェックエンドポイント
  server.get("/health", async (request, reply) => {
    return reply.code(200).send({ status: "ok" });
  });

  // Connect plugin の登録
  server.register(fastifyConnectPlugin, {
    routes: (router) => {
      router.service(ProtoTodoService, {
        createTodo: todoHandler.createTodo.bind(todoHandler),
        getTodo: todoHandler.getTodo.bind(todoHandler),
        listTodos: todoHandler.listTodos.bind(todoHandler),
        updateTodo: todoHandler.updateTodo.bind(todoHandler),
        deleteTodo: todoHandler.deleteTodo.bind(todoHandler),
      });
    },
  });

  return server;
};

const start = async (server: FastifyInstance) => {
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

// サーバーの起動をエクスポートして、テスト可能にする
export const server = buildServer();

// このファイルが直接実行された場合にのみサーバーを起動
if (require.main === module) {
  start(server);
}
