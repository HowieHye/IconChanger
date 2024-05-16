//
//  URL+Document.swift
//  IconChanger
//
//  Created by 朱浩宇 on 2022/6/28.
//

import Foundation

extension URL {
    static var documents: URL {
        let path = "\(NSHomeDirectory())/.config/iconchanger/helper"
        let url = URL(universalFilePath: path)
        if !FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            } catch {
                // Handle error appropriately
                fatalError("Unable to create directory: \(error.localizedDescription)")
            }
        }
        return url
    }
}
