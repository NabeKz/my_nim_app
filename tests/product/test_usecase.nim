import std/unittest
import std/options
import std/json

import src/entities/product/adaptor/repository/on_memory
import src/entities/product/usecase/create

let repo = newProductRepositoryOnMemory().saveCommand


block valid:
  let addUsecase = newProductCreateUsecase repo
  let value = ProductInputDto(
    name: "a",
    description: "",
    price: 10,
    stock: 10,
  )

  let errors = addUsecase(value)

  if (errors.len > 0):
    raise newException(ValueError, $errors)
  
  check errors.len == 0