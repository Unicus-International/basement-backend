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
    guard
      request.session?.userid == nil
    else {
      return response
        .completed(status: .forbidden)
    }

    guard
      let username = request.param(name: "username"),
      let emailAddress = request.param(name: "email_address"),
      emailAddress.isLikelyEmail,
      let passwordOne = request.param(name: "password_one"),
      let passwordTwo = request.param(name: "password_two"),
      passwordOne == passwordTwo
    else {
      return response
        .completed(status: .badRequest)
    }

    guard
      try! User.isRegisterable(username: username)
    else {
      return response
        .completed(status: .forbidden)
    }

    guard
      let user = try? User.newUser(username: username, password: passwordOne, emailAddress: emailAddress)
    else {
      return response
        .completed(status: .internalServerError)
    }

    request.session?.userid = user.username
    response
      .completed(status: .created)
  }

  static func loginHandler(request: HTTPRequest, response: HTTPResponse) {
    guard
      let username = request.param(name: "username"),
      let password = request.param(name: "password")
    else {
      return response
        .completed(status: .badRequest)
    }

    guard
      let user = try? User.named(username),
      user.checkPassword(password)
    else {
      return response
        .completed(status: .forbidden)
    }

    request.session?.userid = user.username
    response
      .completed(status: .noContent)
  }

  static func profileHandler(request: HTTPRequest, response: HTTPResponse) {
    guard
      let user = request.scratchPad["user"] as? User
    else {
      return response
        .completed(status: .forbidden)
    }

    response
      .JSON(encoding: user)
  }

  static func cardsHandler(request: HTTPRequest, response: HTTPResponse) {
    guard
      let user = request.scratchPad["user"] as? User
    else {
      return response
        .completed(status: .forbidden)
    }

    response
      .JSON(encoding: user.cards)
  }

}
