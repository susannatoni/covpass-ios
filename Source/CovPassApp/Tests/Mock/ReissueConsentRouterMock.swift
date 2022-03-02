//
//  ReissueConsentRouterMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
@testable import CovPassApp
import CovPassUI
import CovPassCommon
import XCTest
import PromiseKit

class ReissueConsentRouterMock: ReissueConsentRouterProtocol {

    var sceneCoordinator: SceneCoordinator = SceneCoordinatorMock()
    let showNextExpectation = XCTestExpectation(description: "showNextExpectation")
    let cancelExpectation = XCTestExpectation(description: "cancelExpectation")
    let routeToPrivacyExpectation = XCTestExpectation(description: "routeToPrivacyExpectation")
    let showErrorExpectation = XCTestExpectation(description: "showErrorExpectation")
    var receivedError: Error?

    func showNext(newTokens: [ExtendedCBORWebToken], oldTokens: [ExtendedCBORWebToken], resolver: Resolver<Void>) {
        showNextExpectation.fulfill()
    }
    
    func cancel(resolver:Resolver<Void>)  {
        cancelExpectation.fulfill()
        resolver.fulfill_()
    }
    
    func routeToPrivacyStatement() {
        routeToPrivacyExpectation.fulfill()
    }

    func showError(_ error: Error, resolver: Resolver<Void>) {
        receivedError = error
        showErrorExpectation.fulfill()
    }
}
