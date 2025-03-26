//
//  ImagesCell.swift
//  pixabay
//
//  Created by Zhdanov Konstantin on 25.03.2025.
//

//import UIKit
//
//class ImagesCell: UITableViewCell {
//    
//    // MARK: - UI Elements
//    
//    lazy var previewImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFit
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        return imageView
//    }()
//    
//    lazy var previewImageViewGraffiti: UIImageView = {
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFit
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        return imageView
//    }()
//    
//    lazy var tagsImageLabel: UILabel = {
//        let label = UILabel()
//        label.textAlignment = .left
//        label.numberOfLines = 0
//        label.textColor = .red
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    lazy var tagsImageLabelGraffiti: UILabel = {
//        let label = UILabel()
//        label.textAlignment = .left
//        label.numberOfLines = 0
//        label.textColor = .red
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        setupViews()
//        setupConstraints()
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupViews()
//        setupConstraints()
//    }
//    
//    
//    private func setupViews() {
//        contentView.addSubview(previewImageView)
//        contentView.addSubview(previewImageViewGraffiti)
//        contentView.addSubview(tagsImageLabel)
//        contentView.addSubview(tagsImageLabelGraffiti)
//    }
//    
//    private func setupConstraints() {
//        NSLayoutConstraint.activate([
//            // Preview Image
//            previewImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
//            previewImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
//            previewImageView.widthAnchor.constraint(equalToConstant: 100),
//            previewImageView.heightAnchor.constraint(equalToConstant: 100),
//            
//            // Tags Label
//            tagsImageLabel.topAnchor.constraint(equalTo: previewImageView.bottomAnchor, constant: 10),
//            tagsImageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
//            tagsImageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
//            
//            // Graffiti Image
//            previewImageViewGraffiti.topAnchor.constraint(equalTo: tagsImageLabel.bottomAnchor, constant: 10),
//            previewImageViewGraffiti.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
//            previewImageViewGraffiti.widthAnchor.constraint(equalToConstant: 100),
//            previewImageViewGraffiti.heightAnchor.constraint(equalToConstant: 100),
//            
//            // Graffiti Tags Label
//            tagsImageLabelGraffiti.topAnchor.constraint(equalTo: previewImageViewGraffiti.bottomAnchor, constant: 10),
//            tagsImageLabelGraffiti.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
//            tagsImageLabelGraffiti.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
//            tagsImageLabelGraffiti.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
//        ])
//    }
//}


import UIKit

class ImagesCell: UITableViewCell {
    
    // MARK: - UI Elements
    
    // Stack view для размещения двух изображений в первой строке
    lazy var imagesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // Stack view для размещения двух подписей под изображениями
    lazy var tagsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // Первое изображение
    lazy var previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // Второе изображение
    lazy var previewImageViewSecond: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // Первый лейбл для тегов
    lazy var tagsImageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .red
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Второй лейбл для тегов
    lazy var tagsImageLabelSecond: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .red
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initializer
    
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
    
    // MARK: - Setup Views and Constraints
    
    private func setupViews() {
        // Добавляем в стэквью изображения
        imagesStackView.addArrangedSubview(previewImageView)
        imagesStackView.addArrangedSubview(previewImageViewSecond)
        
        // Добавляем в стэквью теги
        tagsStackView.addArrangedSubview(tagsImageLabel)
        tagsStackView.addArrangedSubview(tagsImageLabelSecond)
        
        contentView.addSubview(imagesStackView)
        contentView.addSubview(tagsStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Стек для изображений
            imagesStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            imagesStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            imagesStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            imagesStackView.heightAnchor.constraint(equalToConstant: 100),
            
            // Стек для тегов
            tagsStackView.topAnchor.constraint(equalTo: imagesStackView.bottomAnchor, constant: 10),
            tagsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            tagsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            tagsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
}
