type
  DomainEvent* = enum
    BookCreated
    BookUpdated
    BookDeleted

  EventHandler = proc(event: DomainEvent){.gcsafe.}

var eventHandlers*: seq[EventHandler] = @[]

proc publish*(event: DomainEvent): void =
  for handler in eventHandlers:
    handler(event)
