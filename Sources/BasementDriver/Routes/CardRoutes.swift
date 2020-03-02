import Foundation

import PerfectHTTP

extension BasementDriver {

  static var cardRoutes: Routes {
    var cardRoutes = Routes(baseUri: "/card")

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

private let jsonDecoder: JSONDecoder = {
  let decoder = JSONDecoder()

  decoder.dateDecodingStrategy = .iso8601

  return decoder
}()

private extension Card {

  struct JSONDecodingData: Decodable {
    let id: UUID?

    let title: String
    let genre: String
    let description: String

    let date: Date
    let location: String

    let image_url: URL
  }

  static func newCard(from data: JSONDecodingData, by author: User) throws -> Card? {
    try Self(
      id: data.id ?? UUID(),
      author_id: author.id,
      title: data.title,
      genre: data.genre,
      description: data.description,
      date: data.date,
      location: data.location,
      image_url: data.image_url
    ).insert()
  }

}

private extension BasementDriver {

  static func createHandler(request: HTTPRequest, response: HTTPResponse) {
    guard
      let user = request.scratchPad["user"] as? User
    else {
      return response
        .completed(status: .forbidden)
    }

    guard
      let postBody = request.postBodyBytes,
      let decodingData = try? jsonDecoder.decode(Card.JSONDecodingData.self, from: Data(postBody))
    else {
      return response
        .completed(status: .badRequest)
    }

    guard
      let card = try? Card.newCard(from: decodingData, by: user)
    else {
      return response
        .completed(status: .internalServerError)
    }

    response
      .addHeader(.location, value: "\(card.id)/read")
      .completed(status: .created)
  }

  static func listHandler(request: HTTPRequest, response: HTTPResponse) {
    guard
      let page: Int = request.param(name: "page").flatMap({ Int($0) }),
      let limit: Int = request.param(name: "limit").flatMap({ Int($0) })
    else {
      return response
        .completed(status: .badRequest)
    }

    guard
      let cards = try? Card.all(page: page, limit: limit)
    else {
      return response
        .completed(status: .internalServerError)
    }

    response
      .JSON(encoding: cards)
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
    response
      .completed(status: .notImplemented)
  }

  static func deleteHandler(request: HTTPRequest, response: HTTPResponse) {
    guard
      let user = request.scratchPad["user"] as? User,
      let card = request.scratchPad["card"] as? Card,
      user.canDelete(card: card)
    else {
      return response
        .completed(status: .forbidden)
    }

    try! card.delete()

    response
      .completed(status: .noContent)
  }

}
