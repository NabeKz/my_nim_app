type User = ref object of RootObj
  name: string


type UserRepository = tuple
  list: proc(): seq[string]
  save: proc(user: User)
