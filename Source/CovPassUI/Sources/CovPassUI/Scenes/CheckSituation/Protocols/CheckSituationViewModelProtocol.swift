//
//  CheckSituationViewModelProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import UIKit

public enum CheckSituationViewModelContextType {
    case settings, information
}

public protocol CheckSituationViewModelProtocol {
    var navBarTitle: String { get }
    var pageTitle: String { get }
    var newBadgeText: String { get }
    var pageImage: UIImage { get }
    var subTitleText: String { get }
    var footerText: String { get }
    var doneButtonTitle: String { get }
    var offlineRevocationTitle: String { get }
    var offlineRevocationDescription: String { get }
    var offlineRevocationDescription2: String { get }
    var offlineRevocationSwitchTitle: String { get }
    var pageTitleIsHidden: Bool { get }
    var newBadgeIconIsHidden: Bool { get }
    var pageImageIsHidden: Bool { get }
    var subTitleIsHidden: Bool { get }
    var offlineRevocationIsHidden: Bool { get }
    var offlineRevocationIsEnabled: Bool { get }
    var descriptionTextIsTop: Bool { get }
    var hStackViewIsHidden: Bool { get }
    var buttonIsHidden: Bool { get set }
    var descriptionIsHidden: Bool { get }
    var onboardingOpen: String { get }
    var onboardingClose: String { get }
    var onboardingImageDescription: String { get }
    var delegate: ViewModelDelegate? { get set }
    var context: CheckSituationViewModelContextType { get set }

    // MARK: Update related properties

    var updateContextHidden: Bool { get }
    var offlineModusButton: String { get }
    var loadingHintTitle: String { get }
    var cancelButtonTitle: String { get }
    var listTitle: String { get }
    var downloadStateHintTitle: String { get }
    var downloadStateHintIcon: UIImage { get }
    var downloadStateHintColor: UIColor { get }
    var downloadStateTextColor: UIColor { get }
    var entryRulesTitle: String { get }
    var entryRulesSubtitle: String { get }
    var domesticRulesUpdateTitle: String { get }
    var domesticRulesUpdateSubtitle: String { get }
    var valueSetsTitle: String { get }
    var valueSetsSubtitle: String { get }
    var certificateProviderTitle: String { get }
    var certificateProviderSubtitle: String { get }
    var countryListTitle: String { get }
    var countryListSubtitle: String { get }
    var authorityListTitle: String { get }
    var authorityListSubtitle: String { get }
    var isLoading: Bool { get }

    // MARK: Check Situation related properties

    var checkSituationTitle: String { get }
    var checkSituationSubtitle: String { get }
    var checkSituationWithinGermanyTitle: String { get }
    var checkSituationWithinGermanySubtitle: String { get }
    var checkSituationWithinGermanyImage: UIImage { get }
    var checkSituationEnteringGermanyTitle: String { get }
    var checkSituationEnteringGermanySubtitle: String { get }
    var checkSituationEnteringGermanyImage: UIImage { get }
    var checkSituationWithinGermanyOptionAccessibiliyLabel: String { get }
    var checkSituationEnteringGermanyOptionAccessibiliyLabel: String { get }
    var checkSituationIsHidden: Bool { get }

    func withinGermanyIsChoosen()
    func enteringGermanyViewIsChoosen()
    func doneIsTapped()
    func toggleOfflineRevocation()
    func refresh()
    func cancel()
}
