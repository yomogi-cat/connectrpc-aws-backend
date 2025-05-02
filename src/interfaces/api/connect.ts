import { ConnectRouter } from "@connectrpc/connect";
import { TodoService } from "../../infrastructure/proto/todo/v1/todo_pb";
import { TodoHandler } from "./handlers/TodoHandler";

export const routes = (router: ConnectRouter, todoHandler: TodoHandler) => {
  router.service(TodoService, {
    createTodo: todoHandler.createTodo.bind(todoHandler),
    getTodo: todoHandler.getTodo.bind(todoHandler),
    listTodos: todoHandler.listTodos.bind(todoHandler),
    updateTodo: todoHandler.updateTodo.bind(todoHandler),
    deleteTodo: todoHandler.deleteTodo.bind(todoHandler),
  });
};