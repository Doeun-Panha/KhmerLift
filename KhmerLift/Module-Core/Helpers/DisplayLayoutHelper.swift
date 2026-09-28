//
//  DisplayLayoutHelper.swift
//  KhmerLift
//
//  Created by Panha on 25/9/26.
//

import SwiftUI

// MARK: - Display Models
enum DisplayState {
    case compact      // Narrow / Outer screen layout
    case expanded     // Wide / Unfolded inner screen layout
    case splitView    // Multitasking / Side-by-side app layout
}

struct DisplayLayoutInfo {
    let size: CGSize
    let safeAreaInsets: EdgeInsets
    let state: DisplayState
    let isLandscape: Bool
    
    /// Returns true if screen is wide enough for dual-pane views
    var isMultiColumn: Bool {
        state == .expanded || size.width > 700
    }
}

// MARK: - View Modifier
private struct DisplayLayoutObserver: ViewModifier {
    @Environment(\.horizontalSizeClass) private var hSizeClass
    @Environment(\.verticalSizeClass) private var vSizeClass
    
    let onChange: (DisplayLayoutInfo) -> Void
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .task(id: "\(geometry.size)-\(String(describing: hSizeClass))") {
                    let currentSize = geometry.size
                    let isWide = currentSize.width > 600
                    
                    let state: DisplayState = {
                        if hSizeClass == .regular && isWide {
                            return .expanded
                        } else if hSizeClass == .compact && isWide {
                            return .splitView
                        } else {
                            return .compact
                        }
                    }()
                    
                    let info = DisplayLayoutInfo(
                        size: currentSize,
                        safeAreaInsets: geometry.safeAreaInsets,
                        state: state,
                        isLandscape: currentSize.width > currentSize.height
                    )
                    
                    onChange(info)
                }
        }
    }
}

// MARK: - View Extension
extension View {
    /// Observes display state, geometry, and posture shifts dynamically.
    func onDisplayLayoutChange(perform action: @escaping (DisplayLayoutInfo) -> Void) -> some View {
        self.modifier(DisplayLayoutObserver(onChange: action))
    }
}
