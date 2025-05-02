import { Todo } from "../../../domain/entities/Todo";
import { ITodoRepository } from "../../../domain/interfaces/repositories/ITodoRepository";
import { logger } from "../../../infrastructure/logging/logger";

// インメモリストレージの実装
export class InMemoryTodoRepository implements ITodoRepository {
  private todos: Map<string, Todo> = new Map();

  async create(todo: Todo): Promise<Todo> {
    logger.info({ todo }, "Creating todo in repository");
    this.todos.set(todo.id, { ...todo });
    return todo;
  }

  async findById(id: string): Promise<Todo | null> {
    logger.info({ id }, "Finding todo by ID");
    const todo = this.todos.get(id);
    return todo ? { ...todo } : null;
  }

  async findAll(
    nextToken?: string,
    maxResults: number = 50
  ): Promise<{
    items: Todo[];
    nextToken?: string;
  }> {
    logger.info({ nextToken, maxResults }, "Finding all todos");

    const allTodos = Array.from(this.todos.values());
    const startIndex = nextToken ? parseInt(nextToken, 10) : 0;

    if (startIndex >= allTodos.length) {
      return { items: [] };
    }

    const endIndex = Math.min(startIndex + maxResults, allTodos.length);
    const hasMore = endIndex < allTodos.length;

    return {
      items: allTodos.slice(startIndex, endIndex),
      nextToken: hasMore ? endIndex.toString() : undefined,
    };
  }

  async update(todo: Todo): Promise<Todo> {
    logger.info({ todo }, "Updating todo");

    if (!this.todos.has(todo.id)) {
      throw new Error(`Todo with ID ${todo.id} not found`);
    }

    this.todos.set(todo.id, { ...todo });
    return todo;
  }

  async delete(id: string): Promise<boolean> {
    logger.info({ id }, "Deleting todo");
    return this.todos.delete(id);
  }
}
