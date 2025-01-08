import src/feature/user/model
import src/shared/db/conn

type UserRdbRepository* = ref object
  db: DbConn


proc list*(self: UserRdbRepository): seq[UserRecord] =
  self.db.select(UserRecord())
  

proc create*(self: UserRdbRepository, model: User): int64 =
  self.db.save(model)


func toInterface*(self: UserRdbRepository): UserRepository =
  (
    list: proc(): seq[UserRecord] = self.list(),
    save: proc(user: User): int64 = self.create(user)
  )

func newUserRepository*(db: DbConn): UserRepository = 
  UserRdbRepository(db: db).toInterface()


when not defined(release):
  echo "dev"

when isMainModule:
  import std/json
  import std/sequtils
  import std/tables

  dbOnMemory db:
    let rows = db.getAllRows sql"select * from users;"
    let fileds = ["id", "name", "age"]
    for row in rows:
      let node = % zip(fileds, row).toTable()
      echo to(node, UserRecord).name
      # let node = row
      # let user = to(node, User)
    # discard db.select(User())