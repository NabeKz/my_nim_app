import std/options

import src/shared/results
import ./events
import ./model

type
  BookListQuery* = ref object
    page*: Option[int]
    pageSize*: Option[int]
    sortBy*: Option[string]

  BookListResult = ref object
    books*: seq[Book]
    totalCount*: int

  GetBooksWorkflow = ref object
    repository*: BookRepository
    userId*: string

proc validateQuery(query: BookListQuery): Result[BookListQuery, BookError] =
  ok[BookListQuery, BookError](query)

proc execute*(workflow: GetBooksWorkflow, query: BookListQuery): Result[BookListResult, BookError] = 
  let validatedQuery = validateQuery(query)
  if validatedQuery.isOk:
    return ok[BookListResult, BookError](
      BookListResult(
        books: workflow.repository.list(),
        totalCount: 1
      )
    )
