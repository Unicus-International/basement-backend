import Foundation

import PerfectHTTP
import PerfectSession

extension BasementDriver {

  static var baseRoutes: Routes {
    var baseRoutes = Routes(baseUri: "/v0", handler: baseHandler)

    baseRoutes.add(method: .options, uri: "**", handler: optionsHandler)

    return baseRoutes
  }

}

private extension BasementDriver {

  static func baseHandler(request: HTTPRequest, response: HTTPResponse) {
    if
      let username = request.session?.userid,
      username != "",
      let user = try? User.named(username)
    {
      request.scratchPad["user"] = user
    }

    response
      .next()
  }

  static func optionsHandler(request: HTTPRequest, response: HTTPResponse) {
    struct Response: Codable {
      let Success = "CORS Request"
    }

    response
      .JSON(encoding: Response())
  }

}
