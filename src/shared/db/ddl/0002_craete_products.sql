CREATE TABLE products (
  id INTEGER PRIMARY KEY AUTOINCREMENT CHECK(id > 0),
  name TEXT CHECK(length(name) <= 50),
  description TEXT,
  price INTEGER CHECK(price > 0),
  stock INTEGER CHECK(stock > 0)
) STRICT;
