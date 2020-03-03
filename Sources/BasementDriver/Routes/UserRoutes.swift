import Foundation

import PerfectHTTP
import PerfectSession

extension BasementDriver {

  static var userRoutes: Routes {
    var userRoutes = Routes(baseUri: "/user")

    userRoutes.add(method: .post, uri: "/register", handler: registerHandler)
    userRoutes.add(method: .post, uri: "/login", handler: loginHandler)

    userRoutes.add(method: .get, uri: "/profile", handler: profileHandler)
    userRoutes.add(method: .get, uri: "/cards", handler: cardsHandler)

    return userRoutes
  }

}

private extension BasementDriver {

  static func registerHandler(request: HTTPRequest, response: HTTPResponse) {
    guard
      (request.session?.userid ?? "") == ""
    else {
      log.debug(message: "403 User already logged in")
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
      log.debug(message: "400 Missing or malformed field")
      return response
        .completed(status: .badRequest)
    }

    guard
      try! User.isRegisterable(username: username)
    else {
      log.debug(message: "403 Username \(username) taken or invalid")
      return response
        .completed(status: .forbidden)
    }

    guard
      let user = try? User.newUser(username: username, password: passwordOne, emailAddress: emailAddress)
    else {
      log.debug(message: "500 Could not create new user")
      return response
        .completed(status: .internalServerError)
    }

    log.info(message: "201 Created")
    request.session?.userid = user.username
    response
      .addHeader(.location, value: "profile")
      .completed(status: .created)
  }

  static func loginHandler(request: HTTPRequest, response: HTTPResponse) {
    guard
      let username = request.param(name: "username"),
      let password = request.param(name: "password")
    else {
      log.debug(message: "400 Missing field")
      return response
        .completed(status: .badRequest)
    }

    guard
      let user = try? User.named(username),
      user.checkPassword(password)
    else {
      log.debug(message: "403 No such user or wrong password")
      return response
        .completed(status: .forbidden)
    }

    log.info(message: "204 No Content")
    request.session?.userid = user.username
    response
      .completed(status: .noContent)
  }

  static func profileHandler(request: HTTPRequest, response: HTTPResponse) {
    guard
      let user = request.scratchPad["user"] as? User
    else {
      log.debug(message: "403 No user logged in")
      return response
        .completed(status: .forbidden)
    }

    log.info(message: "200 OK")
    response
      .JSON(encoding: user)
  }

  static func cardsHandler(request: HTTPRequest, response: HTTPResponse) {
    guard
      let user = request.scratchPad["user"] as? User
    else {
      log.debug(message: "403 No user logged in")
      return response
        .completed(status: .forbidden)
    }

    log.info(message: "200 OK")
    response
      .JSON(encoding: user.cards)
  }

}
