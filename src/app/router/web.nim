import src/shared/handler

const headers = { 
  "Content-Type": "text/html charset=utf8;"
}

proc router*(req: Request) {.async, gcsafe.}  =
   if req.url.path == "/":
    await req.respond(Http200, "Hello", headers.newHttpHeaders())
      
   await req.respond(Http404, $Http404)