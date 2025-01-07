import src/shared/port/model

type User* = ref object of RootObj
  name{.required.}: string
  age: int


type UserRepository* = tuple
  list: proc(): seq[User]{.gcsafe.}
  save: proc(user: User): int64{.gcsafe.}


generateValidation(User)

func newUser*(name: string): User =
  User(name: name)

func name*(self: User): string = self.name

# HACK: refactor, should not has table name
func tableName*(self: User): string = "users"
