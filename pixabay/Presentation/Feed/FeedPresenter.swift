//
//  FeedPresenter.swift
//  pixabay
//
//  Created by Zhdanov Konstantin on 29.03.2025.
//

import Foundation

protocol FeedPresenterProtocol {
    func searchButtonTapped(query: String)
    func loadMoreNormalImages(query: String, page: Int)
    func loadMoreGraffitiImages(query: String, page: Int)
}

class FeedPresenter: FeedPresenterProtocol {
    weak var view: FeedVCProtocol?
    private let pixabayService: ApiServiceProtocol
    private var normalImages = [PixabayImage]()
    private var graffitiImages = [PixabayImage]()
    private var currentPage = 1
    private var hasMoreNormalImages = true
    private var hasMoreGraffitiImages = true
    private let pageSize = 10
    
    init(pixabayService: ApiServiceProtocol) {
        self.pixabayService = pixabayService
    }
    
    func searchButtonTapped(query: String) {
        guard !query.isEmpty else {
            view?.displayError(NSError(domain: "EmptyQuery", code: 1, userInfo: [NSLocalizedDescriptionKey: "Введите запрос для поиска"]))
            return
        }
        
        normalImages.removeAll()
        graffitiImages.removeAll()
        currentPage = 1
        hasMoreNormalImages = true
        hasMoreGraffitiImages = true
        
        loadMoreNormalImages(query: query, page: currentPage)
        loadMoreGraffitiImages(query: query, page: currentPage)
    }
    
    func loadMoreNormalImages(query: String, page: Int) {
        guard hasMoreNormalImages else { return }
        
        pixabayService.searchImages(query: query, page: page, perPage: pageSize) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let images):
                self.normalImages.append(contentsOf: images)
                print("Найдено изображений: \(images.count)")
                if images.count < pageSize {
                    self.hasMoreNormalImages = false
                }
                DispatchQueue.main.async {
                    self.view?.updateNormalImages(self.normalImages)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.view?.displayError(error)
                }
            }
        }
    }
    
    func loadMoreGraffitiImages(query: String, page: Int) {
        guard hasMoreGraffitiImages else { return }
        
        let graffitiQuery = query + " graffiti"
        pixabayService.searchImages(query: graffitiQuery, page: page, perPage: pageSize) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let images):
                self.graffitiImages.append(contentsOf: images)
                print("Найдено изображений graffiti: \(images.count)")
                if images.count < pageSize {
                    self.hasMoreGraffitiImages = false
                }
                DispatchQueue.main.async {
                    self.view?.updateGraffitiImages(self.graffitiImages)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.view?.displayError(error)
                }
            }
        }
    }
}
