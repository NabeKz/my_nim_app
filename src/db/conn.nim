import db_connector/db_sqlite


func dbConn*(filename: string): DbConn = 
  open(filename, "", "", "")