//
//  ImagesCell.swift
//  pixabay
//
//  Created by Zhdanov Konstantin on 25.03.2025.
//

import UIKit

class ImagesCell: UITableViewCell {
        
    lazy var imagesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var tagsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var previewImageViewSecond: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var tagsImageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .red
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var tagsImageLabelSecond: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .red
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupConstraints()
    }
    
    
    private func setupViews() {
        imagesStackView.addArrangedSubview(previewImageView)
        imagesStackView.addArrangedSubview(previewImageViewSecond)
        
        tagsStackView.addArrangedSubview(tagsImageLabel)
        tagsStackView.addArrangedSubview(tagsImageLabelSecond)
        
        contentView.addSubview(imagesStackView)
        contentView.addSubview(tagsStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imagesStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            imagesStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            imagesStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            imagesStackView.heightAnchor.constraint(equalToConstant: 100),
            
            tagsStackView.topAnchor.constraint(equalTo: imagesStackView.bottomAnchor, constant: 10),
            tagsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            tagsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            tagsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
}
