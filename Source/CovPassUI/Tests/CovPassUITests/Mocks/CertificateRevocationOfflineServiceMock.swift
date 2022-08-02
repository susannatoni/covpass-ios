//
//  CertificateRevocationOfflineServiceMock.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation
import XCTest
import PromiseKit

final class CertificateRevocationOfflineServiceMock: CertificateRevocationOfflineServiceProtocol {

    var lastSuccessfulUpdate: Date?
    var shouldOfflineUpdate: Bool = false
    var state: CertificateRevocationServiceState = .idle
    let updateExpectation = XCTestExpectation(description: "updateExpectation")
    let resetExpectation = XCTestExpectation(description: "resetExpectation")

    func update() -> Promise<Void> {
        updateExpectation.fulfill()
        return .value
    }
    
    func updateNeeded() -> Bool {
        shouldOfflineUpdate
    }

    func reset() {
        resetExpectation.fulfill()
    }

    func updateIfNeeded() {
        update().cauterize()
    }
}
