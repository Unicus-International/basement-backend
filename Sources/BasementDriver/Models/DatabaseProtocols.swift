import Foundation

import PerfectCRUD

// MARK: Fetcher

protocol Fetcher: ParentFetcher, ChildFetcher { }
protocol Fetchable: AllFetchable {}

// MARK: AllFetchable

protocol AllFetchable: ChildFetchable {

  static var all: [Self] { get }
  static func all(page: Int, limit: Int) throws -> [Self]

  static var count: Int { get }

}

extension AllFetchable {

  static var all: [Self] {
    try! BasementDriver.database.table(Self.self)
      .order(by: Self.sortingKey)
      .select()
      .map { $0 }
  }

  static func all(page: Int, limit: Int) throws -> [Self] {
    try BasementDriver.database.table(Self.self)
      .order(by: Self.sortingKey)
      .limit(limit, skip: page * limit)
      .select()
      .map { $0 }
  }

  static var count: Int {
    try! BasementDriver.database.table(Self.self)
      .count()
  }

}

// MARK: NamedFetchable

protocol NamedFetchable: Insertable {

  static func named(_ key: String) throws -> Self?
  static func named(key: String, keyPath: KeyPath<Self,String>) throws -> Self?

  static var defaultNamedKeyPath: KeyPath<Self,String> { get }

}

extension NamedFetchable {

  static func named(_ key: String) throws -> Self? {
    try named(key: key, keyPath: defaultNamedKeyPath)
  }

  static func named(key: String, keyPath: KeyPath<Self,String>) throws -> Self? {
    try BasementDriver.database.table(Self.self)
      .where(keyPath == key)
      .first()
  }

}

// MARK: ChildFetcher

protocol ChildFetchable: Addressable {

  static var sortingKey: PartialKeyPath<Self> { get }
  static var sortDescending: Bool { get }

}

extension ChildFetchable {

  static var sortDescending: Bool { false }

}

protocol ChildFetcher: Addressable {

  func firstChild<Target>(foreignKey: KeyPath<Target,UUID>) -> Target? where Target: ChildFetchable

  func fetchChild<Target>(key: UUID, foreignKey: KeyPath<Target, UUID>) -> Target? where Target: ChildFetchable
  func fetchChildren<Target>(foreignKey: KeyPath<Target,UUID>) -> [Target] where Target: ChildFetchable

  func countChildren<Target>(foreignKey: KeyPath<Target,UUID>) -> Int where Target: ChildFetchable

}

extension ChildFetcher {

  func firstChild<Target>(foreignKey: KeyPath<Target,UUID>) -> Target? where Target: ChildFetchable {
    let table = BasementDriver.database.table(Target.self)
    let order = Target.sortDescending
      ? table.order(descending: Target.sortingKey)
      : table.order(by: Target.sortingKey)

    return try? order
      .where(foreignKey == self.id)
      .first()
  }

  func fetchChildren<Target>(foreignKey: KeyPath<Target,UUID>) -> [Target] where Target: ChildFetchable {
    let table = BasementDriver.database.table(Target.self)
    let order = Target.sortDescending
      ? table.order(descending: Target.sortingKey)
      : table.order(by: Target.sortingKey)

    return try! order
      .where(foreignKey == self.id)
      .select()
      .map { $0 }
  }

  func fetchChild<Target>(key: UUID, foreignKey: KeyPath<Target, UUID>) -> Target? where Target: ChildFetchable {
    try? BasementDriver.database.table(Target.self)
      .where(\Target.id == key && foreignKey == self.id)
      .first()
  }

  func countChildren<Target>(foreignKey: KeyPath<Target,UUID>) -> Int where Target: ChildFetchable {
    try! BasementDriver.database.table(Target.self)
      .where(foreignKey == self.id)
      .count()
  }

}

// MARK: ParentFetcher

protocol ParentFetcher {

  func fetchParent<Target>(key: UUID) -> Target where Target: Addressable

}

extension ParentFetcher {

  func fetchParent<Target>(key: UUID) -> Target where Target: Addressable {
    Target.fetch(key: key)
  }

}

// MARK: Addressable entities

protocol Addressable: Insertable {

  var id: UUID { get }

  static func search(key: UUID) -> Self?
  static func fetch(key: UUID) -> Self

}

extension Addressable {

  static func search(key: UUID) -> Self? {
    try? BasementDriver.database.table(Self.self)
      .where(\Self.id == key)
      .first()
  }

  static func fetch(key: UUID) -> Self {
    Self.search(key: key)!
  }

}

// MARK: Insertable entities

protocol Insertable: Codable {

  func insert() throws -> Self

}

extension Insertable {

  func insert() throws -> Self {
    try BasementDriver.database.table(Self.self).insert(self)

    return self
  }

}

// MARK: Deletable entities

protocol Deletable: Addressable {

  func delete() throws

}

extension Deletable {

  func delete() throws {
    try BasementDriver.database.table(Self.self).where(\Self.id == self.id).delete()
  }

}
