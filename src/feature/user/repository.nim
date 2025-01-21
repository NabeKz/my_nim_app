import src/feature/user/model
import src/shared/db/conn
import src/shared/port/rdb

type UserRdbRepository* = ref object
  db: DbConn


generateDeSerialize(UserRecord)

proc list*(self: UserRdbRepository): seq[UserRecord] =
  for record in self.db.select(UserRecord()):
    result.add deSerialize(record)
  

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

  dbOnMemory db:
    let repository = newUserRepository(db)
    for r in repository.list():
      debugEcho %r
      