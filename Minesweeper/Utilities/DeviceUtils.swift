//
//  DeviceUtils.swift
//  Minesweeper
//
//  Created by jh on 2/16/25.
//

import SwiftUI

struct DeviceUtils {
    static var hasNotch: Bool {
        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first
        let topInset = keyWindow?.safeAreaInsets.top ?? 0
        return topInset > 20
    }
}
