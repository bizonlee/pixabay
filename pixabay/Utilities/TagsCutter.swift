//
//  Untitled.swift
//  pixabay
//
//  Created by Zhdanov Konstantin on 28.03.2025.
//

import Foundation

func getTags(tags: String, count: Int = 3) -> String {
    let tagArray = tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    let firstTags = tagArray.prefix(count)
    return firstTags.joined(separator: ", ")
}
