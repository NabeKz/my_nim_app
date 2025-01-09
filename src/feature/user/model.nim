import src/shared/port/model

type User* = ref object of RootObj
  name*{.required.}: string
  age*: int

type UserRecord* = ref object of RootObj
  id*: int64
  name*: string
  age*: int


type UserRepository* = tuple
  list: proc(): seq[UserRecord]{.gcsafe.}
  save: proc(user: User): int64{.gcsafe.}


generateValidation(User)

func newUser*(name: string): User =
  User(name: name)


# HACK: refactor, should not has table name
func tableName*(self: User): string = "users"
func tableName*(self: UserRecord): string = "users"
