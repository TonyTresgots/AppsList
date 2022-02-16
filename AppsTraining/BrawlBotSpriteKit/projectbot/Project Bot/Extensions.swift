//
//  Extensions.swift
//  Project Bot
//
//  Created by Tony Tresgots on 01/04/2020.
//  Copyright © 2020 Best Devs Evah. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
