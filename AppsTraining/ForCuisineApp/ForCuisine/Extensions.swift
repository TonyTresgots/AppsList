//
//  Extensions.swift
//  ForCuisine
//
//  Created by Tony Tresgots on 07/03/2020.
//  Copyright © 2020 Philip Lim. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

extension StringProtocol where Self: RangeReplaceableCollection {
    mutating func insert<S: StringProtocol>(separator: S, every n: Int) {
        for index in indices.dropFirst().reversed()
            where distance(from: indices.dropFirst().reversed()[0], to: index).isMultiple(of: n) {
            insert(contentsOf: separator, at: index)
        }
    }
    func inserting<S: StringProtocol>(separator: S, every n: Int) -> Self {
        var string = self
        string.insert(separator: separator, every: n)
        return string
    }
}

extension View {

    /// Hide or show the view based on a boolean value.
    ///
    /// Example for visibility:
    /// ```
    /// Text("Label")
    ///     .isHidden(true)
    /// ```
    ///
    /// Example for complete removal:
    /// ```
    /// Text("Label")
    ///     .isHidden(true, remove: true)
    /// ```
    ///
    /// - Parameters:
    ///   - hidden: Set to `false` to show the view. Set to `true` to hide the view.
    ///   - remove: Boolean value indicating whether or not to remove the view.
    func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
        modifier(HiddenModifier(isHidden: hidden, remove: remove))
    }
}


/// Creates a view modifier to show and hide a view.
///
/// Variables can be used in place so that the content can be changed dynamically.
fileprivate struct HiddenModifier: ViewModifier {

    fileprivate let isHidden: Bool
    fileprivate let remove: Bool

    init(isHidden: Bool, remove: Bool = false) {
        self.isHidden   = isHidden
        self.remove     = remove
    }

    fileprivate func body(content: Content) -> some View {
        Group {
            if isHidden {
                if remove {
                    EmptyView()
                } else {
                    content.hidden()
                }
            } else {
                content
            }
        }
    }
}

extension String {

    init(charsPerLine:Int, _ str:String){

        self = ""
        var idx = 0
        for char in str {
            self += "\(char)"
            idx = idx + 1
            if idx == charsPerLine {
                self += "\n"
                idx = 0
            }
        }

    }
}
