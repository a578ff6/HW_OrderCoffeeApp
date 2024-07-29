//
//  ColumnItemCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/6/28.
//


import UIKit
import Kingfisher

/// 列布局的 Cell（預設）
class ColumnItemCell: UICollectionViewCell {
    static let reuseIdentifier = "ColumnItemCell"
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderWidth = 2
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor(red: 39/255, green: 37/255, blue: 31/255, alpha: 1).cgColor
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.white
        label.numberOfLines = 1
        return label
    }()
    
    let subtitleNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellAppearance()
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCellAppearance() {
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor(red: 39/255, green: 37/255, blue: 31/255, alpha: 1).cgColor
        
        // 設置 contentView 背景颜色
        self.contentView.backgroundColor = UIColor(red: 39/255, green: 37/255, blue: 31/255, alpha: 0.75)
    }
    
    private func setupViews() {
         contentView.addSubview(imageView)
         contentView.addSubview(stackView)
         
         stackView.addArrangedSubview(titleLabel)
         stackView.addArrangedSubview(subtitleNameLabel)
         
         NSLayoutConstraint.activate([
             // 垂直置中圖片
             imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
             imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
             imageView.widthAnchor.constraint(equalToConstant: 70),
             imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
             
             // 讓 stackView 中心與圖片的中心對齊
             stackView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
             stackView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 20),
             stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
             stackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10)
         ])
     }
    
    func configure(with drink: Drink) {
        imageView.kf.setImage(with: drink.imageUrl, placeholder: UIImage(named: "starbucksLogo"))
        titleLabel.text = drink.name
        subtitleNameLabel.text = drink.subName
    }
}

