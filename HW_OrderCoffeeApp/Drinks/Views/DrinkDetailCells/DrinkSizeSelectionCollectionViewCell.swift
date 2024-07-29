//
//  DrinkSizeSelectionCollectionViewCell.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/6/14.
//


/*
 1. NotificationCenter 管理：
        - 確保在 deinit 中移除觀察者，防止內存洩漏。
        - 使用 NotificationCenter 來通知尺寸改變與更新選中的狀態，避免過度刷新。（導致在滾動選項後，並選取尺寸時，會重置滾動狀態。）
    
 2. 局部刷新：
        - 只刷新價格訊息部分，避免不必要的滾動重置。
        - 在按鈕狀態更新時，只更新選中狀態的按鈕。
 
 3. UIStackView 改善：
        - 在 DrinkSizeSelectionCollectionViewCell 中使用 UIStackView 來管理按鈕佈局，使按鈕平均分佈。
 
 4. Layout建立：
        - 使用 UICollectionViewCompositionalLayout 來建立靈活的佈局，滿足不同的布局需求。
 */

// MARK: - NotificationCenter

/*
import UIKit

/// 展示飲品尺寸選擇的 CollectionViewCell
class DrinkSizeSelectionCollectionViewCell: UICollectionViewCell {
 
    static let reuseIdentifier = "DrinkSizeSelectionCollectionViewCell"
    
    /// 尺寸選擇的按鈕
    let button: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemGray.cgColor
        button.addTarget(self, action: #selector(sizeButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    var size: String?
    
    var isSelectedSize: Bool = false {
        didSet {
            updateButtonSelection()
        }
    }
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(button)
        setupConstraints()
        
        /// 添加通知觀察者，用於監聽尺寸選擇變更
        /// 更新按鈕狀態：在收到 UpdateSelectedSize 通知後，按鈕會檢查自己是否是選中的尺寸，並更新邊框顏色、背景顏色。
        NotificationCenter.default.addObserver(self, selector: #selector(updateSelectedSize(_:)), name: NSNotification.Name("UpdateSelectedSize"), object: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("UpdateSelectedSize"), object: nil)
    }
    
    /// 設置按鈕的尺寸和選中狀態
    func configure(with size: String, isSelected: Bool) {
        self.size = size
        button.setTitle(size, for: .normal)
        self.isSelectedSize = isSelected
        updateButtonSelection()
    }
    
    /// 按鈕點擊事件
    @objc func sizeButtonTapped(_ sender: UIButton) {
        guard let size = sender.titleLabel?.text else { return }
        
        /// 發送尺寸更改通知（DrinkDetailViewController）
        NotificationCenter.default.post(name: NSNotification.Name("SizeChanged"), object: nil, userInfo: ["size": size])
        
        // 彈簧動畫效果
        button.addSpringAnimation()
    }
    
    /// 更新選中的尺寸
    @objc private func updateSelectedSize(_ notification: Notification) {
        guard let selectedSize = notification.userInfo?["size"] as? String else { return }
        isSelectedSize = (size == selectedSize)
    }
    
    /// 更新按鈕選中狀態的外觀
    private func updateButtonSelection() {
        if isSelectedSize {
            button.layer.borderColor = UIColor.systemBlue.cgColor
            button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        } else {
            button.layer.borderColor = UIColor.systemGray.cgColor
            button.backgroundColor = UIColor.clear
        }
    }
    
    /// 配置按钮约束
    private func setupConstraints() {
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
}
*/



// MARK: - 完全使用閉包
import UIKit

/// 展示飲品尺寸選擇的 CollectionViewCell
class DrinkSizeSelectionCollectionViewCell: UICollectionViewCell {
 
    static let reuseIdentifier = "DrinkSizeSelectionCollectionViewCell"
    
    /// 尺寸選擇的按鈕
    let button: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemGray.cgColor
        button.addTarget(self, action: #selector(sizeButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    var size: String?
    
    var isSelectedSize: Bool = false {
        didSet {
            updateButtonSelection()
        }
    }
    
    /// 點擊尺寸按鈕時觸發的閉包，用於傳遞選中的尺寸。
    var sizeSelected: ((String) -> Void)?
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(button)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /// 設置按鈕的尺寸和選中狀態
    func configure(with size: String, isSelected: Bool) {
        self.size = size
        button.setTitle(size, for: .normal)
        self.isSelectedSize = isSelected
        updateButtonSelection()
    }
    
    /// 按鈕點擊事件
    @objc func sizeButtonTapped(_ sender: UIButton) {
        guard let size = sender.titleLabel?.text else { return }
        sizeSelected?(size)
        button.addSpringAnimation()         // 彈簧動畫效果
    }
    
    /// 更新按鈕選中狀態的外觀
    private func updateButtonSelection() {
        if isSelectedSize {
            button.layer.borderColor = UIColor(red: 39/255, green: 37/255, blue: 31/255, alpha: 1).cgColor
            button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        } else {
            button.layer.borderColor = UIColor.systemGray.cgColor
            button.backgroundColor = UIColor.clear
        }
    }
    
    /// 配置按钮约束
    private func setupConstraints() {
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
}

