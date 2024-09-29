//
//  NoFavoritesView.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/9/25.
//

/*
 ## 關於使用 UIView 或 UICollectionViewCell 的場景選擇整理筆記：
 
 （由於一開始是使用 UICollectionViewCell來處理，後來發現「目前沒有我的最愛」是顯示在cell的位置，於是又改成了 UIView 才發現整體簡單很多。）
 
 &.使用 UIView 的情況：
   
    - 當顯示的內容是一個 靜態的視圖，例如「目前沒有我的最愛」這類 不會變動 的訊息或畫面。
    - 適合用來當作 背景視圖，當你需要在某些狀況下（例如清空收藏後）顯示特定訊息時，可以使用 UIView。

    * 優點： 靈活度高，可以任意放置 UI 元素，不受限於 UICollectionView 的項目結構。
    * 缺點： 不屬於 UICollectionView 的結構，適合顯示不屬於 collection 的元素。

 &. 使用 UICollectionViewCell 的情況：

    - 當希望顯示的訊息或內容是 UICollectionView 的一部分時（例如列表的一項）。
    - 如果「沒有收藏」這個訊息是 collection 內的一個項目，且你希望它在資料結構上是 UICollectionView 的一部分，可以使用 UICollectionViewCell。

    * 優點： 能與 UICollectionView 結構統一管理，能夠在資料驅動的 UI 中扮演一部分的角色。
    * 缺點： 如果只是單純顯示靜態訊息，會顯得有些過於複雜。
 
 &. 選擇指引：

    - 如果需要的是 當資料清空時 顯示一個靜態的「沒有內容」訊息，並且這個訊息不屬於 collection 的一部分，使用 UIView 會比較合適。
    - 如果需要「沒有內容」訊息作為 UICollectionView 的一項資料項目，且希望它參與 UICollectionView 的資料更新機制，則使用 UICollectionViewCell。
 */

import UIKit

/// 顯示「目前沒有我的最愛」提示的自定義視圖
///
/// `NoFavoritesView` 是顯示在 UICollectionView 的背景，而不是 UICollectionView 的一個項目（cell）。 當收藏列表為空時，會透過 collectionView.backgroundView 來顯示這個背景視圖。
class NoFavoritesView: UIView {
    
    // MARK: - UI Elements
    
    /// 顯示「目前沒有我的最愛」的提示訊息
    let messageLabel = createLabel(text: "No Favorites", fontSize: 20, weight: .bold, textColor: .lightWhiteGray, alignment: .center)
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 設置視圖佈局
    private func setupView() {
        addSubview(messageLabel)
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    // MARK: - Factory Methods
    
    private static func createLabel(text: String, fontSize: CGFloat, weight: UIFont.Weight, textColor: UIColor, alignment: NSTextAlignment) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        label.textColor = textColor
        label.textAlignment = alignment
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}
