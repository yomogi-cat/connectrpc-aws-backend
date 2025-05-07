import { ITodoService } from "../../../domain/interfaces/services/ITodoService";
import { logger } from "../../../infrastructure/logging/logger";

export class TodoHandler {
  private todoService: ITodoService;

  constructor(todoService: ITodoService) {
    this.todoService = todoService;
  }

  async cleanupTodos(): Promise<void> {
    logger.info("Cleanup todos");
  }

  async exportTodos(): Promise<void> {
    logger.info("Export todos");
  }

  async calculateStats(): Promise<void> {
    logger.info("Calculate stats");
  }
}
