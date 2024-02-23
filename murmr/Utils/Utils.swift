//
//  Utils.swift
//  murmr
//
//  Created by Sam on 17/02/2024.
//

import Foundation

class Utils {
    static func getFile(filePath: URL) throws -> Data {
        let data = try Data(contentsOf: filePath)

        return data
    }
    
    static func deleteFile(filePath: URL) throws {
        let fileManager = FileManager.default

        try fileManager.removeItem(atPath: filePath.absoluteString)
    }
    
    static func writeDataToFile(data: Data, filePath: URL) throws {
        do {
            try data.write(to: filePath)
            print("Data successfully written to: \(filePath)")
        } catch {
            throw error
        }
    }
    
    static func writeDataToTmpFile(data: Data, fileName: String) throws {
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            print("Wrote to \(fileURL)")
            try Utils.writeDataToFile(data: data, filePath: fileURL)
        } catch {
            print("Error writing data to file: \(error)")
        }
    }
}
