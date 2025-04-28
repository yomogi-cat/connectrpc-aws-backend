import { ConnectRouter } from "@connectrpc/connect";
import { TodoService } from "./buf/todo/v1/todo_pb";
import { createTodo, getTodo, listTodos, updateTodo, deleteTodo } from "./todoService";
export const routes = (router: ConnectRouter) => {
  router.service(TodoService, {
    createTodo,
    getTodo,
    listTodos,
    updateTodo,
    deleteTodo,
  });
};
