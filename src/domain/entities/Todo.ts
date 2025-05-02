export interface Todo {
  id: string;
  title: string;
  completed: boolean;
  createdAt: string;
  updatedAt: string;
}

export class TodoEntity implements Todo {
  public id: string;
  public title: string;
  public completed: boolean;
  public createdAt: string;
  public updatedAt: string;

  constructor(id: string, title: string, completed: boolean = false, createdAt?: string, updatedAt?: string) {
    this.id = id;
    this.title = title;
    this.completed = completed;
    this.createdAt = createdAt || new Date().toISOString();
    this.updatedAt = updatedAt || new Date().toISOString();
  }

  static create(title: string): TodoEntity {
    const id = generateId();
    return new TodoEntity(id, title);
  }

  markAsCompleted(): void {
    this.completed = true;
    this.updatedAt = new Date().toISOString();
  }

  updateTitle(title: string): void {
    this.title = title;
    this.updatedAt = new Date().toISOString();
  }

  update(title?: string, completed?: boolean): void {
    if (title !== undefined) {
      this.title = title;
    }
    if (completed !== undefined) {
      this.completed = completed;
    }
    this.updatedAt = new Date().toISOString();
  }
}
function generateId(): string {
  return Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
}
