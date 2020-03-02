import Foundation

import PerfectHTTP

extension BasementDriver {

  static var cardRoutes: Routes {
    var cardRoutes = Routes(baseUri: "/cards")

    cardRoutes.add(method: .post, uri: "/create", handler: createHandler)
    cardRoutes.add(method: .get, uri: "/list", handler: listHandler)

    var fetchedRoutes = Routes(baseUri: "/{card_id}", handler: fetchHandler)

    fetchedRoutes.add(method: .get, uri: "/read", handler: readHandler)
    fetchedRoutes.add(method: .post, uri: "/update", handler: updateHandler)
    fetchedRoutes.add(method: .get, uri: "/delete", handler: deleteHandler)

    cardRoutes.add(fetchedRoutes)

    return cardRoutes
  }

}

private extension BasementDriver {

  static func createHandler(request: HTTPRequest, response: HTTPResponse) {

  }

  static func listHandler(request: HTTPRequest, response: HTTPResponse) {

  }

  static func fetchHandler(request: HTTPRequest, response: HTTPResponse) {
    guard
      let card_id = request.urlVariables["card_id"],
      let card_uuid = UUID(uuidString: card_id)
    else {
      return response
        .completed(status: .badRequest)
    }

    guard
      let card = Card.search(key: card_uuid)
    else {
      return response
        .completed(status: .notFound);
    }

    request.scratchPad["card"] = card
    response
      .next()
  }

  static func readHandler(request: HTTPRequest, response: HTTPResponse) {
    guard
      let card = request.scratchPad["card"] as? Card
    else {
      return response
        .completed(status: .internalServerError)
    }

    response
      .JSON(encoding: card)
  }

  static func updateHandler(request: HTTPRequest, response: HTTPResponse) {

  }

  static func deleteHandler(request: HTTPRequest, response: HTTPResponse) {

  }

}
