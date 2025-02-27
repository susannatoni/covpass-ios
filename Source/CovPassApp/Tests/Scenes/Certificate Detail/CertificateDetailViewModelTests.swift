//
//  CertificateDetailViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CertLogic
@testable import CovPassApp
import CovPassCommon
import CovPassUI
import PromiseKit
import XCTest

class CertificateDetailViewModelTests: XCTestCase {
    private var boosterLogic: BoosterLogicMock!
    private var certificateHolderStatusModel: CertificateHolderStatusModelMock!
    private var delegate: MockViewModelDelegate!
    private var promise: Promise<CertificateDetailSceneResult>!
    private var resolver: Resolver<CertificateDetailSceneResult>!
    private var router: CertificateDetailRouterMock!
    private var sut: CertificateDetailViewModel!
    private var vaccinationRepo: VaccinationRepositoryMock!
    private var persistence: MockPersistence!
    private var descriptionText: String!
    private var rule1: Rule!
    private var result1: ValidationResult!
    private var results: [RuleType?: [ValidationResult]]?

    override func setUpWithError() throws {
        descriptionText = "This is a description"
        rule1 = Rule(identifier: "FOO", description: [.init(lang: "en", desc: descriptionText)])
        result1 = .init(rule: rule1)
        results = [.impfstatusBZwei: [result1]]
        let certificates: [ExtendedCBORWebToken] = try [
            .token1Of2(),
            .token2Of2(),
            .token3Of3()
        ]
        let (promise, resolver) = Promise<CertificateDetailSceneResult>.pending()
        self.promise = promise
        self.resolver = resolver
        router = .init()
        certificateHolderStatusModel = .init()
        persistence = MockPersistence()
        configureCustomSut(certificates: certificates)
    }

    private func configureCustomSut(certificates: [ExtendedCBORWebToken] = [CBORWebToken.mockVaccinationCertificate.extended()],
                                    maskRulesAvailable _: Bool = false,
                                    needsMask _: Bool = false,
                                    isVaccinationCycleComplete: Bool = false,
                                    vaccinatsionCycleCompleteByRule: RuleType? = .impfstatusEEins) {
        boosterLogic = BoosterLogicMock()
        vaccinationRepo = VaccinationRepositoryMock()
        delegate = .init()
        rule1.description.first?.desc = descriptionText + " " + (vaccinatsionCycleCompleteByRule?.rawValue ?? "")
        results = [vaccinatsionCycleCompleteByRule: [.init(rule: rule1)]]
        certificateHolderStatusModel.isVaccinationCycleIsComplete = .init(passed: isVaccinationCycleComplete, results: results)
        persistence.stateSelection = "SH"
        sut = CertificateDetailViewModel(
            router: router,
            repository: vaccinationRepo,
            boosterLogic: boosterLogic,
            certificates: certificates,
            resolvable: resolver,
            certificateHolderStatusModel: certificateHolderStatusModel,
            userDefaults: persistence
        )
        sut.delegate = delegate
    }

    private func configureSut(booosterState: BoosterCandidate.BoosterState = .none) throws {
        let token3Of3 = try ExtendedCBORWebToken.token3Of3()
        var boosterCandidate = BoosterCandidate(certificate: token3Of3)
        boosterCandidate.state = booosterState
        let certificates: [ExtendedCBORWebToken] = try [
            .token1Of2(),
            .token2Of2(),
            token3Of3
        ]
        boosterLogic.boosterCandidates = [boosterCandidate]
        sut = CertificateDetailViewModel(
            router: router,
            repository: VaccinationRepositoryMock(),
            boosterLogic: boosterLogic,
            certificates: certificates,
            resolvable: resolver,
            certificateHolderStatusModel: certificateHolderStatusModel,
            userDefaults: persistence
        )
    }

    override func tearDownWithError() throws {
        descriptionText = nil
        rule1 = nil
        result1 = nil
        results = nil
        persistence = nil
        vaccinationRepo = nil
        boosterLogic = nil
        delegate = nil
        promise = nil
        router = nil
        sut = nil
    }

    func testShowBoosterNotification_no_booster_candidate() {
        // When
        let showBoosterNotification = sut.showBoosterNotification

        // Then
        XCTAssertTrue(showBoosterNotification)
    }

    func testShowBoosterNotification_booster_candidate_state_none() throws {
        // Given
        try configureSut(booosterState: .none)

        // When
        let showBoosterNotification = sut.showBoosterNotification

        // Then
        XCTAssertFalse(showBoosterNotification)
    }

    func testShowBoosterNotification_booster_candidate_state_qualified() throws {
        // Given
        try configureSut(booosterState: .qualified)

        // When
        let showBoosterNotification = sut.showBoosterNotification

        // Then
        XCTAssertTrue(showBoosterNotification)
    }

    func testShowBoosterNotification_booster_candidate_state_new() throws {
        // Given
        try configureSut(booosterState: .new)

        // When
        let showBoosterNotification = sut.showBoosterNotification

        // Then
        XCTAssertTrue(showBoosterNotification)
    }

    func testStartReissue() throws {
        // When
        sut.triggerBoosterReissue()

        // Then
        wait(for: [router.expectationShowReissue], timeout: 0.1)
    }

    func testShowReissueNotification_ReissueQualifiedCase1() throws {
        // GIVEN: 1/1 and 2/2 qualifies for reissue
        let certificates: [ExtendedCBORWebToken] = try [
            .token1Of1(),
            .token2Of2()
        ]
        configureCustomSut(certificates: certificates)

        // THEN
        XCTAssertTrue(sut.showBoosterReissueNotification)
    }

    func testShowReissueNotification_ReissueNotQualifiedCase_RecoveryIsYoungerThanVaccinations() throws {
        // GIVEN: 1/1 and 2/2 and recovery cert qualifies for reissue
        let certificates: [ExtendedCBORWebToken] = try [
            CBORWebToken.mockRecoveryCertificate.extended(),
            .token1Of1(),
            .token2Of2()
        ]
        configureCustomSut(certificates: certificates)

        // THEN
        XCTAssert(sut.showBoosterReissueNotification)
    }

    func testShowReissueNotification_ReissueQualifiedCase2() throws {
        // GIVEN: 1/1 and 2/2 and recovery cert qualifies for reissue
        let certificates: [ExtendedCBORWebToken] = try [
            CBORWebToken.mockRecoveryCertificate.extended(),
            .token1Of1(),
            .token2Of2()
        ]
        certificates[0].firstRecovery!.fr = Date().addingTimeInterval(-2000)
        certificates[1].firstVaccination!.dt = Date().addingTimeInterval(-1500)
        certificates[2].firstVaccination!.dt = Date().addingTimeInterval(-1000)
        configureCustomSut(certificates: certificates)

        // THEN
        XCTAssertTrue(sut.showBoosterReissueNotification)
    }

    func testNotShowReissueNotification_NotQualified() throws {
        // GIVEN: 2/2 doesnt qualifies for reissue
        let certificates: [ExtendedCBORWebToken] = try [
            .token2Of2()
        ]
        configureCustomSut(certificates: certificates)

        // THEN
        XCTAssertFalse(sut.showBoosterReissueNotification)
    }

    func testUpdateReissueCandidate() throws {
        // GIVEN: 1/1 and 2/2 qualifies for reissue
        let certificates: [ExtendedCBORWebToken] = try [
            .token1Of1(),
            .token2Of2()
        ]
        configureCustomSut(certificates: certificates)

        // WHEN update reissues candidate it updates cert that they are already seen
        sut.updateReissueCandidate(to: true)
        // THEN
        wait(for: [vaccinationRepo.setReissueAlreadySeen], timeout: 1)
    }

    func testName() throws {
        // Given
        try configureCustomSut(certificates: tokensWithDifferentButMatchingFnt())

        // When
        let name = sut.name

        // Then
        XCTAssertEqual(name, "Erika Mustermann")
    }

    private func tokensWithDifferentButMatchingFnt() throws -> [ExtendedCBORWebToken] {
        try [
            .token1Of2SchmidtMustermann(),
            .token2Of2Mustermann()
        ]
    }

    func testName_reversed_certificates() throws {
        // Given
        try configureCustomSut(certificates: tokensWithDifferentButMatchingFnt().reversed())

        // When
        let name = sut.name

        // Then
        XCTAssertEqual(name, "Erika Mustermann")
    }

    func testNameReversed() throws {
        // Given
        try configureCustomSut(certificates: tokensWithDifferentButMatchingFnt())

        // When
        let name = sut.nameReversed

        // Then
        XCTAssertEqual(name, "Mustermann, Erika")
    }

    func testNameReversed_reversed_certificates() throws {
        // Given
        try configureCustomSut(certificates: tokensWithDifferentButMatchingFnt().reversed())

        // When
        let name = sut.nameReversed

        // Then
        XCTAssertEqual(name, "Mustermann, Erika")
    }

    func testNameTransliterated() throws {
        // Given
        try configureCustomSut(certificates: tokensWithDifferentButMatchingFnt())

        // When
        let name = sut.nameTransliterated

        // Then
        XCTAssertEqual(name, "MUSTERMANN, ERIKA")
    }

    func testNameTransliterated_reversed_certificates() throws {
        // Given
        try configureCustomSut(certificates: tokensWithDifferentButMatchingFnt().reversed())

        // When
        let name = sut.nameTransliterated

        // Then
        XCTAssertEqual(name, "MUSTERMANN, ERIKA")
    }

    func testFavoriteIcon_default() {
        // When
        let favoriteIcon = sut.favoriteIcon

        // Then
        XCTAssertNil(favoriteIcon)
    }

    func testFavoriteIcon_certificates_of_one_person_which_is_favorite() {
        // Given
        vaccinationRepo.favoriteToggle = true
        sut.refresh()
        wait(for: [delegate.viewModelDidUpdateExpectation], timeout: 2)

        // When
        let favoriteIcon = sut.favoriteIcon

        // Then
        XCTAssertNil(favoriteIcon)
    }

    func testFavoriteIcon_certificates_of_one_person_which_is_not_favorite() {
        // Given
        vaccinationRepo.favoriteToggle = false
        sut.refresh()
        wait(for: [delegate.viewModelDidUpdateExpectation], timeout: 2)

        // When
        let favoriteIcon = sut.favoriteIcon

        // Then
        XCTAssertNil(favoriteIcon)
    }

    func testFavoriteIcon_certificates_of_two_persons_this_persons_is_favorite() throws {
        // Given
        vaccinationRepo.favoriteToggle = true
        vaccinationRepo.certificates = try [
            ExtendedCBORWebToken.token1Of1(),
            ExtendedCBORWebToken.token2Of2Pérez()
        ]
        sut.refresh()
        wait(for: [delegate.viewModelDidUpdateExpectation], timeout: 2)

        // When
        let favoriteIcon = sut.favoriteIcon

        // Then
        XCTAssertEqual(favoriteIcon, UIImage.starFull)
    }

    func testFavoriteIcon_certificates_of_two_persons_this_person_is_not_favorite() throws {
        // Given
        vaccinationRepo.favoriteToggle = false
        vaccinationRepo.certificates = try [
            ExtendedCBORWebToken.token1Of1(),
            ExtendedCBORWebToken.token2Of2Pérez()
        ]
        sut.refresh()
        wait(for: [delegate.viewModelDidUpdateExpectation], timeout: 2)

        // When
        let favoriteIcon = sut.favoriteIcon

        // Then
        XCTAssertEqual(favoriteIcon, UIImage.starPartial)
    }

    func testImmunizationButton_neither_revoked_nor_invalid() {
        // Given
        sut.refresh()

        // When
        let immunizationButton = sut.immunizationButton

        // Then
        XCTAssertEqual(immunizationButton, "Show certificates")
    }

    func testImmunizationButton_revoked() throws {
        // Given
        try configureSut(revoked: true)

        // When
        let immunizationButton = sut.immunizationButton

        // Then
        XCTAssertEqual(immunizationButton, "Add new certificate")
    }

    private func configureSut(invalid: Bool? = nil, revoked: Bool? = nil) throws {
        var token = try ExtendedCBORWebToken.token1Of1()
        token.revoked = revoked
        token.invalid = invalid
        configureCustomSut(certificates: [token])
    }

    func testImmunizationButton_invalid() throws {
        // Given
        try configureSut(invalid: true)

        // When
        let immunizationButton = sut.immunizationButton

        // Then
        XCTAssertEqual(immunizationButton, "Add new certificate")
    }

    func testImmunizationIcon_revoked() throws {
        // Given
        try configureSut(revoked: true)

        // When
        let immunizationIcon = sut.immunizationIcon

        // Then
        XCTAssertEqual(immunizationIcon, .statusExpiredCircle)
    }

    func testImmunizationIcon_invalid() throws {
        // Given
        try configureSut(invalid: true)

        // When
        let immunizationIcon = sut.immunizationIcon

        // Then
        XCTAssertEqual(immunizationIcon, .statusExpiredCircle)
    }

    func testImmunizationTitle_revoked() throws {
        // Given
        try configureSut(revoked: true)

        // When
        let immunizationTitle = sut.immunizationTitle

        // Then
        XCTAssertEqual(immunizationTitle, "Certificate invalid")
    }

    func testImmunizationTitle_invalid() throws {
        // Given
        try configureSut(invalid: true)

        // When
        let immunizationTitle = sut.immunizationTitle

        // Then
        XCTAssertEqual(immunizationTitle, "Certificate invalid")
    }

    func testImmunizationTitle_vaccination() {
        // Given
        let token = CBORWebToken.mockVaccinationCertificate
            .doseNumber(2)
            .seriesOfDoses(2)
            .medicalProduct(.johnsonjohnson)
            .extended()
        configureCustomSut(certificates: [token])

        // When
        let immunizationTitle = sut.immunizationTitle

        // Then
        XCTAssertEqual(immunizationTitle, "Vaccine dose 2 of 2")
    }

    func testImmunizationBody_revoked_vaccination_certificate_german_issuer() throws {
        // Given
        try configureSut(revoked: true)

        // When
        let immunizationBody = sut.immunizationBody

        // Then
        XCTAssertEqual(immunizationBody, "The RKI has revoked the certificate due to an official decree.")
    }

    func testImmunizationBody_revoked_vaccination_certificate_non_german_issuer() throws {
        // Given
        var token = try ExtendedCBORWebToken.token1Of1()
        token.vaccinationCertificate.iss = "XL"
        token.revoked = true
        configureCustomSut(certificates: [token])

        // When
        let immunizationBody = sut.immunizationBody

        // Then
        XCTAssertEqual(immunizationBody, "The certificate was revoked by the certificate issuer due to an official decision.")
    }

    func testImmunizationBody_revoked_test_certificate_german_issuer() {
        // Given
        var token = CBORWebToken.mockTestCertificate.extended()
        token.revoked = true
        configureCustomSut(certificates: [token])

        // When
        let immunizationBody = sut.immunizationBody

        // Then
        XCTAssertEqual(immunizationBody, "The RKI has revoked the certificate due to an official decree.")
    }

    func testImmunizationBody_revoked_test_certificate_non_german_issuer() throws {
        // Given
        var token = CBORWebToken.mockTestCertificate.extended()
        token.vaccinationCertificate.iss = "XL"
        token.revoked = true
        configureCustomSut(certificates: [token])

        // When
        let immunizationBody = sut.immunizationBody

        // Then
        XCTAssertEqual(immunizationBody, "The certificate was revoked by the certificate issuer due to an official decision.")
    }

    func testImmunizationBody_revoked_recovery_certificate_german_issuer() {
        // Given
        var token = CBORWebToken.mockRecoveryCertificate.extended()
        token.revoked = true
        configureCustomSut(certificates: [token])

        // When
        let immunizationBody = sut.immunizationBody

        // Then
        XCTAssertEqual(immunizationBody, "The RKI has revoked the certificate due to an official decree.")
    }

    func testImmunizationBody_revoked_recovery_certificate_non_german_issuer() throws {
        // Given
        var token = CBORWebToken.mockRecoveryCertificate.extended()
        token.vaccinationCertificate.iss = "XL"
        token.revoked = true
        configureCustomSut(certificates: [token])

        // When
        let immunizationBody = sut.immunizationBody

        // Then
        XCTAssertEqual(immunizationBody, "The certificate was revoked by the certificate issuer due to an official decision.")
    }

    func testImmunizationBody_expired_certificate_non_german_issuer() throws {
        // Given
        var token = CBORWebToken.mockRecoveryCertificate.extended()
        token.vaccinationCertificate.iss = "XL"
        token.vaccinationCertificate.exp = .init(timeIntervalSinceReferenceDate: 0)
        configureCustomSut(certificates: [token])

        // When
        let immunizationBody = sut.immunizationBody

        // Then
        XCTAssertEqual(
            immunizationBody,
            "Your latest certificate was not issued in Germany and therefore cannot be renewed in the app. Please contact the issuer of the certificate."
        )
    }

    func testImmunizationBody_expiring_soon_certificate_non_german_issuer() throws {
        // Given
        var token = CBORWebToken.mockRecoveryCertificate.extended()
        token.vaccinationCertificate.iss = "XL"
        token.vaccinationCertificate.exp = .init(timeIntervalSinceNow: 1000)
        configureCustomSut(certificates: [token])

        // When
        let immunizationBody = sut.immunizationBody

        // Then
        XCTAssertEqual(
            immunizationBody,
            "Your latest certificate was not issued in Germany and therefore cannot be renewed in the app. Please contact the issuer of the certificate."
        )
    }

    func testImmunizationBody_expired_certificate_german_issuer() throws {
        // Given
        var token = CBORWebToken.mockRecoveryCertificate.extended()
        token.vaccinationCertificate.exp = .init(timeIntervalSinceReferenceDate: 0)
        configureCustomSut(certificates: [token])

        // When
        let immunizationBody = sut.immunizationBody

        // Then
        XCTAssertEqual(
            immunizationBody,
            "The expiry date of your latest certificate has passed. You can conveniently renew this certificate in the CovPass app. Previous certificates will not be renewed. To do so, use the renewal function in the overview of your certificates or scan a newly issued certificate."
        )
    }

    func testShowScanHint_revoked() throws {
        // Given
        try configureSut(revoked: true)

        // When
        let showScanHint = sut.showScanHint

        // Then
        XCTAssertFalse(showScanHint)
    }

    func testShowScanHint_not_revoked() throws {
        // Given
        try configureSut()

        // When
        let showScanHint = sut.showScanHint

        // Then
        XCTAssertTrue(showScanHint)
    }

    func testImmunizationButtonTapped_certificate_invalid() throws {
        // Given
        try configureSut(invalid: true)
        let expectation = XCTestExpectation()
        promise
            .done { result in
                switch result {
                case .addNewCertificate:
                    expectation.fulfill()
                default:
                    break
                }
            }
            .cauterize()

        // When
        sut.immunizationButtonTapped()

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testImmunizationButtonTapped_certificate_revoked() throws {
        // Given
        try configureSut(revoked: true)
        let expectation = XCTestExpectation()
        promise
            .done { result in
                switch result {
                case .addNewCertificate:
                    expectation.fulfill()
                default:
                    break
                }
            }
            .cauterize()

        // When
        sut.immunizationButtonTapped()

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testImmunizationButtonTapped_valid_certificate() throws {
        // Given
        try configureSut()
        let expectation = XCTestExpectation()
        promise
            .done { result in
                switch result {
                case .showCertificatesOnOverview:
                    expectation.fulfill()
                default:
                    break
                }
            }
            .cauterize()

        // When
        sut.immunizationButtonTapped()

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testShowVaccinationExpiryReissueNotification_no_reissueble_vaccination() throws {
        // Given
        configureCustomSut(certificates: [.nonReissuableVaccination])

        // When
        let showVaccinationExpiryReissueNotification = sut.showVaccinationExpiryReissueNotification

        // Then
        XCTAssertFalse(showVaccinationExpiryReissueNotification)
    }

    func testShowVaccinationExpiryReissueNotification_reissueble_vaccination() throws {
        // Given
        configureCustomSut(certificates: [.reissuableVaccination])

        // When
        let showVaccinationExpiryReissueNotification = sut.showVaccinationExpiryReissueNotification

        // Then
        XCTAssertTrue(showVaccinationExpiryReissueNotification)
    }

    func testTriggerVaccinationExpiryReissue() {
        // Given
        let token1 = ExtendedCBORWebToken.reissuableVaccination
        let token2 = ExtendedCBORWebToken.reissuableVaccination
        configureCustomSut(
            certificates: [
                token1,
                token2,
                .reissuableRecovery,
                .reissuableRecovery
            ]
        )

        // When
        sut.triggerVaccinationExpiryReissue()

        // Then
        wait(for: [
            router.expectationShowReissue,
            vaccinationRepo.getCertificateListExpectation,
            delegate.viewModelDidUpdateExpectation
        ], timeout: 1)
        let tokens = router.receivedReissueTokens
        XCTAssertEqual(tokens.count, 1)
    }

    func testTriggerRecoveryExpiryReissue() throws {
        // Given
        let token1 = ExtendedCBORWebToken.reissuableRecovery
        let token2 = ExtendedCBORWebToken.reissuableRecovery
        try configureCustomSut(
            certificates: [
                token1,
                token2,
                .reissuableVaccination,
                .reissuableVaccination,
                .token2Of2()
            ]
        )

        // When
        sut.triggerRecoveryExpiryReissue(index: 0)

        // Then
        wait(for: [
            router.expectationShowReissue,
            vaccinationRepo.getCertificateListExpectation,
            delegate.viewModelDidUpdateExpectation
        ], timeout: 1)
        let tokens = router.receivedReissueTokens
        XCTAssertEqual(tokens.count, 3)
    }

    func testRecoveryExpiryReissueCandidatesCount() {
        // Given
        configureCustomSut(
            certificates: [
                .reissuableRecovery,
                .reissuableRecovery,
                .reissuableVaccination
            ]
        )

        // When
        let count = sut.recoveryExpiryReissueCandidatesCount

        // Then
        XCTAssertEqual(count, 1)
    }

    func testRecoveryExpiryReissueCandidatesCount_withNonReissuable() {
        // Given
        configureCustomSut(
            certificates: [
                .reissuableRecovery,
                .reissuableRecovery,
                .reissuableVaccination,
                .nonReissuableRecovery
            ]
        )

        // When
        let count = sut.recoveryExpiryReissueCandidatesCount

        // Then
        XCTAssertEqual(count, 0)
    }

    func testRecoveryExpiryReissueCandidatesCount_count_changed_after_refresh() {
        // Given
        configureCustomSut(
            certificates: [
                .reissuableRecovery,
                .reissuableRecovery,
                .reissuableVaccination,
                .nonReissuableRecovery
            ]
        )
        vaccinationRepo.certificates = []
        sut.refreshCertsAndUpdateView()
        wait(for: [delegate.viewModelDidUpdateExpectation], timeout: 1)

        // When
        let count = sut.recoveryExpiryReissueCandidatesCount

        // Then
        XCTAssertEqual(count, 0)
    }

    func testImmunizationStatusViewModel_incomplete() throws {
        // Given
        configureCustomSut(isVaccinationCycleComplete: false, vaccinatsionCycleCompleteByRule: nil)
        // When
        let viewModel = sut.immunizationStatusViewModel
        // Then
        XCTAssertTrue(viewModel is CertificateHolderIncompleteImmunizationStatusViewModel)
        XCTAssertEqual(viewModel.title, "Incomplete vaccination protection")
        XCTAssertEqual(viewModel.subtitle, nil)
        XCTAssertEqual(viewModel.description, "You have not yet received all currently recommended vaccinations. Your vaccination protection is not yet complete. Please note that the vaccination status displayed in the app is determined in accordance with the Infection Protection Act. For children under 12 and all other persons, there are currently no restrictions under federal law that are linked to the \"fully vaccinated\" vaccination status that can be viewed in the app. Please note, on the one hand, the recommendations of the Permanent Vaccination Commission and, on the other hand, possibly deviating rules in your federal state.")
        XCTAssertEqual(viewModel.icon, .statusPartialCircle)
        XCTAssertEqual(viewModel.date, nil)
        XCTAssertEqual(viewModel.federalState, nil)
        XCTAssertEqual(viewModel.federalStateText, nil)
        XCTAssertEqual(viewModel.linkLabel, nil)
        XCTAssertEqual(viewModel.notice, nil)
        XCTAssertEqual(viewModel.noticeText, nil)
        XCTAssertEqual(viewModel.selectFederalStateButtonTitle, nil)
    }

    func testImmunizationStatusViewModel_incomplete_alternative() throws {
        // Given
        configureCustomSut(isVaccinationCycleComplete: true, vaccinatsionCycleCompleteByRule: nil)
        // When
        let viewModel = sut.immunizationStatusViewModel
        // Then
        XCTAssertTrue(viewModel is CertificateHolderIncompleteImmunizationStatusViewModel)
        XCTAssertEqual(viewModel.title, "Incomplete vaccination protection")
        XCTAssertEqual(viewModel.subtitle, nil)
        XCTAssertEqual(viewModel.description, "You have not yet received all currently recommended vaccinations. Your vaccination protection is not yet complete. Please note that the vaccination status displayed in the app is determined in accordance with the Infection Protection Act. For children under 12 and all other persons, there are currently no restrictions under federal law that are linked to the \"fully vaccinated\" vaccination status that can be viewed in the app. Please note, on the one hand, the recommendations of the Permanent Vaccination Commission and, on the other hand, possibly deviating rules in your federal state.")
        XCTAssertEqual(viewModel.icon, .statusPartialCircle)
        XCTAssertEqual(viewModel.date, nil)
        XCTAssertEqual(viewModel.federalState, nil)
        XCTAssertEqual(viewModel.federalStateText, nil)
        XCTAssertEqual(viewModel.linkLabel, nil)
        XCTAssertEqual(viewModel.notice, nil)
        XCTAssertEqual(viewModel.noticeText, nil)
        XCTAssertEqual(viewModel.selectFederalStateButtonTitle, nil)
    }

    func testImmunizationStatusViewModel_complete_E1() throws {
        // Given
        let recoveryTestDate = try XCTUnwrap(DateUtils.parseDate("2021-01-26T15:05:00"))
        let recoveryCertificate = CBORWebToken.mockRecoveryCertificate
            .recoveryTestDate(recoveryTestDate)
            .extended()
        configureCustomSut(certificates: [recoveryCertificate],
                           isVaccinationCycleComplete: true,
                           vaccinatsionCycleCompleteByRule: .impfstatusEEins)
        // When
        let viewModel = sut.immunizationStatusViewModel
        // Then
        XCTAssertTrue(viewModel is CertificateHolderImmunizationE1StatusViewModel)
        XCTAssertEqual(viewModel.title, "Incomplete vaccination protection")
        XCTAssertEqual(viewModel.subtitle, "Complete from Feb 24, 2021")
        XCTAssertEqual(viewModel.description, "This is a description ImpfstatusEEins")
        XCTAssertEqual(viewModel.icon, .statusPartialCircle)
        XCTAssertEqual(viewModel.date, "Feb 24, 2021")
        XCTAssertEqual(viewModel.federalState, nil)
        XCTAssertEqual(viewModel.federalStateText, nil)
        XCTAssertEqual(viewModel.linkLabel, nil)
        XCTAssertEqual(viewModel.notice, nil)
        XCTAssertEqual(viewModel.noticeText, nil)
        XCTAssertEqual(viewModel.selectFederalStateButtonTitle, nil)
    }

    func testImmunizationStatusViewModel_complete_B2() throws {
        // Given
        configureCustomSut(isVaccinationCycleComplete: true, vaccinatsionCycleCompleteByRule: .impfstatusBZwei)
        // When
        let viewModel = sut.immunizationStatusViewModel
        // Then
        XCTAssertTrue(viewModel is CertificateHolderCompleteVaccinationCycleStatusViewModel)
        XCTAssertEqual(viewModel.title, "Complete vaccination protection")
        XCTAssertEqual(viewModel.subtitle, nil)
        XCTAssertEqual(viewModel.description, "This is a description ImpfstatusBZwei")
        XCTAssertEqual(viewModel.icon, .statusFullCircle)
        XCTAssertEqual(viewModel.date, nil)
        XCTAssertEqual(viewModel.federalState, nil)
        XCTAssertEqual(viewModel.federalStateText, nil)
        XCTAssertEqual(viewModel.linkLabel, nil)
        XCTAssertEqual(viewModel.notice, nil)
        XCTAssertEqual(viewModel.noticeText, nil)
        XCTAssertEqual(viewModel.selectFederalStateButtonTitle, nil)
    }

    func testImmunizationStatusViewModel_complete_C2() throws {
        // Given
        configureCustomSut(isVaccinationCycleComplete: true, vaccinatsionCycleCompleteByRule: .impfstatusCZwei)
        // When
        let viewModel = sut.immunizationStatusViewModel
        // Then
        XCTAssertTrue(viewModel is CertificateHolderCompleteVaccinationCycleStatusViewModel)
        XCTAssertEqual(viewModel.title, "Complete vaccination protection")
        XCTAssertEqual(viewModel.subtitle, nil)
        XCTAssertEqual(viewModel.description, "This is a description ImpfstatusCZwei")
        XCTAssertEqual(viewModel.icon, .statusFullCircle)
        XCTAssertEqual(viewModel.date, nil)
        XCTAssertEqual(viewModel.federalState, nil)
        XCTAssertEqual(viewModel.federalStateText, nil)
        XCTAssertEqual(viewModel.linkLabel, nil)
        XCTAssertEqual(viewModel.notice, nil)
        XCTAssertEqual(viewModel.noticeText, nil)
        XCTAssertEqual(viewModel.selectFederalStateButtonTitle, nil)
    }

    func testImmunizationStatusViewModel_complete_E2() throws {
        // Given
        configureCustomSut(isVaccinationCycleComplete: true, vaccinatsionCycleCompleteByRule: .impfstatusEZwei)
        // When
        let viewModel = sut.immunizationStatusViewModel
        // Then
        XCTAssertTrue(viewModel is CertificateHolderCompleteVaccinationCycleStatusViewModel)
        XCTAssertEqual(viewModel.title, "Complete vaccination protection")
        XCTAssertEqual(viewModel.subtitle, nil)
        XCTAssertEqual(viewModel.description, "This is a description ImpfstatusEZwei")
        XCTAssertEqual(viewModel.icon, .statusFullCircle)
        XCTAssertEqual(viewModel.date, nil)
        XCTAssertEqual(viewModel.federalState, nil)
        XCTAssertEqual(viewModel.federalStateText, nil)
        XCTAssertEqual(viewModel.linkLabel, nil)
        XCTAssertEqual(viewModel.notice, nil)
        XCTAssertEqual(viewModel.noticeText, nil)
        XCTAssertEqual(viewModel.selectFederalStateButtonTitle, nil)
    }

    func testImmunizationStatusViewModel_invalid() throws {
        // Given
        var token: ExtendedCBORWebToken = try .token2Of2Mustermann()
        token.invalid = true
        configureCustomSut(certificates: [token])
        // When
        let viewModel = sut.immunizationStatusViewModel
        // Then
        XCTAssertTrue(viewModel is CertificateHolderInvalidImmunizationStatusViewModel)
        XCTAssertEqual(viewModel.title, "No valid certificate")
        XCTAssertEqual(viewModel.subtitle, nil)
        XCTAssertEqual(viewModel.description, "Add a valid certificate or renew your latest certificate to get information about your vaccination status.")
        XCTAssertEqual(viewModel.icon, .statusExpiredCircle)
        XCTAssertEqual(viewModel.date, nil)
        XCTAssertEqual(viewModel.federalState, nil)
        XCTAssertEqual(viewModel.federalStateText, nil)
        XCTAssertEqual(viewModel.linkLabel, nil)
        XCTAssertEqual(viewModel.notice, nil)
        XCTAssertEqual(viewModel.noticeText, nil)
        XCTAssertEqual(viewModel.selectFederalStateButtonTitle, nil)
    }
}

private extension ExtendedCBORWebToken {
    static var reissuableVaccination: Self {
        var token = CBORWebToken.mockVaccinationCertificate
        token.exp = Date()
        return token.extended(vaccinationQRCodeData: UUID().uuidString)
    }

    static var nonReissuableVaccination: Self {
        CBORWebToken.mockVaccinationCertificate.extended(
            vaccinationQRCodeData: UUID().uuidString
        )
    }

    static var reissuableRecovery: Self {
        var token = CBORWebToken.mockRecoveryCertificate
        token.exp = Date()
        return token.extended(vaccinationQRCodeData: UUID().uuidString)
    }

    static var nonReissuableRecovery: Self {
        CBORWebToken.mockRecoveryCertificate.extended(
            vaccinationQRCodeData: UUID().uuidString
        )
    }

    static func token1Of2SchmidtMustermann() throws -> Self {
        try token(from: """
            {"1":"DE","4":1682239131,"6":1619167131,"-260":{"1":{"nam":{"gn":"Erika","fn":"Schmidt-Mustermann","gnt":"ERIKA","fnt":"SCHMIDT<MUSTERMANN"},"dob":"1964-08-12","v":[{"ci":"01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S","co":"DE","dn":1,"dt":"2021-02-02","is":"Bundesministerium für Gesundheit","ma":"ORG-100030215","mp":"EU/1/20/1528","sd":2,"tg":"840539006","vp":"1119349007"}],"ver":"1.0.0"}}}
            """
        )
    }

    static func token2Of2Mustermann() throws -> Self {
        try token(from: """
            {"1":"DE","4":1682239131,"6":1619167131,"-260":{"1":{"nam":{"gn":"Erika","fn":"Mustermann","gnt":"ERIKA","fnt":"MUSTERMANN"},"dob":"1964-08-12","v":[{"ci":"01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S","co":"DE","dn":2,"dt":"2021-02-02","is":"Bundesministerium für Gesundheit","ma":"ORG-100030215","mp":"EU/1/20/1528","sd":2,"tg":"840539006","vp":"1119349007"}],"ver":"1.0.0"}}}
            """
        )
    }

    static func token2Of2Pérez() throws -> Self {
        try token(from: """
            {"1":"DE","4":1682239131,"6":1619167131,"-260":{"1":{"nam":{"gn":"Juan","fn":"Pérez","gnt":"JUAN","fnt":"PEREZ"},"dob":"1964-08-12","v":[{"ci":"01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S","co":"DE","dn":2,"dt":"2021-02-02","is":"Bundesministerium für Gesundheit","ma":"ORG-100030215","mp":"EU/1/20/1528","sd":2,"tg":"840539006","vp":"1119349007"}],"ver":"1.0.0"}}}
            """
        )
    }
}
