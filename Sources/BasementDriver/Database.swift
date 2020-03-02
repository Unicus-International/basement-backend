import PerfectCRUD

extension BasementDriver {

  static func initializeDatabaseTables() throws {
    #if DEBUG
    let policy = TableCreatePolicy([.dropTable, .shallow])
    #else
    let policy = TableCreatePolicy([.shallow])
    #endif

    // MARK: User stuff
    try database.create(User.self,     policy: policy)
    try database.table(User.self).index(unique: true, \.username)

    // MARK: Card stuff
    try database.create(Card.self, policy: policy)
  }

  #if DEBUG
  static func insertDebugData() throws {
    let user = try User.newUser(username: "Wheel", password: "iebin", emailAddress: "wheel@basementub.com")!
  }
  #endif

}
