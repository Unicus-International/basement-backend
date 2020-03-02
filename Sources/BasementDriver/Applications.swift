import Foundation

import PerfectHTTP
import PerfectHTTPServer
import PerfectPostgreSQL
import PerfectCRUD
import PerfectSession
import PerfectLib

extension BasementDriver {

  static var log = Log.self

  static var database: Database<PostgresDatabaseConfiguration>! = nil

  static var routes: Routes {
    var routes = Routes()

    routes.add(Self.cardRoutes)
    routes.add(Self.userRoutes)

    return routes
  }

  static func initializeDatabase() throws {
    database = Database(configuration: try PostgresDatabaseConfiguration("dbname=basement user=basement"))

    try initializeDatabaseTables()

    #if DEBUG
    try insertDebugData()
    #endif
  }

  static func runServer() throws {
    let server = HTTPServer()

    server.addRoutes(routes)
    server.serverPort = 8181
    server.serverAddress = "::1"

    SessionConfig.name = "BasementDriver"
    SessionConfig.cookieDomain = "basement.yoga.unicus.com"

    let sessionDriver = SessionMemoryDriver()

    server.setRequestFilters([(LoggingFilter(), .high), sessionDriver.requestFilter])
    server.setResponseFilters([sessionDriver.responseFilter])

    try server.start()
  }

  struct LoggingFilter: HTTPRequestFilter {
    func filter(request: HTTPRequest, response: HTTPResponse, callback: (HTTPRequestFilterResult) -> ()) {
      log.info(message: "\(request.method) \(request.uri)")

      callback(.continue(request, response))
    }
  }
}
