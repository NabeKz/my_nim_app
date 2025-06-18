# Auto-generated from database schema

import std/options

type
  Users* = ref object
    id*: int
    name*: Option[string]
    email*: Option[string]
    age*: Option[int]

type
  Products* = ref object
    id*: int
    name*: Option[string]
    description*: Option[string]
    price*: Option[int]
    stock*: Option[int]

