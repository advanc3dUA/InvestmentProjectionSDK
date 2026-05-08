import InvestmentProjectionCore
import UIKit

final class ProjectionLineChartView: UIView {
    var onSelectionChanged: ((ProjectionYearPoint) -> Void)?
    var onScrubbingEnded: (() -> Void)?

    var theme: InvestmentProjectionTheme = .default {
        didSet {
            setNeedsDisplay()
        }
    }

    var points: [ProjectionYearPoint] = [] {
        didSet {
            setSelectedIndex(points.isEmpty ? nil : points.count - 1, emitsFeedback: false)
            setNeedsDisplay()
        }
    }

    private var selectedIndex: Int? {
        didSet {
            guard selectedIndex != oldValue else {
                return
            }

            if oldValue != nil, shouldEmitFeedback {
                feedbackGenerator.selectionChanged()
            }

            notifySelectionChanged()
            setNeedsDisplay()
            shouldEmitFeedback = true
        }
    }

    private let feedbackGenerator = UISelectionFeedbackGenerator()
    private var shouldEmitFeedback = true

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
        configureGestures()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
        isOpaque = false
        configureGestures()
    }

    override func draw(_ rect: CGRect) {
        guard points.count > 1, let context = UIGraphicsGetCurrentContext() else {
            return
        }

        let chartRect = chartDrawingRect(in: rect)
        let resolvedPoints = resolvedPoints(in: chartRect)

        guard resolvedPoints.count == points.count else {
            return
        }

        let linePath = UIBezierPath()
        linePath.move(to: resolvedPoints[0])
        resolvedPoints.dropFirst().forEach { linePath.addLine(to: $0) }

        let fillPath = linePath.copy() as! UIBezierPath
        fillPath.addLine(to: CGPoint(x: resolvedPoints.last?.x ?? chartRect.maxX, y: chartRect.maxY))
        fillPath.addLine(to: CGPoint(x: resolvedPoints[0].x, y: chartRect.maxY))
        fillPath.close()

        context.saveGState()
        fillPath.addClip()

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colors = [
            theme.accentColor.withAlphaComponent(0.24).cgColor,
            theme.accentColor.withAlphaComponent(0.02).cgColor
        ] as CFArray
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0, 1])
        if let gradient {
            context.drawLinearGradient(
                gradient,
                start: CGPoint(x: chartRect.midX, y: chartRect.minY),
                end: CGPoint(x: chartRect.midX, y: chartRect.maxY),
                options: []
            )
        }
        context.restoreGState()

        theme.accentColor.setStroke()
        linePath.lineWidth = 3
        linePath.lineCapStyle = .round
        linePath.lineJoinStyle = .round
        linePath.stroke()

        for (index, point) in resolvedPoints.enumerated() {
            let isSelected = index == selectedIndex
            let radius: CGFloat = isSelected ? 6 : 3
            let circleRect = CGRect(
                x: point.x - radius,
                y: point.y - radius,
                width: radius * 2,
                height: radius * 2
            )

            let circlePath = UIBezierPath(ovalIn: circleRect)
            let fillColor = isSelected
                ? theme.accentColor
                : theme.accentColor.withAlphaComponent(0.7)
            fillColor.setFill()
            circlePath.fill()

            if isSelected {
                theme.surfaceColor.setStroke()
                circlePath.lineWidth = 2
                circlePath.stroke()
            }
        }
    }

    private func configureGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGesture)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
    }

    private func chartDrawingRect(in rect: CGRect) -> CGRect {
        rect.insetBy(dx: 12, dy: 16)
    }

    private func resolvedPoints(in chartRect: CGRect) -> [CGPoint] {
        let balances = points.map(\.balance)
        let maxBalance = balances.max() ?? 0

        guard maxBalance > 0, points.count > 1 else {
            return []
        }

        return points.enumerated().map { index, point in
            let xRatio = CGFloat(index) / CGFloat(points.count - 1)
            let yRatio = CGFloat(NSDecimalNumber(decimal: point.balance / maxBalance).doubleValue)
            return CGPoint(
                x: chartRect.minX + chartRect.width * xRatio,
                y: chartRect.maxY - chartRect.height * yRatio
            )
        }
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        updateSelectedPoint(for: gesture.location(in: self))
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            feedbackGenerator.prepare()
            updateSelectedPoint(for: gesture.location(in: self))
        case .changed:
            updateSelectedPoint(for: gesture.location(in: self))
        case .ended, .cancelled, .failed:
            feedbackGenerator.prepare()
            onScrubbingEnded?()
            setSelectedIndex(points.isEmpty ? nil : points.count - 1, emitsFeedback: false)
        default:
            break
        }
    }

    private func updateSelectedPoint(for location: CGPoint) {
        let resolvedPoints = resolvedPoints(in: chartDrawingRect(in: bounds))
        guard !resolvedPoints.isEmpty else {
            return
        }

        let nearestIndex = resolvedPoints.enumerated().min { lhs, rhs in
            abs(lhs.element.x - location.x) < abs(rhs.element.x - location.x)
        }?.offset

        setSelectedIndex(nearestIndex, emitsFeedback: true)
    }

    private func notifySelectionChanged() {
        guard let selectedIndex, points.indices.contains(selectedIndex) else {
            return
        }

        onSelectionChanged?(points[selectedIndex])
    }

    private func setSelectedIndex(_ newValue: Int?, emitsFeedback: Bool) {
        shouldEmitFeedback = emitsFeedback
        selectedIndex = newValue
    }
}
