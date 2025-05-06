const bcrypt = require('bcryptjs');

const users = [];   // In-memory users
const tasks = [];   // In-memory tasks

/**
 * Thêm user mới với password đã được hash sẵn
 */
function addUser(username, email, hashedPassword) {
  const newUser = {
    id: Date.now().toString(),
    username,
    email,
    password: hashedPassword,
  };
  users.push(newUser);
  return newUser;
}

/** Tìm user theo username */
function findUserByUsername(username) {
  return users.find(u => u.username === username) || null;
}

/** Tìm user theo username hoặc email (check đăng ký) */
function findUser(username, email) {
  return users.find(u => u.username === username || u.email === email) || null;
}

// CRUD tasks
function addTask(task) { tasks.push(task); return task; }
function getTasks() { return tasks; }
function getTaskById(id) { return tasks.find(t => t.id === id) || null; }
function updateTask(id, updates) {
  const t = getTaskById(id);
  if (!t) return null;
  Object.assign(t, updates);
  return t;
}
function deleteTask(id) {
  const idx = tasks.findIndex(t => t.id === id);
  if (idx !== -1) tasks.splice(idx, 1);
}

module.exports = {
  users,
  tasks,
  addUser,
  findUserByUsername,
  findUser,
  addTask,
  getTasks,
  getTaskById,
  updateTask,
  deleteTask,
};