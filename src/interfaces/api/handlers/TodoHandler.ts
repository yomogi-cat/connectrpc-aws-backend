import { create } from "@bufbuild/protobuf";
import { ITodoService } from "../../../domain/interfaces/services/ITodoService";
import { logger } from "../../../infrastructure/logging/logger";
import {
  type CreateTodoRequest,
  type GetTodoRequest,
  type ListTodosRequest,
  type UpdateTodoRequest,
  type DeleteTodoRequest,
  type DeleteTodoResponse,
  type UpdateTodoResponse,
  type ListTodosResponse,
  type GetTodoResponse,
  type CreateTodoResponse,
  CreateTodoResponseSchema,
  GetTodoResponseSchema,
  ListTodosResponseSchema,
  UpdateTodoResponseSchema,
  DeleteTodoResponseSchema,
  TodoItem,
} from "../../../infrastructure/proto/todo/v1/todo_pb";

export class TodoHandler {
  private todoService: ITodoService;

  constructor(todoService: ITodoService) {
    this.todoService = todoService;
  }

  // Todoエンティティを Proto定義のTodoItemに変換するヘルパーメソッド
  private mapToTodoItem(todo: any): TodoItem {
    return {
      id: todo.id,
      title: todo.title,
      completed: todo.completed,
      createdAt: todo.createdAt,
      updatedAt: todo.updatedAt,
    } as TodoItem;
  }

  async createTodo(request: CreateTodoRequest): Promise<CreateTodoResponse> {
    logger.info({ request }, "Creating new todo");

    try {
      const todo = await this.todoService.createTodo(request.title);
      return create(CreateTodoResponseSchema, {
        item: this.mapToTodoItem(todo),
      });
    } catch (error) {
      logger.error({ error, request }, "Error creating todo");
      return create(CreateTodoResponseSchema, { item: undefined });
    }
  }

  async getTodo(request: GetTodoRequest): Promise<GetTodoResponse> {
    logger.info({ request }, "Getting todo");

    try {
      const todo = await this.todoService.getTodo(request.id);
      return create(GetTodoResponseSchema, {
        item: todo ? this.mapToTodoItem(todo) : undefined,
      });
    } catch (error) {
      logger.error({ error, request }, "Error getting todo");
      return create(GetTodoResponseSchema, { item: undefined });
    }
  }

  async listTodos(request: ListTodosRequest): Promise<ListTodosResponse> {
    logger.info({ request }, "Listing todos");

    try {
      const result = await this.todoService.listTodos(request.nextToken, request.maxResults);

      return create(ListTodosResponseSchema, {
        items: result.items.map(this.mapToTodoItem),
        nextToken: result.nextToken,
      });
    } catch (error) {
      logger.error({ error, request }, "Error listing todos");
      return create(ListTodosResponseSchema, { items: [] });
    }
  }

  async updateTodo(request: UpdateTodoRequest): Promise<UpdateTodoResponse> {
    logger.info({ request }, "Updating todo");

    try {
      const todo = await this.todoService.updateTodo(request.id, request.title, request.completed);

      return create(UpdateTodoResponseSchema, {
        item: todo ? this.mapToTodoItem(todo) : undefined,
      });
    } catch (error) {
      logger.error({ error, request }, "Error updating todo");
      return create(UpdateTodoResponseSchema, { item: undefined });
    }
  }

  async deleteTodo(request: DeleteTodoRequest): Promise<DeleteTodoResponse> {
    logger.info({ request }, "Deleting todo");

    try {
      const success = await this.todoService.deleteTodo(request.id);
      return create(DeleteTodoResponseSchema, { success });
    } catch (error) {
      logger.error({ error, request }, "Error deleting todo");
      return create(DeleteTodoResponseSchema, { success: false });
    }
  }
}
