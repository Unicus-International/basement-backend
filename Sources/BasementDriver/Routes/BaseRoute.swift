import Foundation

import PerfectHTTP
import PerfectSession

extension BasementDriver {

  static var baseRoutes: Routes {
    Routes(baseUri: "/v0", handler: baseHandler)
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

}
