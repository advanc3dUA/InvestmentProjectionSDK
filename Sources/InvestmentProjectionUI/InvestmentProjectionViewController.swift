import InvestmentProjectionCore
import UIKit

public final class InvestmentProjectionViewController: UIViewController {
    private let theme: InvestmentProjectionTheme
    private let viewModel: InvestmentProjectionViewModel
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private lazy var inputFormView = ProjectionInputFormView(theme: theme)
    private lazy var resultSummaryView = ProjectionResultSummaryView(theme: theme)

    public init(
        initialInput: ProjectionInput? = nil,
        configuration: ProjectionConfiguration = .default,
        theme: InvestmentProjectionTheme = .default,
        calculator: ProjectionCalculator = ProjectionCalculator()
    ) {
        self.theme = theme
        self.viewModel = InvestmentProjectionViewModel(
            initialInput: initialInput,
            configuration: configuration,
            calculator: calculator
        )
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.theme = .default
        self.viewModel = InvestmentProjectionViewModel(
            initialInput: nil,
            configuration: .default,
            calculator: ProjectionCalculator()
        )
        super.init(coder: coder)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        title = "Projection"
        view.backgroundColor = theme.backgroundColor
        configureLayout()
        bindViews()
        render(viewModel.initialState())
    }

    private func configureLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.layoutMargins = UIEdgeInsets(top: 24, left: 20, bottom: 32, right: 20)
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
        stack.spacing = 8

        let titleLabel = UILabel()
        titleLabel.text = "Investment projection"
        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = theme.primaryTextColor
        titleLabel.numberOfLines = 0

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Scenario planning"
        subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        subtitleLabel.textColor = theme.secondaryTextColor

        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(subtitleLabel)
        return stack
    }
}
