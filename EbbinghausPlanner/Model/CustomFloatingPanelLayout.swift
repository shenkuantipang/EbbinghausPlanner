//
//  CustomFloatingPanelLayout.swift
//  EbbinghausPlanner
//
//  Created by 이승기 on 2021/06/17.
//

import UIKit
import FloatingPanel

class CustomFloatingPanelLayout: FloatingPanelLayout {
    let position: FloatingPanelPosition = .bottom
    var initialState: FloatingPanelState = .half
    
    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 16.0, edge: .top, referenceGuide: .safeArea),
            .half: FloatingPanelLayoutAnchor(fractionalInset: 0.75, edge: .bottom, referenceGuide: .safeArea),
            .tip: FloatingPanelLayoutAnchor(absoluteInset: 300, edge: .bottom, referenceGuide: .safeArea),
        ]
    }
}
