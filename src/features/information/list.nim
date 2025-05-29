import std/json
import std/sugar

import src/shared/handler
import src/shared/port/http


type
  InformationReadModel* = ref object
    id*: int64
    content*: string

  InformationListCommand* =
    ((){.gcsafe.} -> seq[InformationReadModel])

  InformationListUsecase* =
    ((){.gcsafe.} -> seq[InformationReadModel])

  InformationListController* = Handler


func newInformationReadModel*(id: int64,
    content: string): InformationReadModel =
  InformationReadModel(
    id: id,
    content: content,
  )


proc newInformationFetchListUsecase*(command: InformationListCommand): InformationListUsecase =
  let data = command()
  () => data


proc newInformationListController*(usecase: InformationListUsecase): InformationListController =
  (req: Request) => (
    let data = usecase()
    req.json(Http200, data)
  )

