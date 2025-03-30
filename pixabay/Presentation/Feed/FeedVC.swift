//
//  FeedVC.swift
//  pixabay
//
//  Created by Zhdanov Konstantin on 28.03.2025.
//

import UIKit
import SDWebImage

protocol FeedVCProtocol: AnyObject {
    func updateImages(_ images: [[PixabayImage]])
    func displayError(_ error: Error)
}

class FeedVC: UIViewController, FeedVCProtocol {
    private let pixabayService: ApiServiceProtocol
    private let presenter: FeedPresenter
    private var images = [[PixabayImage]]()
    private var currentPage = 1
    private let pageSize = 10
    private var isLoading = false
    private var isPullToRefresh = false
    private var hasMoreImages = [true, true]
    private var query = ""
    
    private lazy var searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Search..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var searchButton: UIButton = {
        let button = UIButton()
        button.setTitle("Search", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ImagesCell.self, forCellReuseIdentifier: "ImagesCell")
        return tableView
    }()
    
    private let refreshControl = UIRefreshControl()
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    init(pixabayService: ApiServiceProtocol) {
        self.pixabayService = pixabayService
        self.presenter = FeedPresenter(pixabayService: pixabayService)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Pixabay App"
        view.backgroundColor = .white
        presenter.view = self
        setupViews()
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchTextField.trailingAnchor.constraint(equalTo: searchButton.leadingAnchor, constant: -10),
            
            searchButton.topAnchor.constraint(equalTo: searchTextField.topAnchor, constant: 10),
            searchButton.leadingAnchor.constraint(equalTo: searchTextField.trailingAnchor, constant: 10),
            searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            tableView.topAnchor.constraint(equalTo: searchButton.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupViews() {
        view.addSubview(searchTextField)
        view.addSubview(searchButton)
        view.addSubview(tableView)
        refreshControl.addTarget(self, action: #selector(refreshFiles(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
    }

    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
    }

    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        view.isUserInteractionEnabled = true
    }

    @objc private func searchButtonTapped() {
        guard let query = searchTextField.text, !query.isEmpty else {
            print("Введите запрос для поиска")
            return
        }
        self.query = query
        currentPage = 1
        isPullToRefresh = false
        hasMoreImages = [true, true]
        presenter.searchButtonTapped(query: query)
        showLoadingIndicator()
    }

    @objc private func refreshFiles(_ sender: Any) {
        isPullToRefresh = true
        currentPage = 1
        hasMoreImages = [true, true]
        presenter.searchButtonTapped(query: query)
    }

    func updateImages(_ images: [[PixabayImage]]) {
        self.images = images
        if isPullToRefresh {
            self.images[1] = []
        }
        tableView.reloadData()
        refreshControl.endRefreshing()
        hideLoadingIndicator()
        isLoading = false
    }

    func displayError(_ error: Error) {
        let alertController = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
        refreshControl.endRefreshing()
        hideLoadingIndicator()
        isLoading = false
        print("Ошибка: \(error.localizedDescription)")
    }
}

extension FeedVC: UITableViewDelegate {
}

extension FeedVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard images.count > 1 else {
            return 0
        }
        return min(images[0].count, images[1].count)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImagesCell", for: indexPath) as! ImagesCell

        if indexPath.row < images[0].count {
            let normalImage = images[0][indexPath.row]
            cell.previewImageView.sd_setImage(with: URL(string: normalImage.previewURL), placeholderImage: UIImage(named: "placeholder"))
            cell.tagsImageLabel.text = getTags(tags: normalImage.tags)
        } else {
            cell.previewImageView.image = nil
            cell.tagsImageLabel.text = nil
        }

        if indexPath.row < images[1].count {
            let graffitiImage = images[1][indexPath.row]
            cell.previewImageViewSecond.sd_setImage(with: URL(string: graffitiImage.previewURL), placeholderImage: UIImage(named: "placeholder"))
            cell.tagsImageLabelSecond.text = getTags(tags: graffitiImage.tags)
        } else {
            cell.previewImageViewSecond.image = nil
            cell.tagsImageLabelSecond.text = nil
        }

        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let totalRows = tableView.numberOfRows(inSection: 0)
        if indexPath.row == totalRows - 1 && hasMoreImages[0] && hasMoreImages[1] && !isLoading {
            isLoading = true
            currentPage += 1
            presenter.loadMoreImages(query: query, page: currentPage, type: 0)
            presenter.loadMoreImages(query: query, page: currentPage, type: 1)
        }
    }
}
