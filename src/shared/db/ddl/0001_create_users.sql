CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT CHECK (id > 0),
  name TEXT CHECK(length(name) < 256),
  email TEXT UNIQUE,
  age INTEGER CHECK(age > -1)
) STRICT;
