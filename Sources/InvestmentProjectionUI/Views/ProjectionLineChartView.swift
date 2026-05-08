import InvestmentProjectionCore
import UIKit

final class ProjectionLineChartView: UIView {
    var theme: InvestmentProjectionTheme = .default {
        didSet {
            setNeedsDisplay()
        }
    }

    var points: [ProjectionYearPoint] = [] {
        didSet {
            setNeedsDisplay()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
        isOpaque = false
    }

    override func draw(_ rect: CGRect) {
        guard points.count > 1, let context = UIGraphicsGetCurrentContext() else {
            return
        }

        let chartRect = rect.insetBy(dx: 12, dy: 16)
        let balances = points.map(\.balance)
        let maxBalance = balances.max() ?? 0

        guard maxBalance > 0 else {
            return
        }

        let resolvedPoints = points.enumerated().map { index, point in
            let xRatio = CGFloat(index) / CGFloat(points.count - 1)
            let yRatio = CGFloat(NSDecimalNumber(decimal: point.balance / maxBalance).doubleValue)
            return CGPoint(
                x: chartRect.minX + chartRect.width * xRatio,
                y: chartRect.maxY - chartRect.height * yRatio
            )
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
    }
}
