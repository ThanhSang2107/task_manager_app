const express = require('express');
const { getTasks, addTask, getTaskById, updateTask, deleteTask } = require('../data/db');
const { v4: uuidv4 } = require('uuid');
const jwt = require('jsonwebtoken');
const { jwtSecret } = require('../config');

const router = express.Router();

// JWT Authentication Middleware
function authMiddleware(req, res, next) {
  const header = req.headers.authorization;
  if (!header || !header.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'Không có token' });
  }
  const token = header.split(' ')[1];
  try {
    const decoded = jwt.verify(token, jwtSecret);
    req.userId = decoded.userId;
    next();
  } catch {
    return res.status(401).json({ message: 'Token không hợp lệ' });
  }
}

// GET all tasks
router.get('/', authMiddleware, (req, res) => {
  res.json(getTasks());
});

// GET task by id
router.get('/:id', authMiddleware, (req, res) => {
  const task = getTaskById(req.params.id);
  if (!task) return res.status(404).json({ message: 'Không tìm thấy task' });
  res.json(task);
});

// CREATE task
router.post('/', authMiddleware, (req, res) => {
  const { title, description, status, priority } = req.body;
  if (!title) return res.status(400).json({ message: 'Thiếu title' });

  const task = {
    id: uuidv4(),
    title,
    description: description || '',
    completed: false,
    status: status || 'todo',
    priority: typeof priority === 'number' ? priority : 2,
    createdAt: new Date().toISOString()
  };

  addTask(task);
  res.status(201).json(task);
});

// UPDATE task
router.put('/:id', authMiddleware, (req, res) => {
  const updates = {};
  ['title', 'description', 'completed', 'status', 'priority'].forEach(k => {
    if (req.body[k] !== undefined) updates[k] = req.body[k];
  });

  const updated = updateTask(req.params.id, updates);
  if (!updated) return res.status(404).json({ message: 'Không tìm thấy task' });
  res.json(updated);
});

// DELETE task
router.delete('/:id', authMiddleware, (req, res) => {
  deleteTask(req.params.id);
  res.status(204).end();
});

// TOGGLE completed status
router.patch('/:id/toggle', authMiddleware, (req, res) => {
  const task = getTaskById(req.params.id);
  if (!task) return res.status(404).json({ message: 'Không tìm thấy task' });

  task.completed = !task.completed;
  res.json({ message: 'Đã cập nhật trạng thái completed', task });
});

module.exports = router;
