import src/shared/port/model

type User* = ref object of RootObj
  name{.required.}: string
  age: int


type UserRepository* = tuple
  list: proc(): seq[string]
  save: proc(user: User)


generateValidation(User)

func newUser*(name: string): User =
  User(name: name)

func name*(self: User): string = self.name
