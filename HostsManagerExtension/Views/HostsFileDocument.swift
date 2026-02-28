//
//  HostsFileDocument.swift
//  Hosts Manager
//
//  Created on February 9, 2026.
//

import SwiftUI
import UniformTypeIdentifiers

// MARK: - Document Type

struct HostsFileDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.plainText] }

    var content: String

    init(content: String) {
        self.content = content
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        content = string
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(content.utf8)
        return .init(regularFileWithContents: data)
    }
}
