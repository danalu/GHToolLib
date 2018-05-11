//
//  FilePersistentTool.swift
//  FBSnapshotTestCase
//
//  Created by DanaLu on 2018/5/10.
//

import UIKit

fileprivate let fileArchiveDirectory = "FileArchiveKey"
fileprivate let fileArchiveErrorDomain = "fileArchiveErrorDomain"
fileprivate let fileArchiveErrorCode = 1011001

public class PersistentTool: NSObject {
    //MARK: userDefault
    public static func userDefault(_ key: String) ->Any? {
        return UserDefaults.standard.value(forKey: key)
    }
    
    public static func updateDefault(_ key: String, value: Any?) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(value, forKey: key)
        userDefaults.synchronize()
    }
    
    //MARK: file
    public static func setArchiveObject(_ object: Any, fileName: String) throws -> Bool {
        let filePath = NSString.init(string: documentDirectory()).appendingPathComponent(fileName)
        do {
            guard (try createFolder(filePath)) else {
                return false
            }
        } catch {
            throw error
        }
        
        let data = NSMutableData()
        let archiver = NSKeyedArchiver.init(forWritingWith: data)
        archiver.encode(object, forKey: fileArchiveDirectory)
        archiver.finishEncoding()

        return data.write(toFile: filePath, atomically: true)
    }
    
    public static func archiveObject(_ fileName: String?) -> Any? {
        guard let file = fileName, !file.isEmpty else {
            return nil
        }
        
        let filePath = NSString.init(string: documentDirectory()).appendingPathComponent(fileName!)
        let data = NSData.init(contentsOfFile: filePath)
        guard let d = data, d.length > 0 else {
            return nil
        }
        
        let unarchiver = NSKeyedUnarchiver.init(forReadingWith: Data.init(referencing: data!))
        let object = unarchiver.decodeObject(forKey: fileArchiveDirectory)
        unarchiver.finishDecoding()
        
        return object
    }
    
    public static func deleteFile(_ fileName: String?) throws {
        guard let file = fileName, !file.isEmpty else {
            throw NSError.init(domain: fileArchiveErrorDomain, code: fileArchiveErrorCode, userInfo: ["filepath": "filePath is Empty!"])
        }
        
        let filePath = NSString.init(string: documentDirectory()).appendingPathComponent(fileName!)
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath, isDirectory: nil) {
            try fileManager.removeItem(atPath: filePath)
        }
    }
    
    //MARK: tool
    public static func createFolder(_ filePath: String?) throws -> Bool {
        guard let path = filePath, !path.isEmpty else {
            throw NSError.init(domain: fileArchiveErrorDomain, code: fileArchiveErrorCode, userInfo: ["filepath": "filePath is Empty!"])
        }
        
        let fileFolder = NSString.init(string: filePath!).deletingLastPathComponent
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: fileFolder) {
            try fileManager.createDirectory(atPath: fileFolder, withIntermediateDirectories: true, attributes: nil)
        }
        
        return true
    }
    
    fileprivate static func documentDirectory() ->String {
        let directories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if directories.count > 0 {
            let documentDirecotory = directories[0]
            return documentDirecotory
        }
        
        return ""
    }
}
