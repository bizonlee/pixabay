//
//  FeedPresenter.swift
//  pixabay
//
//  Created by Zhdanov Konstantin on 29.03.2025.
//

import Foundation

protocol FeedPresenterProtocol {
    func searchButtonTapped(query: String)
}

class FeedPresenter: FeedPresenterProtocol {
    weak var view: FeedVCProtocol?
    private let pixabayService = ApiService()
    private var normalImages = [PixabayImage]()
    private var graffitiImages = [PixabayImage]()
    
    func searchButtonTapped(query: String) {
        guard !query.isEmpty else {
            view?.displayError(NSError(domain: "EmptyQuery", code: 1, userInfo: [NSLocalizedDescriptionKey: "Введите запрос для поиска"]))
            return
        }
        
        let dispatchGroup = DispatchGroup()
        normalImages.removeAll()
        graffitiImages.removeAll()
        
        dispatchGroup.enter()
        pixabayService.searchImages(query: query) { [weak self] result in
            switch result {
            case .success(let images):
                self?.normalImages = images
                print("Найдено изображений: \(images.count)")
            case .failure(let error):
                self?.view?.displayError(error)
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        let graffitiQuery = query + " graffiti"
        pixabayService.searchImages(query: graffitiQuery) { [weak self] result in
            switch result {
            case .success(let images):
                self?.graffitiImages = images
                print("Найдено изображений graffiti: \(images.count)")
            case .failure(let error):
                self?.view?.displayError(error)
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            self.view?.updateImages(normalImages: self.normalImages, graffitiImages: self.graffitiImages)
        }
    }
}
