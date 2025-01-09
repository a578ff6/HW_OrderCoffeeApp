//
//  StoreInfoPanelLayout.swift
//  HW_OrderCoffeeApp
//
//  Created by 曹家瑋 on 2024/10/30.
//

// MARK: - FloatingPanelLayout 重點筆記
/**
 
 ## FloatingPanelLayout 重點筆記
 
 1. `FloatingPanelLayout`：StoreInfoPanelLayout 繼承自 FloatingPanelLayout，這個類別負責自訂浮動面板的顯示位置、初始狀態以及各種狀態下的高度。
 
 - `position`：設定浮動面板出現的位置，這裡設定為 .bottom，表示面板將從螢幕底部彈出。
 -  `initialState`：定義面板的初始狀態，這裡設定為 .tip，表示一開始只會顯示小部分的面板（最低高度）。
 - `anchors`：定義浮動面板的各種狀態及其對應的高度。這些狀態可以讓面板顯示在不同的位置，例如完全展開、半展開或最小顯示（Tip）。
 
 &. 註解重點解釋
 
 1. position：
    - 設定浮動面板的位置，這裡設定為 .bottom，表示面板會從螢幕底部彈出，這是常見的設計，類似 Google Maps 或其他地圖應用的方式。
 
 2. initialState：
    - 設定浮動面板的初始狀態，這裡設定為 .tip，意味著面板一開始只會顯示最低高度。這樣的設置可以讓使用者在初始時看到面板的一小部分，引導他們進一步互動。
 
 3. anchors：
    - .full（完全展開）：這裡的註解提到 .full 狀態時，設置為距離頂部安全區域 16 點，可以讓面板幾乎全屏顯示，但這部分在程式碼中被註解掉了（可以根據需求啟用）。
    - .half（半展開）：fractionalInset: 0.4 代表面板的高度是螢幕底部至安全區域高度的 40%，這樣的狀態通常適合顯示更多信息，但不完全佔據螢幕。
    - .tip（最小狀態）：absoluteInset: 80.0 表示面板在最小狀態下，距離螢幕底部有 80 點的間距，這樣可以確保面板不會完全消失，並提供使用者一個抓取面板的提示（通常配合 grabber 使用）。
 
 &. 使用心得
 
    - 一開始使用 蘋果自己的 `sheetPresentationController`，但我發現會導致整個 `StoreInfoViewController` 被收起，於是改用 FloatingPanel。
    - 彼得潘對於 sheetPresentationController 的紀錄 （ https://reurl.cc/5dmOzz ）
    - FloatingPanelLayout 能夠非常靈活地定義浮動面板行為的類別，它允許設計不同的狀態，並為這些狀態設置高度，提供類似 Google Maps 那樣的用戶體驗。
    - 可以根據應用場景，選擇是否啟用 .full 狀態，或者只讓面板有 .half 和 .tip 狀態，以提供合適的交互方式。
 */

import UIKit
import FloatingPanel

/// 用於設定浮動面板 (FloatingPanel) 在螢幕中的佈局位置及各種狀態的顯示方式
class StoreInfoPanelLayout: FloatingPanelLayout {
    
    // MARK: - Panel Position Settings

    // position 決定面板在螢幕中的顯示位置，這裡設定為從底部彈出
    var position: FloatingPanelPosition {
        return .bottom
    }
    
    // MARK: - Initial State Settings

    // initialState 設定面板剛出現時的狀態，這裡設定為最小狀態（tip），即初始時面板只顯示一小部分
    var initialState: FloatingPanelState {
        return .tip
    }
    
    // MARK: - Panel Anchors Setup

    // anchors 定義面板在不同狀態下的顯示高度
    var anchors: [FloatingPanelState : FloatingPanelLayoutAnchoring] {
        return [
            // 完全展開的高度，設置為距離頂部安全區域 16 點
            // .full: FloatingPanelLayoutAnchor(absoluteInset: 16.0, edge: .top, referenceGuide: .safeArea),
            
            // 半展開狀態，設置為距離底部 315
            .half: FloatingPanelLayoutAnchor(absoluteInset: 315, edge: .bottom, referenceGuide: .safeArea),

            // 最小狀態 (tip)，設置為距離底部 80 點，防止完全收起
            .tip: FloatingPanelLayoutAnchor(absoluteInset: 50, edge: .bottom, referenceGuide: .safeArea)
        ]
    }
    
}
