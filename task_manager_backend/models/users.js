const bcrypt = require('bcryptjs');

let users = [];

function addUser(username, email, password) {
  const hashedPassword = bcrypt.hashSync(password, 8);
  const newUser = { id: Date.now().toString(), username, email, password: hashedPassword };
  users.push(newUser);
  return newUser;
}

function findUser(username) {
  return users.find(user => user.username === username);
}

module.exports = { addUser, findUser };
