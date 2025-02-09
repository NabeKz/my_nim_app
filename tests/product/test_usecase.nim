import std/unittest
import std/json

import src/entities/product/repository
import src/entities/product/usecase

let repo = newProductRepositoryOnMemory().toInterface()

block fetch:
  let u1 = newProductFetchUsecase repo
  let got = u1.invoke()
  check got.len == 2

block add:
  let u2 = newProductCreateUsecase repo
  let value = %* {
    "hoge": "fuga"
  }
  try:
    u2.invoke(ProductInputDto())
  except:
    echo getCurrentExceptionMsg()