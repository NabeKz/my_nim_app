import src/feature/user/model
import src/shared/db/conn

type UserRdbRepository* = ref object
  db: DbConn


proc list*(self: UserRdbRepository): seq[User] =
  @[]

proc create*(self: UserRdbRepository, model: User): int64 =
  self.db.save(model)


func toInterface*(self: UserRdbRepository): UserRepository =
  (
    list: proc(): seq[User] = self.list(),
    save: proc(user: User): int64 = self.create(user)
  )

func newUserRepository*(db: DbConn): UserRepository = 
  UserRdbRepository(db: db).toInterface()