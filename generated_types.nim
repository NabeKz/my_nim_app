# Auto-generated from database schema

import std/options

type
  Users* = ref object
    id*: int
    name*: string

type
  Books* = ref object
    id*: int
    title*: Option[string]

