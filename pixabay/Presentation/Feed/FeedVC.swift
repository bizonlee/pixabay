//
//  FeedVC.swift
//  pixabay
//
//  Created by Zhdanov Konstantin on 28.03.2025.
//

import SDWebImage
import UIKit

protocol FeedVCProtocol: AnyObject {
    func updateImages(_ images: [[PixabayImage]])
    func displayError(_ error: Error)
    func showNoResultsMessage()
    func hideNoResultsMessage()
}

class FeedVC: UIViewController, FeedVCProtocol {
    private let pixabayService: ApiServiceProtocol
    public  var presenter: FeedPresenter
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

        textField.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        textField.textColor = .white

        let placeholderColor = UIColor(white: 0.5, alpha: 1.0)
        textField.attributedPlaceholder = NSAttributedString(string: "Search...",
                                                             attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])

        textField.layer.cornerRadius = 8.0
        textField.layer.masksToBounds = true

        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor(white: 0.3, alpha: 1.0).cgColor

        let searchIcon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        searchIcon.tintColor = placeholderColor
        searchIcon.contentMode = .scaleAspectFit

        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
        searchIcon.frame = CGRect(x: 8, y: 0, width: 20, height: 20)
        paddingView.addSubview(searchIcon)

        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.heightAnchor.constraint(equalToConstant: 30).isActive = true

        return textField
    }()
    
    private lazy var searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Search", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.2, green: 0.4, blue: 1.0, alpha: 1.0)
        button.layer.cornerRadius = 8.0
        button.layer.masksToBounds = true
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
        tableView.backgroundColor = .black
        tableView.separatorColor = .clear
        tableView.layer.cornerRadius = 8.0
        return tableView
    }()
    
    private lazy var noResultsLabel: UILabel = {
        let label = UILabel()
        label.text = "Нет результатов"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
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
        view.backgroundColor = .black
        presenter.view = self
        setupViews()
        setupConstraints()
        hideNoResultsMessage()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100),
            
            searchButton.topAnchor.constraint(equalTo: searchTextField.topAnchor),
            searchButton.leadingAnchor.constraint(equalTo: searchTextField.trailingAnchor, constant: 10),
            searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            searchButton.bottomAnchor.constraint(equalTo: searchTextField.bottomAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchButton.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            noResultsLabel.topAnchor.constraint(equalTo: tableView.topAnchor),
            noResultsLabel.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            noResultsLabel.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
            noResultsLabel.bottomAnchor.constraint(equalTo: tableView.bottomAnchor),
            noResultsLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            noResultsLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
        ])
    }
    
    private func setupViews() {
        view.addSubview(searchTextField)
        view.addSubview(searchButton)
        view.addSubview(tableView)
        view.addSubview(noResultsLabel)
        
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
    
    @objc
    private func searchButtonTapped() {
        guard let query = searchTextField.text, !query.isEmpty else {
            showNoResultsMessage()
            return
        }
        self.query = query
        currentPage = 1
        isPullToRefresh = false
        hasMoreImages = [true, true]
        presenter.searchButtonTapped(query: query)
        showLoadingIndicator()
    }
    
    @objc
    private func refreshFiles(_ sender: Any) {
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
        
        if images[0].isEmpty && images[1].isEmpty {
            showNoResultsMessage()
        } else {
            hideNoResultsMessage()
        }
    }
    
    func showNoResultsMessage() {
        tableView.isHidden = true
        noResultsLabel.isHidden = false
    }
    
    func hideNoResultsMessage() {
        tableView.isHidden = false
        noResultsLabel.isHidden = true
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row < images[0].count, indexPath.row < images[1].count else {
            print("Индекс вне диапазона")
            return
        }
        let selectedImages = [images[0][indexPath.row], images[1][indexPath.row]]
        let imageViewerVC = ImageViewerVC(selectedImage: selectedImages)
        navigationController?.pushViewController(imageViewerVC, animated: true)
    }
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
            cell.previewImageView.sd_setImage(with: URL(string: normalImage.previewURL), placeholderImage: UIImage(named: "imgPlaceholder"))
            cell.tagsImageLabel.text = getTags(tags: normalImage.tags)
        } else {
            cell.previewImageView.image = nil
            cell.tagsImageLabel.text = nil
        }
        
        if indexPath.row < images[1].count {
            let graffitiImage = images[1][indexPath.row]
            cell.previewImageViewSecond.sd_setImage(with: URL(string: graffitiImage.previewURL), placeholderImage: UIImage(named: "imgPlaceholder"))
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
