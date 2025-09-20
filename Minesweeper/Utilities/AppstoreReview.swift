//
//  AppstoreReview.swift
//  Minesweeper
//
//  Created by jh on 9/21/25.
//

import StoreKit

enum ReviewEvent { case win, bestTime, goodGacha }

struct ReviewGate {
    private static let lastPromptKey = "review.lastPromptDate"
    private static let winCountKey   = "review.winCount"
    private static let sessionKey    = "review.sessionCount"

    static func recordSession() {
        let d = UserDefaults.standard
        d.set(d.integer(forKey: sessionKey) + 1, forKey: sessionKey)
    }

    static func recordWin() {
        let d = UserDefaults.standard
        d.set(d.integer(forKey: winCountKey) + 1, forKey: winCountKey)
    }

    static func canPrompt(now: Date = Date()) -> Bool {
        let d = UserDefaults.standard
        let sessions = d.integer(forKey: sessionKey)
        let wins     = d.integer(forKey: winCountKey)
        if sessions < 5 || wins < 3 { return false }

        if let last = d.object(forKey: lastPromptKey) as? Date {
            if now.timeIntervalSince(last) < 90*24*3600 { return false } // 90일 쿨다운
        }
        return true
    }

    static func markPrompted(now: Date = Date()) {
        UserDefaults.standard.set(now, forKey: lastPromptKey)
    }
}
