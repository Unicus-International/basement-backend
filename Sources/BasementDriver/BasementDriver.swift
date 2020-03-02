public enum BasementDriver {

  public static func run() throws {
    try initializeDatabase()

    try runServer()
  }

}
