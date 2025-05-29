import std/options
import src/features/rental/model


type
  RentalRepositoryOnMemory = ref object of RentalRepository
    item: CurrentState



proc newRentalRepositoryOnMemory*(): RentalRepositoryOnMemory =
  let item = newCurrentState("2024-02-02").get()
  RentalRepositoryOnMemory(item: item)


method find*(self: RentalRepositoryOnMemory): CurrentState =
  self.item
