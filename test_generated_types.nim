# Auto-generated from database schema

import std/options

type
  Users* = ref object
    id*: int
    name*: string
    email*: Option[string]
    age*: Option[int]
    created_at*: Option[string]

type
  Books* = ref object
    id*: int
    title*: string
    author*: string
    isbn*: Option[string]
    price*: Option[float]
    published_year*: Option[int]

type
  User_books* = ref object
    user_id*: int
    book_id*: int
    borrowed_at*: Option[string]
    returned_at*: Option[string]

