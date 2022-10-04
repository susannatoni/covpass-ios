//
//  ValidationUseCase.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import PromiseKit
import Foundation
import CertLogic

enum ValidateCertificateUseCaseError: Error, Equatable  {
    case maskRulesNotAvailable(_ token: ExtendedCBORWebToken)
    case holderNeedsMask(_ token: ExtendedCBORWebToken)
    case invalidDueToRules(_ token: ExtendedCBORWebToken)
    case invalidDueToTechnicalReason(_ token: ExtendedCBORWebToken)
}

struct ValidateCertificateUseCase {
    let token: ExtendedCBORWebToken
    let region: String?
    let revocationRepository: CertificateRevocationRepositoryProtocol
    public let holderStatus: CertificateHolderStatusModelProtocol
    
    func execute() -> Promise<ExtendedCBORWebToken> {
        return firstly {
            checkMaskRulesAvailable()
        }
        .then {
            isRevoked(token)
        }
        .then {
            checkDomesticRules()
        }
        .then {
            checkEuRules()
        }
        .then {
            checkMaskRules()
        }
        .then {
            Promise.value(token)
        }
    }
    
    private func checkMaskRulesAvailable() -> Promise<Void> {
        guard holderStatus.maskRulesAvailable(for: region) else {
            return .init(error: ValidateCertificateUseCaseError.maskRulesNotAvailable(token))
        }
        return .value
    }
    
    private func checkMaskRules() -> Promise<Void> {
        if holderStatus.holderNeedsMask([token], region: region) {
            return .init(error: ValidateCertificateUseCaseError.holderNeedsMask(token))
        }
        return .value
    }

    private func isRevoked(_ token: ExtendedCBORWebToken) -> Promise<Void> {
        firstly {
            revocationRepository.isRevoked(token)
        }
        .then { isRevoked -> Promise<Void> in
            if isRevoked {
                return .init(error: CertificateError.revoked(token))
            }
            return .value
        }
    }
    
    private func checkDomesticRules() -> Promise<Void> {
        switch holderStatus.checkDomesticAcceptanceAndInvalidationRules([token]) {
        case .passed:
            return .value
        case .failedTechnical:
            return .init(error: ValidateCertificateUseCaseError.invalidDueToTechnicalReason(token))
        case .failedFunctional:
            return .init(error: ValidateCertificateUseCaseError.invalidDueToRules(token))
        }
    }
    
    private func checkEuRules() -> Promise<Void> {
        switch holderStatus.checkEuInvalidationRules([token]) {
        case .passed:
            return .value
        case .failedTechnical:
            return .init(error: ValidateCertificateUseCaseError.invalidDueToTechnicalReason(token))
        case .failedFunctional:
            return .init(error: ValidateCertificateUseCaseError.invalidDueToRules(token))
        }
    }
}
