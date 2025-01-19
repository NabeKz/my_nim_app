import ./model

proc list*(repository: UserRepository): seq[User] =
  for record in repository.list():
    result.add to(record)


proc create*(repository: UserRepository, user: User): tuple[id: int64, user: User] =
  let errors = user.validate()
  if errors.len > 0:
    raise newException(ValueError, $errors)
  else:
    let id = repository.save(user)
    (id, user)