import src/shared/port/http
import src/feature/user/model

type UnValidateForm = ref object
  name: string
  age: int

generateUnmarshal(UnValidateForm)


proc to*(body: string, t: type User): User =
  let form = body.toJson().unmarshal()
  let user = newUser(name = form.name)
  let errors = user.validate()
  if errors.len > 0:
    raise newException(ValueError, $errors)
  else:
    user



when isMainModule:
  import std/unittest
  block:
    let body = """{"name": 1}"""
    let jsonNode = body.toJson()

    check body.to(User).name == ""
  
  block:
    let body = """{"name": "hoge"}"""
    let jsonNode = body.toJson()

    check body.to(User).name == "hoge"

  block:
    let user = newUser(name = "")
    debugEcho user.validate()

# StmtList
  # TypeSection
    # TypeDef
      # Ident "UnValidateForm"
      # Empty
      # RefTy
        # ObjectTy
          # Empty
          # Empty
          # RecList
            # IdentDefs
              # PragmaExpr
                # Ident "name"
                # Pragma
                  # Ident "required"
                # Ident "string"
                # Empty
              # IdentDefs
                # Postfix
                  # Ident "*"
                  # Ident "age"
                # Ident "int"
                # Empty
