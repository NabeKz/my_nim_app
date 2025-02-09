import std/unittest
import std/json
import std/asynchttpserver

import src/entities/product/repository
import src/entities/product/usecase
import src/entities/product/controller

let repo = newProductRepositoryOnMemory().toInterface()


block add:
  let postController = newProductCreateController newProductCreateUsecase repo
  let body = %* {
    "name": "a",
    "description": "a",
    "price": 0,
    "stock": 1,
  }

  let got = postController.build($body)

  check got == (Http201, "ok")
  