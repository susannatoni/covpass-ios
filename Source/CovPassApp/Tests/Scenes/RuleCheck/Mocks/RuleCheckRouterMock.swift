//
//  RuleCheckRouterMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassCommon
import CovPassUI
import PromiseKit
import XCTest

class RuleCheckRouterMock: RuleCheckRouterProtocol {
    let showCountrySelectionExpectation = XCTestExpectation(description: "showCountrySelectionExpectation")
    let showDateSelectionExpectation = XCTestExpectation(description: "showDateSelectionExpectation")
    let showResultDetailExpectation = XCTestExpectation(description: "showResultDetailExpectation")
    var sceneCoordinator: SceneCoordinator = SceneCoordinatorMock()

    var receivedCountries = [Country]()
    var receivedCountry: String?
    var countryToReturn = ""

    func showCountrySelection(countries: [Country], country: String) -> Promise<String> {
        receivedCountries = countries
        receivedCountry = country
        showCountrySelectionExpectation.fulfill()
        return .value(countryToReturn)
    }

    func showInternetConnectionDialog() -> Promise<Void> {
        .value
    }

    func showDateSelection(date _: Date) -> Promise<Date> {
        showDateSelectionExpectation.fulfill()
        return .value(Date())
    }

    func showResultDetail(result _: CertificateResult, country _: String, date _: Date) -> Promise<Void> {
        showResultDetailExpectation.fulfill()
        return .value(())
    }
}
