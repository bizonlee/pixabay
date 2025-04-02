//
//  ImageViewerVC.swift
//  pixabay
//
//  Created by Zhdanov Konstantin on 28.03.2025.
//

import UIKit
import SDWebImage

class ImageViewerVC: UIViewController {
    var selectedImage: [PixabayImage]
    private var imageView: UIImageView!
    private var currentIndex = 0
    private var loadingImageView: UIImageView!
    
    init(selectedImage: [PixabayImage]) {
        self.selectedImage = selectedImage
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        setupImageView()
        setupLoadingImageView()
        setupGestures()
        loadImages()
    }
    
    private func setupImageView() {
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupLoadingImageView() {
        loadingImageView = UIImageView(image: UIImage(named: "loading_indicator"))
        loadingImageView.contentMode = .scaleAspectFit
        loadingImageView.center = view.center
        loadingImageView.isHidden = true
        view.addSubview(loadingImageView)
    }
    
    private func setupGestures() {
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        leftSwipeGesture.direction = .left
        view.addGestureRecognizer(leftSwipeGesture)
        
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        rightSwipeGesture.direction = .right
        view.addGestureRecognizer(rightSwipeGesture)
    }
    
    private func loadImages() {
        loadingImageView.isHidden = false
        
        imageView.sd_setImage(with: URL(string: selectedImage[0].largeImageURL), placeholderImage: UIImage(named: "imgPlaceholder")) { [weak self] image, error, cacheType, url in
            self?.loadingImageView.isHidden = true
            if let error = error {
                print("Ошибка загрузки оригинального изображения: \(error.localizedDescription)")
            }
        }
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .left:
            if currentIndex == 0 {
                currentIndex = 1
                title = "Graffiti Image"
                loadingImageView.isHidden = false
                imageView.fadeTransition(0.5)
                imageView.sd_setImage(with: URL(string: selectedImage[1].largeImageURL), placeholderImage: UIImage(named: "imgPlaceholder")) { [weak self] image, error, cacheType, url in
                    self?.loadingImageView.isHidden = true
                    if let error = error {
                        print("Ошибка загрузки граффити изображения: \(error.localizedDescription)")
                    }
                }
            }
        case .right:
            if currentIndex == 1 {
                currentIndex = 0
                title = "Original Image"
                loadingImageView.isHidden = false
                imageView.fadeTransition(0.5)
                imageView.sd_setImage(with: URL(string: selectedImage[0].largeImageURL), placeholderImage: UIImage(named: "imgPlaceholder")) { [weak self] image, error, cacheType, url in
                    self?.loadingImageView.isHidden = true
                    if let error = error {
                        print("Ошибка загрузки оригинального изображения: \(error.localizedDescription)")
                    }
                }
            }
        default:
            break
        }
    }
}

extension UIImageView {
    func fadeTransition(_ duration: CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.fade
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.fade.rawValue)
    }
}
