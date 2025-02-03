import src/shared/db/conn

type Context = ref object
  db*: DbConn