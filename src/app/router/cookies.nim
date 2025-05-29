import std/cookies
import std/options
import std/times

type Cookie* = distinct string

proc setCookie*(key, value, path: string): Cookie =
  cookies.setCookie(
    key,
    value,
    path = path,
    noName = true,
    secure = true,
    httpOnly = true,
    expires = times.now() + 1.days,
    sameSite = SameSite.Strict
  ).Cookie

proc setCookie*(key, value: string): Cookie =
  setCookie(
    key,
    value,
    path = "",
  ).Cookie

proc setCookie*(self: Cookie, key, value, path: string): Cookie =
  let a = self.string
  let b = setCookie(
    key,
    value,
    path = "",
  ).string
  (a & "; " & b).Cookie

proc deleteCookie*(key: string): Cookie =
  cookies.setCookie(
    key,
    "",
    noName = true,
    secure = true,
    httpOnly = true,
    maxAge = some(0),
    sameSite = SameSite.Strict
  ).Cookie
