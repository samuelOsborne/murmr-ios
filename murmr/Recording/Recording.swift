//
//  record.swift
//  murmr
//
//  Created by Sam on 02/01/2024.
//

import Foundation

struct Recording: Equatable {
    var id: UUID
    let fileURL: URL
    let createdAt: Date
    var isPlaying: Bool
    let name: String
}
