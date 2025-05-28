import std/cookies
import std/times


proc setCookie*(key, value: string): string =
  cookies.setCookie(
    key, 
    value, 
    noName = true, 
    secure = true,
    httpOnly = true,
    expires = times.now() + 1.days,
    sameSite = SameSite.Strict
  )

proc deleteCookie*(key: string): string =
  cookies.setCookie(
    key, 
    "", 
    noName = true, 
    secure = true,
    httpOnly = true,
    expires = times.now() - 1.seconds,
    sameSite = SameSite.Strict
  )