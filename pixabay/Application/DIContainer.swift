//
//  DIContainer.swift
//  pixabay
//
//  Created by Zhdanov Konstantin on 26.03.2025.
//

import Foundation

enum DIContainer {
    static let sharedApiService = ApiService()
//
//    static func createOnboardingService() -> OnboardingServiceProtocol {
//        OnboardingService()
//    }
//
//    static func createFileService() -> FileServiceProtocol {
//        return FileService(apiService: sharedApiService)
 //   }
    
    static func createApiService() -> ApiServiceProtocol {
        sharedApiService
    }
    
//    static func createProfileService() -> ProfileService {
//        return ProfileService(apiService: sharedApiService)
//    }
}
