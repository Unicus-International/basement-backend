import Foundation

import PerfectHTTP
import PerfectSession

extension BasementDriver {

  static var userRoutes: Routes {
    var userRoutes = Routes(baseUri: "/user", handler: baseHandler)

    userRoutes.add(method: .post, uri: "/register", handler: registerHandler)
    userRoutes.add(method: .post, uri: "/login", handler: loginHandler)

    userRoutes.add(method: .get, uri: "/profile", handler: profileHandler)
    userRoutes.add(method: .get, uri: "/cards", handler: cardsHandler)

    return userRoutes
  }

}

private extension BasementDriver {

  static func baseHandler(request: HTTPRequest, response: HTTPResponse) {
    if let username = request.session?.userid, let user = try? User.named(username) {
      request.scratchPad["user"] = user
    }

    response
      .next()
  }

  static func registerHandler(request: HTTPRequest, response: HTTPResponse) {

  }

  static func loginHandler(request: HTTPRequest, response: HTTPResponse) {

  }

  static func profileHandler(request: HTTPRequest, response: HTTPResponse) {

  }

  static func cardsHandler(request: HTTPRequest, response: HTTPResponse) {

  }

}
