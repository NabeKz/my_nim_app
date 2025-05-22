
import std/sugar

import src/shared/db/conn
import src/features/information/list


type
  InformationRepositoryOnSqlite = ref object
    db: DbConn

  InformationRepositoryOnMemory = ref object
    information: seq[InformationReadModel]


proc newInformationRepositoryOnMemory*(): InformationRepositoryOnMemory =
  InformationRepositoryOnMemory(information: @[
    newInformationReadModel(id = 1, content = "aaa"),
    newInformationReadModel(id = 2, content = "bbb"),
  ])



proc listCommand*(self: InformationRepositoryOnMemory): InformationListCommand =
  () => self.information
