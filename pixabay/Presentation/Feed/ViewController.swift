import UIKit
import SDWebImage

class ViewController: UIViewController {
    
    private let pixabayService = ApiService()
    private var images = [PixabayImage]()
    private var normalImages = [PixabayImage]()
    private var graffitiImages = [PixabayImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Pixabay"
        view.backgroundColor = .white
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
            guard let query = searchTextField.text, !query.isEmpty else {
                print("Введите запрос для поиска")
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
                    print("Ошибка при поиске: \(error)")
                }
                dispatchGroup.leave()
            }
            
            dispatchGroup.enter()
            let graffitiQuery =  query + " graffiti"
            pixabayService.searchImages(query: graffitiQuery) { [weak self] result in
                switch result {
                case .success(let images):
                    self?.graffitiImages = images
                    print("Найдено изображений graffiti: \(images.count)")
                case .failure(let error):
                    print("Ошибка при поиске graffiti: \(error)")
                }
                dispatchGroup.leave()
            }
            
            dispatchGroup.notify(queue: .main) {
                let minCount = min(self.normalImages.count, self.graffitiImages.count)
                self.images = Array(self.normalImages.prefix(minCount)) + Array(self.graffitiImages.prefix(minCount))
                
                self.tableView.reloadData()
            }
        }
}

extension ViewController: UITableViewDelegate {
    
}




extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImagesCell", for: indexPath) as! ImagesCell
        
        let normalImageIndex = indexPath.row
        let graffitiImageIndex = indexPath.row
        
        if normalImageIndex < normalImages.count {
            let normalImage = normalImages[normalImageIndex]
            cell.previewImageView.sd_setImage(with: URL(string: normalImage.previewURL), placeholderImage: UIImage(named: "placeholder"))
            cell.tagsImageLabel.text = normalImage.tags
        } else {
            cell.previewImageView.image = nil
            cell.tagsImageLabel.text = nil
        }
        
        if graffitiImageIndex < graffitiImages.count {
            let graffitiImage = graffitiImages[graffitiImageIndex]
            cell.previewImageViewSecond.sd_setImage(with: URL(string: graffitiImage.previewURL), placeholderImage: UIImage(named: "placeholder"))
            cell.tagsImageLabelSecond.text = graffitiImage.tags
        } else {
            cell.previewImageViewSecond.image = nil
            cell.tagsImageLabelSecond.text = nil
        }
        
        return cell
    }
}
