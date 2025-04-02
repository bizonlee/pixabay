//
//  ImageModel.swift
//  pixabay
//
//  Created by Zhdanov Konstantin on 25.03.2025.
//

import Foundation

struct PixabayResponse: Decodable {
    let total: Int
    let totalHits: Int
    let hits: [PixabayImage]
}

struct PixabayImage: Decodable {
    let id: Int
    let tags: String
    let previewURL: String
    let largeImageURL: String

}
