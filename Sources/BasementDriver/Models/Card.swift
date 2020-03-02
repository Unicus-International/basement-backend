import Foundation

struct Card: Fetchable, ChildFetchable, Deletable {
  let id: UUID
  let author_id: UUID

  let title: String
  let genre: String
  let description: String

  let date: Date
  let location: String

  let image_url: URL

  static let sortingKey: PartialKeyPath<Self> = \.date
  static let sortDescending = true
}

extension Card: ParentFetcher {

  var author: User { fetchParent(key: self.author_id) }

}

extension User: ChildFetcher {

  var cards: [Card] { fetchChildren(foreignKey: \.author_id) }

  func canDelete(card: Card) -> Bool {
    card.author_id == id
  }

}
