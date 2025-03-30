import UIKit
import SDWebImage

protocol FeedVCProtocol: AnyObject {
    func updateNormalImages(_ images: [PixabayImage])
    func updateGraffitiImages(_ images: [PixabayImage])
    func displayError(_ error: Error)
}

class FeedVC: UIViewController, FeedVCProtocol {
    private let pixabayService: ApiServiceProtocol
    private let presenter: FeedPresenter
    private var normalImages = [PixabayImage]()
    private var graffitiImages = [PixabayImage]()
    private var currentPage = 1
    private let pageSize = 10
    private var isLoading = false
    private var isPullToRefresh = false
    private var hasMoreNormalImages = true
    private var hasMoreGraffitiImages = true
    private var query = ""
    
    private lazy var searchLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.text = "Search for images"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
        title = "Pixabay"
        view.backgroundColor = .white
        presenter.view = self
        setupViews()
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            searchLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            searchLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            searchTextField.topAnchor.constraint(equalTo: searchLabel.bottomAnchor, constant: 10),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            searchButton.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 10),
            searchButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.topAnchor.constraint(equalTo: searchButton.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupViews() {
        view.addSubview(searchLabel)
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
        hasMoreNormalImages = true
        hasMoreGraffitiImages = true
        presenter.searchButtonTapped(query: query)
        showLoadingIndicator()
        print("Инициирован поиск с запросом: \(query)")
    }
    
    @objc private func refreshFiles(_ sender: Any) {
        isPullToRefresh = true
        currentPage = 1
        hasMoreNormalImages = true
        hasMoreGraffitiImages = true
        presenter.searchButtonTapped(query: query)
    }
    
    func updateNormalImages(_ images: [PixabayImage]) {
        normalImages = images
        if isPullToRefresh {
            graffitiImages.removeAll()
        }
        tableView.reloadData()
        refreshControl.endRefreshing()
        hideLoadingIndicator()
        isLoading = false
        print("Обновление нормальных изображений с \(images.count) элементами")
    }
    
    func updateGraffitiImages(_ images: [PixabayImage]) {
        graffitiImages = images
        tableView.reloadData()
        refreshControl.endRefreshing()
        hideLoadingIndicator()
        isLoading = false
        print("Обновление изображений с graffiti с \(images.count) элементами")
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
        return min(normalImages.count, graffitiImages.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImagesCell", for: indexPath) as! ImagesCell
        
        if indexPath.row < normalImages.count {
            let normalImage = normalImages[indexPath.row]
            cell.previewImageView.sd_setImage(with: URL(string: normalImage.previewURL), placeholderImage: UIImage(named: "placeholder"))
            cell.tagsImageLabel.text = getTags(tags: normalImage.tags)
        } else {
            cell.previewImageView.image = nil
            cell.tagsImageLabel.text = nil
        }
        
        if indexPath.row < graffitiImages.count {
            let graffitiImage = graffitiImages[indexPath.row]
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
        if indexPath.row == totalRows - 1 && hasMoreNormalImages && hasMoreGraffitiImages && !isLoading {
            isLoading = true
            currentPage += 1
            presenter.loadMoreNormalImages(query: query, page: currentPage)
            presenter.loadMoreGraffitiImages(query: query, page: currentPage)
        }
    }
}
