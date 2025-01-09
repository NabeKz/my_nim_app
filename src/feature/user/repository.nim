import src/feature/user/model
import src/shared/db/conn
import src/shared/port/rdb

type UserRdbRepository* = ref object
  db: DbConn


generateDeSerialize(UserRecord)

proc list*(self: UserRdbRepository): seq[UserRecord] =
  # discard self.db.select(UserRecord())
  @[]
  

proc create*(self: UserRdbRepository, model: User): int64 =
  self.db.save(model)


func toInterface*(self: UserRdbRepository): UserRepository =
  (
    list: proc(): seq[UserRecord] = self.list(),
    save: proc(user: User): int64 = self.create(user)
  )

func newUserRepository*(db: DbConn): UserRepository = 
  UserRdbRepository(db: db).toInterface()


when isMainModule:
  import std/json
  import std/sequtils
  import std/tables

  dbOnMemory db:
    for row in db.select(UserRecord()):
      echo row
      let user = deSerialize(row)
      echo (%* user)
      