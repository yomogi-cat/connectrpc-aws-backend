import { Todo } from "../../entities/Todo";

export interface ITodoRepository {
  create(todo: Todo): Promise<Todo>;
  findById(id: string): Promise<Todo | null>;
  findAll(
    nextToken?: string,
    maxResults?: number
  ): Promise<{
    items: Todo[];
    nextToken?: string;
  }>;
  update(todo: Todo): Promise<Todo>;
  delete(id: string): Promise<boolean>;
}
