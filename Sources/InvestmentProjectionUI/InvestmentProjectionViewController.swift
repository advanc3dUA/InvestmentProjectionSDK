import InvestmentProjectionCore
import Foundation
import UIKit

public final class InvestmentProjectionViewController: UIViewController, UIGestureRecognizerDelegate {
    private let theme: InvestmentProjectionTheme
    private let localization: ProjectionLocalization
    private let viewModel: InvestmentProjectionViewModel
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private lazy var inputFormView = ProjectionInputFormView(theme: theme, localization: localization)
    private lazy var resultSummaryView = ProjectionResultSummaryView(theme: theme, localization: localization)

    public init(
        initialInput: ProjectionInput? = nil,
        configuration: ProjectionConfiguration = .default,
        theme: InvestmentProjectionTheme = .default,
        locale: Locale = .current,
        currencyCode: String = "EUR",
        calculator: ProjectionCalculator = ProjectionCalculator()
    ) {
        self.theme = theme
        self.localization = ProjectionLocalization(locale: locale, currencyCode: currencyCode)
        self.viewModel = InvestmentProjectionViewModel(
            initialInput: initialInput,
            configuration: configuration,
            calculator: calculator,
            localization: self.localization
        )
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.theme = .default
        self.localization = ProjectionLocalization(locale: .current)
        self.viewModel = InvestmentProjectionViewModel(
            initialInput: nil,
            configuration: .default,
            calculator: ProjectionCalculator(),
            localization: self.localization
        )
        super.init(coder: coder)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        title = localization.navigationTitle
        configureLayout()
        configureKeyboardDismissal()
        configureTraitChanges()
        bindViews()
        applyAppearance()
        render(viewModel.initialState())
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyAppearance()
    }

    private func configureLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = theme.contentSpacing
        contentStack.layoutMargins = theme.contentInsets
        contentStack.isLayoutMarginsRelativeArrangement = true

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        contentStack.addArrangedSubview(makeHeaderView())
        contentStack.addArrangedSubview(inputFormView)
        contentStack.addArrangedSubview(resultSummaryView)
    }

    private func bindViews() {
        inputFormView.onChange = { [weak self] formInput in
            guard let self else {
                return
            }

            render(viewModel.state(for: formInput))
        }
    }

    private func render(_ state: InvestmentProjectionViewState) {
        inputFormView.apply(state)
        resultSummaryView.apply(state.result)
    }

    private func makeHeaderView() -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical

        let titleLabel = UILabel()
        titleLabel.text = localization.headlineTitle
        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = theme.primaryTextColor
        titleLabel.numberOfLines = 0

        stack.addArrangedSubview(titleLabel)
        return stack
    }

    private func configureKeyboardDismissal() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.delegate = self
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    private func configureTraitChanges() {
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, _) in
            self.applyAppearance()
        }
    }

    private func applyAppearance() {
        view.backgroundColor = theme.backgroundColor
        configureNavigationBar()
        inputFormView.updateAppearance()
        resultSummaryView.updateAppearance()
    }

    private func configureNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar else {
            return
        }

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = theme.backgroundColor
        appearance.titleTextAttributes = [.foregroundColor: theme.primaryTextColor]
        appearance.largeTitleTextAttributes = [.foregroundColor: theme.primaryTextColor]

        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.tintColor = theme.accentColor
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        !touch.isInsideControl
    }
}

private extension UITouch {
    var isInsideControl: Bool {
        var currentView = view

        while let inspectedView = currentView {
            if inspectedView is UIControl {
                return true
            }

            currentView = inspectedView.superview
        }

        return false
    }
}
