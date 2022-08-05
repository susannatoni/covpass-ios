//
//  AppInformationViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassCommon
import CovPassUI
import XCTest

class CheckAppInformationBaseViewModelTests: XCTestCase {
    func testEntries_empty() {
        // Given
        let sut = prepareSut(with: UserDefaultsPersistence())

        // When
        let entries = sut.entries

        // Then
        XCTAssertEqual(entries.count, 2)
    }

    private func prepareSut(with persistence: UserDefaultsPersistence = UserDefaultsPersistence()) -> CheckAppInformationBaseViewModel {
        CheckAppInformationBaseViewModel(
            router: AppInformationRouterMock(),
            entries: [],
            userDefaults: persistence
        )
    }

    func testEntries_checking_rules_right_title_nil() throws {
        // Given
        let sut = prepareSut()

        // When
        let entries = sut.entries

        // Then
        let entry = try XCTUnwrap(entries[0])
        XCTAssertNil(entry.rightTitle)
    }

    func testEntries_expertMode_default() throws {
        // Given
        // TODO: replace with twine key
        let expectedTitle = "Off".localized
        let persistence = UserDefaultsPersistence()
        try persistence.delete(UserDefaults.keyRevocationExpertMode)
        let sut = prepareSut(with: persistence)

        // When
        let entries = sut.entries

        // Then
        let entry = try XCTUnwrap(entries[1])
        XCTAssertEqual(entry.rightTitle, expectedTitle)
    }
    
    func testEntries_expertMode_false() throws {
        // Given
        // TODO: replace with twine key
        let expectedTitle = "Off".localized
        var persistence = UserDefaultsPersistence()
        persistence.revocationExpertMode = false
        let sut = prepareSut(with: persistence)

        // When
        let entries = sut.entries

        // Then
        let entry = try XCTUnwrap(entries[1])
        XCTAssertEqual(entry.rightTitle, expectedTitle)
    }
    
    func testEntries_expertMode_true() throws {
        // Given
        // TODO: replace with twine key
        let expectedTitle = "On".localized
        var persistence = UserDefaultsPersistence()
        persistence.revocationExpertMode = true
        let sut = prepareSut(with: persistence)

        // When
        let entries = sut.entries

        // Then
        let entry = try XCTUnwrap(entries[1])
        XCTAssertEqual(entry.rightTitle, expectedTitle)
    }
}

class GermanAppInformationViewModelTests: XCTestCase {
    func testEntries_default() {
        // Given
        let expectedTitles = [
            AppInformationBaseViewModel.Texts.leichteSprache,
            AppInformationBaseViewModel.Texts.contactTitle,
            AppInformationBaseViewModel.Texts.faqTitle,
            AppInformationBaseViewModel.Texts.datenschutzTitle,
            AppInformationBaseViewModel.Texts.companyDetailsTitle,
            AppInformationBaseViewModel.Texts.openSourceLicenseTitle,
            AppInformationBaseViewModel.Texts.accessibilityStatementTitle,
            AppInformationBaseViewModel.Texts.appInformationTitle,
        ]
        let sut = GermanAppInformationViewModel(
            router: AppInformationRouterMock(),
            userDefaults: UserDefaultsPersistence()
        )

        // When
        let entries = sut.entries

        // Then
        XCTAssertEqual(entries.count, 9)
        for index in 0..<min(entries.count, expectedTitles.count) {
            XCTAssertEqual(entries[index].title, expectedTitles[index])
        }
    }
}

class EnglishAppInformationViewModelTests: XCTestCase {
    func testEntries_default() {
        // Given
        let expectedTitles = [
            AppInformationBaseViewModel.Texts.contactTitle,
            AppInformationBaseViewModel.Texts.faqTitle,
            AppInformationBaseViewModel.Texts.datenschutzTitle,
            AppInformationBaseViewModel.Texts.companyDetailsTitle,
            AppInformationBaseViewModel.Texts.openSourceLicenseTitle,
            AppInformationBaseViewModel.Texts.accessibilityStatementTitle,
            AppInformationBaseViewModel.Texts.appInformationTitle,
        ]
        let sut = EnglishAppInformationViewModel(
            router: AppInformationRouterMock(),
            userDefaults: UserDefaultsPersistence()
        )

        // When
        let entries = sut.entries

        // Then
        XCTAssertEqual(entries.count, 8)
        for index in 0..<min(entries.count, expectedTitles.count) {
            XCTAssertEqual(entries[index].title, expectedTitles[index])
        }
    }
}
