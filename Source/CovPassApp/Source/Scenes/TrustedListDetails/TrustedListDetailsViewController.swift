//
//  TrustedListDetailsViewController.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import Foundation
import Scanner
import UIKit

class TrustedListDetailsViewController: UIViewController {
    // MARK: - IBOutlet

    @IBOutlet var headerView: PlainLabel!
    @IBOutlet var bodyTitleLabel: PlainLabel!
    @IBOutlet var downloadStateHintLabel: PlainLabel!
    @IBOutlet var downloadStateIconImageView: UIImageView!
    @IBOutlet var downloadStateWrapper: UIView!
    @IBOutlet var entryRulesContainer: UIView!
    @IBOutlet var entryRulesTitleLabel: PlainLabel!
    @IBOutlet var entryRulesSubtitleLabel: PlainLabel!
    @IBOutlet var domesticRulesContainer: UIView!
    @IBOutlet var domesticRulesTitleLabel: PlainLabel!
    @IBOutlet var domesticRulesSubtitleLabel: PlainLabel!
    @IBOutlet var valueSetsContainer: UIView!
    @IBOutlet var valueSetsTitleLabel: PlainLabel!
    @IBOutlet var valueSetsSubtitleLabel: PlainLabel!
    @IBOutlet var certificateProviderContainer: UIView!
    @IBOutlet var certificateProviderTitleLabel: PlainLabel!
    @IBOutlet var certificateProviderSubtitleLabel: PlainLabel!
    @IBOutlet var countryListContainer: UIView!
    @IBOutlet var countryListTitleLabel: PlainLabel!
    @IBOutlet var countryListSubtitleLabel: PlainLabel!
    @IBOutlet var cancelButton: MainButton!
    @IBOutlet var downloadingHintLabel: PlainLabel!
    @IBOutlet var activityIndicatorWrapper: UIView!
    @IBOutlet public var mainButton: MainButton!
    private let activityIndicator = DotPulseActivityIndicator(frame: CGRect(x: 0, y: 0, width: 100, height: 20))

    // MARK: - Properties

    private(set) var viewModel: TrustedListDetailsViewModel

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    public init(viewModel: TrustedListDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .main)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        view.backgroundColor = .backgroundPrimary
        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIAccessibility.post(notification: .layoutChanged, argument: viewModel.accessibilityAnnounce)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIAccessibility.post(notification: .layoutChanged, argument: viewModel.accessibilityClose)
    }

    // MARK: - Private Methods

    private func setupTitle() {
        if navigationController?.navigationBar.backItem != nil {
            title = viewModel.title
            return
        }
        let label = UILabel()
        label.attributedText = viewModel.title.styledAs(.header_3)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: label)
    }

    private func setupButtonActions() {
        mainButton.action = viewModel.refresh
        cancelButton.action = viewModel.cancel
    }

    private func setupStaticTexts() {
        headerView.attributedText = viewModel.oflineModusDescription.styledAs(.body)
        mainButton.title = viewModel.offlineModusButton
        mainButton.style = .primary
        cancelButton.title = viewModel.cancelButtonTitle
        cancelButton.style = .plain
        entryRulesTitleLabel.attributedText = viewModel.entryRulesTitle.styledAs(.header_3)
        domesticRulesTitleLabel.attributedText = viewModel.domesticRulesTitle.styledAs(.header_3)
        valueSetsTitleLabel.attributedText = viewModel.valueSetsTitle.styledAs(.header_3)
        certificateProviderTitleLabel.attributedText = viewModel.certificateProviderTitle.styledAs(.header_3)
        countryListTitleLabel.attributedText = viewModel.countryListTitle.styledAs(.header_3)
        downloadingHintLabel.attributedText = viewModel.loadingHintTitle.styledAs(.header_3).colored(.gray)
        bodyTitleLabel.attributedText = viewModel.listTitle.styledAs(.header_2)
        bodyTitleLabel.accessibilityTraits = .header
    }

    private func setupView() {
        setupTitle()
        setupActivityIndicator()
        setupButtonActions()
        updateView()
        setupStaticTexts()
        downloadStateWrapper.layer.cornerRadius = 12.0

        let backButton = UIBarButtonItem(image: .arrowBack, style: .done, target: self, action: #selector(backButtonTapped))
        backButton.accessibilityLabel = "accessibility_app_information_contact_label_back".localized // TODO: change accessibility text when they are available
        navigationItem.leftBarButtonItem = backButton
        navigationController?.navigationBar.tintColor = .onBackground100
    }

    private func updateLoadingView(isLoading: Bool) {
        mainButton?.isHidden = isLoading
        downloadingHintLabel.isHidden = !isLoading
        cancelButton.isHidden = !isLoading
        isLoading ? UIAccessibility.post(notification: .layoutChanged, argument: downloadingHintLabel) :
            UIAccessibility.post(notification: .layoutChanged, argument: downloadStateHintLabel)
        isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }

    private func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorWrapper.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorWrapper.addSubview(activityIndicator)
        activityIndicator.topAnchor.constraint(equalTo: activityIndicatorWrapper.topAnchor, constant: 40).isActive = true
        activityIndicator.bottomAnchor.constraint(equalTo: activityIndicatorWrapper.bottomAnchor, constant: -40.0).isActive = true
        activityIndicator.leftAnchor.constraint(equalTo: activityIndicatorWrapper.leftAnchor, constant: 40.0).isActive = true
        activityIndicator.rightAnchor.constraint(equalTo: activityIndicatorWrapper.rightAnchor, constant: -40.0).isActive = true
    }

    private func updateView() {
        updateLoadingView(isLoading: viewModel.isLoading)
        downloadStateHintLabel.attributedText = viewModel.downloadStateHintTitle.styledAs(.label).colored(viewModel.downloadStateTextColor)
        downloadStateIconImageView.image = viewModel.downloadStateHintIcon
        downloadStateWrapper.backgroundColor = viewModel.downloadStateHintColor
        entryRulesSubtitleLabel.attributedText = viewModel.entryRulesSubtitle.styledAs(.body)
        domesticRulesSubtitleLabel.attributedText = viewModel.domesticRulesSubtitle.styledAs(.body)
        valueSetsSubtitleLabel.attributedText = viewModel.valueSetsSubtitle.styledAs(.body)
        certificateProviderSubtitleLabel.attributedText = viewModel.certificateProviderSubtitle.styledAs(.body)
        countryListSubtitleLabel.attributedText = viewModel.countryListSubtitle.styledAs(.body)

        configureAccessibility()
    }

    private func configureAccessibility() {
        domesticRulesContainer.enableAccessibility(label: viewModel.domesticRulesTitle,
                                                   value: viewModel.entryRulesSubtitle,
                                                   traits: .staticText)
        entryRulesContainer.enableAccessibility(label: viewModel.entryRulesTitle,
                                                value: viewModel.entryRulesSubtitle,
                                                traits: .staticText)
        valueSetsContainer.enableAccessibility(label: viewModel.valueSetsTitle,
                                               value: viewModel.valueSetsSubtitle,
                                               traits: .staticText)
        certificateProviderContainer.enableAccessibility(label: viewModel.certificateProviderTitle,
                                                         value: viewModel.certificateProviderSubtitle,
                                                         traits: .staticText)
        countryListContainer.enableAccessibility(label: viewModel.countryListTitle,
                                                 value: viewModel.countryListSubtitle,
                                                 traits: .staticText)

        if #available(iOS 13.0, *) {
            headerView.accessibilityRespondsToUserInteraction = true
            entryRulesContainer.accessibilityRespondsToUserInteraction = true
            domesticRulesContainer.accessibilityRespondsToUserInteraction = true
            valueSetsContainer.accessibilityRespondsToUserInteraction = true
            certificateProviderContainer.accessibilityRespondsToUserInteraction = true
            countryListContainer.accessibilityRespondsToUserInteraction = true
        }
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension TrustedListDetailsViewController: ViewModelDelegate {
    public func viewModelDidUpdate() {
        updateView()
    }

    public func viewModelUpdateDidFailWithError(_: Error) {}
}
