//
//  validatorOverviewViewModel+CheckImmunity.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import PromiseKit

extension ValidatorOverviewViewModel {
    func checkImmunityStatus(secondToken: ExtendedCBORWebToken? = nil, thirdToken: ExtendedCBORWebToken? = nil) {
        isLoadingScan = true
        firstly{
            ScanAndParseQRCodeAndCheckIfsg22aUseCase(router: router,
                                                     audioPlayer: audioPlayer,
                                                     vaccinationRepository: vaccinationRepository,
                                                     revocationRepository: revocationRepository,
                                                     certLogic: certLogic,
                                                     secondToken: secondToken,
                                                     thirdToken: thirdToken).execute()
        }
        .done { token in
            self.router.showVaccinationCycleComplete(token: token)
                .done(self.checkImmunityStatusResult(result:))
                .cauterize()
        }
        .ensure {
            self.isLoadingScan = false
        }
        .catch { error in
            self.errorHandlingIfsg22aCheck(error: error, token: nil)
                .done(self.checkImmunityStatusResult(result:))
                .cauterize()

        }
    }
    
    func errorHandlingIfsg22aCheck(error: Error, token: ExtendedCBORWebToken?) -> Promise<ValidatorDetailSceneResult> {
        if case let CertificateError.revoked(token) = error {
            return router.showIfsg22aCheckError(token: token)
        }
        switch error as? CheckIfsg22aUseCaseError {
        case let .showMaskCheckdifferentPersonalInformation(token1OfPerson, token2OfPerson):
            return router.showIfsg22aCheckDifferentPerson(token1OfPerson: token1OfPerson, token2OfPerson: token2OfPerson)
        case let .vaccinationCycleIsNotComplete(firstToken, secondToken, thirdToken):
            if secondToken != nil, thirdToken != nil {
                return router.showIfsg22aIncompleteResult(token: firstToken)
            } else {
                return router.showIfsg22aNotComplete(token: firstToken, secondToken: secondToken)
            }
        case .none, .invalidToken(_):
            return router.showIfsg22aCheckError(token: nil)
        case .invalidToken(token):
            return router.showIfsg22aCheckError(token: token)
        }
    }
    
    func checkImmunityStatusResult(result: ValidatorDetailSceneResult) {
        switch result {
        case .startOver:
            self.checkImmunityStatus(secondToken: nil, thirdToken: nil)
        case .close:
            break
        case let .secondScan(secondToken):
            self.checkImmunityStatus(secondToken: secondToken, thirdToken: nil)
        case let .thirdScan(secondToken, thirdToken):
            self.checkImmunityStatus(secondToken: secondToken, thirdToken: thirdToken)
        }
    }
}

private extension ExtendedCBORWebToken {
    var countOfTokens: Int {
        (vaccinationCertificate.hcert.dgc.v?.count ?? 0) +
        (vaccinationCertificate.hcert.dgc.r?.count ?? 0) +
        (vaccinationCertificate.hcert.dgc.t?.count ?? 0)
    }
}
