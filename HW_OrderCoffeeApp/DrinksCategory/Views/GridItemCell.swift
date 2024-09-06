//
//  GridItemCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/6/28.
//


import UIKit
import Kingfisher

/// 網格布局的 Cell
class GridItemCell: UICollectionViewCell {
    
    static let reuseIdentifier = "GridItemCell"
    
    // MARK: - UI Elements

    let imageView = createImageView(cornerRadius: 30)
    let titleLabel = createLabel(fontSize: 18, textColor: .deepBrown, alignment: .center, isBold: true)
    let subNameLabel = createLabel(fontSize: 14, textColor: .gray, alignment: .center, numberOfLines: 2, isBold: false)
    let stackView: UIStackView = createStackView(axis: .vertical, spacing: 4)

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellAppearance()
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup Methods

    /// 設置 Cell 外觀
    private func setupCellAppearance() {
        self.layer.cornerRadius = 30
        self.layer.masksToBounds = true
        self.contentView.backgroundColor = .lightWhiteGray           // 設置 contentView 背景顏色
    }
    
    /// 配置 Cell 的視圖佈局
    private func setupViews() {
        contentView.addSubview(imageView)
        contentView.addSubview(stackView)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subNameLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            
            // 修改高度约束，允許高度調整
            imageView.heightAnchor.constraint(lessThanOrEqualTo: imageView.widthAnchor),
            
            stackView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 18),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -18)
        ])
    }
    
    // MARK: - Factory Methods

    private static func createLabel(fontSize: CGFloat, textColor: UIColor, alignment: NSTextAlignment = .left, numberOfLines: Int = 1, isBold: Bool) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = isBold ? UIFont.boldSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize)
        label.textColor = textColor
        label.textAlignment = alignment
        label.numberOfLines = numberOfLines
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }
    
    private static func createImageView(cornerRadius: CGFloat) -> UIImageView {
         let imageView = UIImageView()
         imageView.translatesAutoresizingMaskIntoConstraints = false
         imageView.contentMode = .scaleAspectFit
         imageView.layer.cornerRadius = cornerRadius
         imageView.layer.masksToBounds = true
         imageView.clipsToBounds = true
         return imageView
     }
    
    private static func createStackView(axis: NSLayoutConstraint.Axis, spacing: CGFloat) -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = axis
        stackView.spacing = spacing
        return stackView
    }
  
    // MARK: - Configure Method

    /// 設置 飲品圖片、名稱、副名稱
    func configure(with drink: Drink) {
        imageView.kf.setImage(with: drink.imageUrl, placeholder: UIImage(named: "starbucksLogo"))
        titleLabel.text = drink.name
        subNameLabel.text = drink.subName
    }
    
}
