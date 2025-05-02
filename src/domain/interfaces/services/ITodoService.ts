import { Todo } from "../../entities/Todo";
export interface ITodoService {
  createTodo(title: string): Promise<Todo>;
  getTodo(id: string): Promise<Todo | null>;
  listTodos(
    nextToken?: string,
    maxResults?: number
  ): Promise<{
    items: Todo[];
    nextToken?: string;
  }>;
  updateTodo(id: string, title?: string, completed?: boolean): Promise<Todo | null>;
  deleteTodo(id: string): Promise<boolean>;
}
