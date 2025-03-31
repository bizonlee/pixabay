//
//  FeedPresenter.swift
//  pixabay
//
//  Created by Zhdanov Konstantin on 29.03.2025.
//

import Foundation

protocol FeedPresenterProtocol {
    func searchButtonTapped(query: String)
    func loadMoreImages(query: String, page: Int, type: Int)
}

class FeedPresenter: FeedPresenterProtocol {
    weak var view: FeedVCProtocol?
    private let apiService: ApiServiceProtocol
    private var images = [[PixabayImage]]()
    private var currentPage = 1
    private var hasMoreImages = [true, true]
    private let pageSize = 10

    init(pixabayService: ApiServiceProtocol) {
        self.apiService = pixabayService
    }

    func searchButtonTapped(query: String) {
        guard !query.isEmpty else {
            view?.displayError(NSError(domain: "EmptyQuery", code: 1, userInfo: [NSLocalizedDescriptionKey: "Введите запрос для поиска"]))
            return
        }
        images = [[], []]
        currentPage = 1
        hasMoreImages = [true, true]
        loadMoreImages(query: query, page: currentPage, type: 0)
        loadMoreImages(query: query, page: currentPage, type: 1)
    }

    func loadMoreImages(query: String, page: Int, type: Int) {
        guard hasMoreImages[type] else { return }
        let finalQuery = type == 1 ? query + " graffiti" : query
        apiService.searchImages(query: finalQuery, page: page, perPage: pageSize) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let images):
                self.images[type].append(contentsOf: images)
                print("Найдено изображений \(type == 1 ? "graffiti" : ""): \(images.count)")
                if images.count < pageSize {
                    self.hasMoreImages[type] = false
                }
                DispatchQueue.main.async {
                    self.view?.updateImages(self.images)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.view?.displayError(error)
                }
            }
        }
    }
}
