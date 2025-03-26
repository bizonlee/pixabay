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
//    let pageURL: String
//    let type: String
    let tags: String
    let previewURL: String
//    let previewWidth: Int
//    let previewHeight: Int
//    let webformatURL: String
//    let webformatWidth: Int
//    let webformatHeight: Int
    let largeImageURL: String

}
