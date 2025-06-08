- repository, usecase 抽象化する

- context で usecase を注入する

- データ操作は以下
  - get\_{resource}
    - Id -> Resource
  - get\_{resource}s
    - Query -> List(Resource)
  - create\_{resource}
    - Resource -> Result(Nil, List(Error))
  - update\_{resource}
    - Resource -> Result(Nil, List(Error))
  - delete\_{resource}
    - Resource -> Result(Nil, List(Error))
