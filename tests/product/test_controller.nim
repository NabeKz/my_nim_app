import std/unittest
import std/json
import std/asynchttpserver

import src/entities/product/repository
import src/entities/product/usecase
import src/entities/product/controller

let repo = newProductRepositoryOnMemory().toInterface()


block valid:
  let postController = newProductCreateController newProductCreateUsecase repo
  let body = %* {
    "name": "a",
    "description": "a",
    "price": 0,
    "stock": 1,
  }

  let got = postController.build($body)

  check got == (Http201, "ok")
  
block invalid:
  let postController = newProductCreateController newProductCreateUsecase repo
  let 
    body1 = %* {
      "name": "",
      "description": "a",
      "price": 0,
      "stock": 1,
    }
    body2 = %* {
      "name": 1,
      "description": "a",
      "price": 0,
      "stock": 1,
    }
    body3 = %* {
      "description": "a",
      "price": 0,
      "stock": 1,
    }

  let 
    got1 = postController.build($body1)
    got2 = postController.build($body2)
    got3 = postController.build($body3)

  check got1 == (Http400, $(%* @["name is required"]))
  check got2 == (Http400, $(%* @["name is required"]))
  check got3 == (Http400, $(%* @["name is required"]))
  