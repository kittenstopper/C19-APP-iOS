import Foundation
import SQLCipher
import os


class DBHelper {
    
    let dbFileName: String = "GeohashDB.sqlite"
    
    var db: OpaquePointer?
    
    static var shared: DBHelper = {
        DBHelper()
    }()
    
    private init() {
        openDatabase()
    }
    
    
    public func destroyDatabase() {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("GeohashDB.sqlite")
        let filePath = fileURL.path
        do {
            if FileManager.default.fileExists(atPath: filePath) {
               try FileManager.default.removeItem(atPath: filePath)
               os_log("Old database has been destroyed")
            } else {
               print("File does not exist")
            }
        } catch let error as NSError {
            os_log("An error took place: %s", error)
        }
        self.db = nil
        setupNewDatabase()
    }
    
    
    private func setupNewDatabase() {
        self.openDatabase()
        self.createTable()
    }
    
    
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
    
    
    
    func createTable() {
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


    func insert(location: LocationModel) {
        insert(timestamp: location.timestamp, geohash: location.hashString)
    }
    
    
    func insert(timestamp:Int, geohash:String)
    {
        let insertStatementString = "INSERT INTO locations (timestamp, geohash) VALUES (?, ?);"
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_int64(insertStatement, 1, Int64(timestamp))
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
        let queryStatementString = "SELECT * FROM locations ORDER BY timestamp;"
        var queryStatement: OpaquePointer? = nil
        var locs : [LocationModel] = []
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let timestamp = sqlite3_column_int64(queryStatement, 0)
                let geohash = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                locs.append(LocationModel(from: Int(timestamp), geohash: geohash))
            }
        } else {
            os_log("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return locs
    }
    


    func deleteRowBy(timestamp:Int) {
        let deleteStatementStirng = "DELETE FROM locations WHERE timestamp = ?;"
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            sqlite3_bind_int64(deleteStatement, 1, Int64(timestamp))
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                os_log("Successfully deleted a row.")
            } else {
                os_log("Could not delete a row.")
            }
        } else {
            os_log("DELETE statement could not be prepared")
        }
        sqlite3_finalize(deleteStatement)
    }

    
    
    func pruneOldRecords() {
        
        let allRows: [LocationModel] = self.read()
        let twoWeeksInSeconds: Int = 1209600
        let twoWeeksAgo = Date().addingTimeInterval(Double(-twoWeeksInSeconds))
        for row in allRows {
            if (Date(timeIntervalSinceReferenceDate: Double(row.timestamp)/1000) < twoWeeksAgo) {
                self.deleteRowBy(timestamp: row.timestamp)
                print("Pruned a row")
            }
        }
    }
    
    
    /// Returns the string representation of the data for the past two weeks
    func getHistoricalData() -> String {
        let data = read()
        return data.map { "\($0.timestamp):\($0.hashString)" }.joined(separator: " ")
    }
    
}
