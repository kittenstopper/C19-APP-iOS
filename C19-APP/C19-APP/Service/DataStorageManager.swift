import Foundation
import SQLCipher
import os


class DataStorageManager {
    
    let dbFileName: String = "GeohashDB.sqlite"
    
    var db: OpaquePointer?
    
    static var shared: DataStorageManager = {
        DataStorageManager()
    }()
    
    private init() {
        openDatabase()
    }
    
    
    private func destroyDatabase() {}
    
    
    func openDatabase() {
        if let _ = self.db {
            return
        } else {
            let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(dbFileName)
            var db: OpaquePointer? = nil
            if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
                os_log("Couldn't open database")
            } else {
                os_log("Successfully opened connection to database at %s", dbFileName)
                self.db = db
            }
        }
    }
    
    
    
    func createTable() throws {
        let createTableString = "CREATE TABLE IF NOT EXISTS locations(timestamp INTEGER PRIMARY KEY,geohash TEXT);"
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                os_log("locations table created.")
            } else {
                os_log("locations table could not be created.")
            }
        } else {
            os_log("CREATE TABLE statement could not be prepared.")
        }
        sqlite3_finalize(createTableStatement)
    }
    
    
    
    func insert(timestamp:Int, geohash:String)
    {
        let insertStatementString = "INSERT INTO locations (timestamp, geohash) VALUES (?, ?);"
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(insertStatement, 1, Int32(timestamp))
            sqlite3_bind_text(insertStatement, 2, (geohash as NSString).utf8String, -1, nil)
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                os_log("Successfully inserted row.")
            } else {
                os_log("Could not insert row.")
            }
        } else {
            os_log("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    
    
    func read() -> [LocationModel] {
        let queryStatementString = "SELECT * FROM locations;"
        var queryStatement: OpaquePointer? = nil
        var locs : [LocationModel] = []
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let timestamp = sqlite3_column_int(queryStatement, 0)
                let geohash = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                locs.append(LocationModel(from: Int(timestamp), geohash: geohash))
                print("Query Result:")
                print("\(timestamp) | \(geohash)")
            }
        } else {
            os_log("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return locs
    }
    
    
    
    func pruneOldRecords() {
        print(self.read())
    }
    
    
    
    
    /// Returns the string representation of the data for the past two weeks
    func getHistoricalData() -> String {
        return " Historical data "
    }
    
}
