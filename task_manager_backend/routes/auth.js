const express = require('express');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const { jwtSecret } = require('../config');
const { addUser, findUserByUsername, findUser } = require('../data/db');

const router = express.Router();

// POST /api/auth/register
router.post('/register', (req, res) => {
  const { username, email, password } = req.body;
  if (!username || !email || !password) {
    return res.status(400).json({ message: 'Vui lòng nhập đầy đủ thông tin' });
  }
  if (findUser(username, email)) {
    return res.status(400).json({ message: 'Người dùng đã tồn tại' });
  }
  const hashedPassword = bcrypt.hashSync(password, 8);
  const user = addUser(username, email, hashedPassword);
  const token = jwt.sign({ userId: user.id }, jwtSecret, { expiresIn: '1h' });
  return res.status(201).json({
    message: 'Đăng ký thành công',
    token,
    user: { id: user.id, username: user.username, email: user.email },
  });
});

// POST /api/auth/login
router.post('/login', (req, res) => {
  const { username, password } = req.body;
  const user = findUserByUsername(username);
  if (!user || !bcrypt.compareSync(password, user.password)) {
    return res.status(401).json({ message: 'Sai tên đăng nhập hoặc mật khẩu' });
  }
  const token = jwt.sign({ userId: user.id }, jwtSecret, { expiresIn: '1h' });
  return res.status(200).json({ token });
});

module.exports = router;