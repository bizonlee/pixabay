//
//  DIContainer.swift
//  pixabay
//
//  Created by Zhdanov Konstantin on 26.03.2025.
//

import Foundation

enum DIContainer {
    static let sharedApiService: ApiServiceProtocol = ApiService()
    
    static func createApiService() -> ApiServiceProtocol {
        sharedApiService
    }
    
    static func createFeedPresenter() -> FeedPresenter {
        FeedPresenter(pixabayService: createApiService())
    }
    
    static func createFeedVC() -> FeedVC {
        let feedVC = FeedVC(pixabayService: createApiService())
        feedVC.presenter = createFeedPresenter()
        return feedVC
    }
}
