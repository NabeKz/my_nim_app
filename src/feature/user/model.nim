import src/shared/port/model

type User* = ref object of RootObj
  name{.required.}: string
  age: int

type UserRecord* = ref object of User
  id: int64


type UserRepository* = tuple
  list: proc(): seq[UserRecord]{.gcsafe.}
  save: proc(user: User): int64{.gcsafe.}


generateValidation(User)

func newUser*(name: string): User =
  User(name: name)

func name*(self: User): string = self.name
func age*(self: User): int = self.age
func id*(self: User): int64 = self.id

# HACK: refactor, should not has table name
method tableName*(self: User): string{.base.} = "users"
