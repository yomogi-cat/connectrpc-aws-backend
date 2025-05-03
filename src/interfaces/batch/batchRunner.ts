import { logger } from "../../infrastructure/logging/logger";
import { InMemoryTodoRepository } from "../../infrastructure/persistence/repositories/TodoRepository";
import { TodoService } from "../../usecase/services/TodoService";
import { TodoHandler } from "./handlers/TodoHandler";

const main = async (): Promise<void> => {
  try {
    const args = process.argv.slice(2);
    const command = args[0];
    logger.info({ command, args }, "Starting batch process");

    // 依存関係の注入
    const todoRepository = new InMemoryTodoRepository();
    const todoService = new TodoService(todoRepository);
    const todoHandler = new TodoHandler(todoService);

    // コマンドに応じたバッチ処理を実行
    switch (command) {
      case "cleanup":
        await todoHandler.cleanupTodos();
        break;

      case "export":
        await todoHandler.exportTodos();
        break;

      case "stats":
        await todoHandler.calculateStats();
        break;

      default:
        logger.warn({ command }, "Unknown batch command");
    }

    logger.info("Batch process completed successfully");
    process.exit(0);
  } catch (error) {
    logger.error({ error }, "Error in batch process");
    process.exit(1);
  }
};

// バッチプロセスの実行
if (require.main === module) {
  main().catch((error) => {
    logger.error({ error }, "Unhandled error in batch process");
    process.exit(1);
  });
}
