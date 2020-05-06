import XCTest
@testable import C19_APP

class DBHelperTests: XCTestCase {

    
    override func setUpWithError() throws {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("GeohashDB.sqlite")
        let filePath = fileURL.path
        do {
            if FileManager.default.fileExists(atPath: filePath) {
               try FileManager.default.removeItem(atPath: filePath)
            } else {
               print("File does not exist")
            }
        } catch let error as NSError {
            print("An error took place: \(error)")
        }
    }
        

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCreateEmptyTable() throws {
        DBHelper.shared.createTable()
        let result = DBHelper.shared.read()
        XCTAssert(result.isEmpty)
    }
    
    
    func testInsertReadOrdered() {
        DBHelper.shared.createTable()
        let lm1 = LocationModel(from: 12345345353255, geohash: "aretg344ewer")
        let lm2 = LocationModel(from: 35453253245352, geohash: "csdgfsergrth")
        let lm3 = LocationModel(from: 23425324534553, geohash: "bgsdghsdgfds")
        
        DBHelper.shared.insert(location: lm1)
        DBHelper.shared.insert(location: lm2)
        DBHelper.shared.insert(location: lm3)
        
        let result = DBHelper.shared.read()
        XCTAssertEqual(result, [lm1, lm3, lm2])
    }
    
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
