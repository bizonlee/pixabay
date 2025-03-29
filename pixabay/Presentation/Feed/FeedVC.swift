import UIKit
import SDWebImage

protocol FeedVCProtocol: AnyObject {
    func updateImages(normalImages: [PixabayImage], graffitiImages: [PixabayImage])
    func displayError(_ error: Error)
}

import UIKit
import SDWebImage

class FeedVC: UIViewController, FeedVCProtocol {
    private let pixabayService = ApiService()
    private var normalImages = [PixabayImage]()
    private var graffitiImages = [PixabayImage]()
    private let presenter = FeedPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Pixabay"
        view.backgroundColor = .white
        presenter.view = self
        setupViews()
        setupConstraints()
    }
    
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
    }
    
    @objc private func searchButtonTapped() {
        guard let query = searchTextField.text else { return }
        presenter.searchButtonTapped(query: query)
    }
    
    func updateImages(normalImages: [PixabayImage], graffitiImages: [PixabayImage]) {
        self.normalImages = normalImages
        self.graffitiImages = graffitiImages
        let minCount = min(normalImages.count, graffitiImages.count)
        tableView.reloadData()
    }
    
    func displayError(_ error: Error) {
        print(error.localizedDescription)
    }
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
}

extension FeedVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedOriginalImage = normalImages[indexPath.row]
        let selectedGraffitiImage = graffitiImages[indexPath.row]
        
        let detailVC = ImageViewerVC(selectedOriginalImage: selectedOriginalImage, selectedGraffitiImage: selectedGraffitiImage)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
