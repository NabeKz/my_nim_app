type User = ref object
  name: string

func newUser*(name: string): User =
  User(name: name)
