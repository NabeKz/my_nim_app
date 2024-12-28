import src/shared/port/http
import src/feature/user/model

type UnValidateForm = ref object
  name: string
  age: int

generateUnmarshal(UnValidateForm)


proc to*(body: string, t: type User): Result[User] =
  let form = body.toJson().unmarshal()
  let user = newUser(name = form.name)
  match(user)


when isMainModule:
  block:
    let body = """{"name": 1}"""
    let jsonNode = body.toJson()
    let user = body.to(User)
    case user.kind
    of kOk:
      echo user.val.name
    of kErr:
      echo user.errors

  block:
    let body = """{"name": "hoge"}"""
    let jsonNode = body.toJson()
    let user = body.to(User)
    case user.kind
    of kOk:
      echo user.val.name
    of kErr:
      echo user.errors

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
