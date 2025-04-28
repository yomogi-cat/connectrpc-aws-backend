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
  CreateTodoResponseSchema,
  GetTodoResponseSchema,
  ListTodosResponseSchema,
  UpdateTodoResponseSchema,
  DeleteTodoResponseSchema,
} from "./buf/todo/v1/todo_pb";
import { create } from "@bufbuild/protobuf";
import { logger } from "./logger";

export const createTodo = async (request: CreateTodoRequest) => {
  logger.info({ request }, "Creating new todo");
  return create(CreateTodoResponseSchema, { item: undefined });
};

export const getTodo = async (request: GetTodoRequest): Promise<GetTodoResponse> => {
  logger.info({ request }, "Getting todo");
  return create(GetTodoResponseSchema, { item: undefined });
};

export const listTodos = async (request: ListTodosRequest): Promise<ListTodosResponse> => {
  logger.info({ request }, "Listing todos");
  return create(ListTodosResponseSchema, { items: undefined });
};

export const updateTodo = async (request: UpdateTodoRequest): Promise<UpdateTodoResponse> => {
  logger.info({ request }, "Updating todo");
  return create(UpdateTodoResponseSchema, { item: undefined });
};

export const deleteTodo = async (request: DeleteTodoRequest): Promise<DeleteTodoResponse> => {
  logger.info({ request }, "Deleting todo");
  return create(DeleteTodoResponseSchema, { success: true });
};
