import { Todo, TodoEntity } from "../../domain/entities/Todo";
import { ITodoRepository } from "../../domain/interfaces/repositories/ITodoRepository";
import { ITodoService } from "../../domain/interfaces/services/ITodoService";

export class TodoService implements ITodoService {
  private repository: ITodoRepository;

  constructor(repository: ITodoRepository) {
    this.repository = repository;
  }

  async createTodo(title: string): Promise<Todo> {
    const todo = TodoEntity.create(title);
    return this.repository.create(todo);
  }

  async getTodo(id: string): Promise<Todo | null> {
    return this.repository.findById(id);
  }

  async listTodos(
    nextToken?: string,
    maxResults?: number
  ): Promise<{
    items: Todo[];
    nextToken?: string;
  }> {
    return this.repository.findAll(nextToken, maxResults);
  }

  async updateTodo(id: string, title?: string, completed?: boolean): Promise<Todo | null> {
    const existingTodo = await this.repository.findById(id);

    if (!existingTodo) {
      return null;
    }

    const todoEntity = new TodoEntity(existingTodo.id, existingTodo.title, existingTodo.completed, existingTodo.createdAt, existingTodo.updatedAt);

    todoEntity.update(title, completed);

    return this.repository.update(todoEntity);
  }

  async deleteTodo(id: string): Promise<boolean> {
    return this.repository.delete(id);
  }
}
