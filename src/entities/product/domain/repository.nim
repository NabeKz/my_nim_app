import ./model

type
  ProductRepository* = ref object of RootObj

method list*(self: ProductRepository): seq[ProductReadModel]{.base.} = discard
method save*(self: ProductRepository, model: ProductWriteModel){.base.} = discard