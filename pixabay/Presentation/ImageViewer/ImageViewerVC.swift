//
//  ImageViewerVC.swift
//  pixabay
//
//  Created by Zhdanov Konstantin on 28.03.2025.
//

import UIKit
import SDWebImage

class ImageViewerVC: UIViewController {
    
    var selectedOriginalImage: PixabayImage
    var selectedGraffitiImage: PixabayImage
    
    private var scrollView: UIScrollView!
    private var imageView1: UIImageView!
    private var imageView2: UIImageView!
    
    init(selectedOriginalImage: PixabayImage, selectedGraffitiImage: PixabayImage) {
        self.selectedOriginalImage = selectedOriginalImage
        self.selectedGraffitiImage = selectedGraffitiImage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupScrollView()
        setupImageViews()
        loadImages()
    }
    
    private func setupScrollView() {
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentSize = CGSize(width: view.bounds.width * 2, height: view.bounds.height)
        view.addSubview(scrollView)
    }
    
    private func setupImageViews() {
        imageView1 = UIImageView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
        imageView1.contentMode = .scaleAspectFit
        imageView1.clipsToBounds = true
        scrollView.addSubview(imageView1)
        
        imageView2 = UIImageView(frame: CGRect(x: view.bounds.width, y: 0, width: view.bounds.width, height: view.bounds.height))
        imageView2.contentMode = .scaleAspectFit
        imageView2.clipsToBounds = true
        scrollView.addSubview(imageView2)
    }
    
    private func loadImages() {
        imageView1.sd_setImage(with: URL(string: selectedOriginalImage.largeImageURL), placeholderImage: UIImage(named: "placeholder"))
        imageView2.sd_setImage(with: URL(string: selectedGraffitiImage.largeImageURL), placeholderImage: UIImage(named: "placeholder"))
        
        title = "Original Image"
    }
}

extension ImageViewerVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.bounds.width
        let page = Int(round(scrollView.contentOffset.x / pageWidth))
        title = page == 0 ? "Original Image" : "Graffiti Image"
    }
}

struct SelectedImage {
    var imageUrl: String
}
