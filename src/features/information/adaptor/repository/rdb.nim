import std/sugar

import src/shared/db/conn
import src/features/information/list


type
  InformationRepositoryOnSqlite* = ref object
    dbConn: DbConn


type InformationTable = InformationReadModel

func tableName(self: InformationTable): string = "information"

proc newInformationRepository*(dbConn: DbConn): InformationRepositoryOnSqlite =
  InformationRepositoryOnSqlite(dbConn: dbConn)



proc listCommand*(self: InformationRepositoryOnSqlite): InformationListCommand =
  () => self.db.select(InformationTable())
