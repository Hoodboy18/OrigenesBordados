//
//  TalaveraPatternView.swift
//  Origenes Bordados
//
//  Mosaico de azulejos tipo talavera dibujado con Core Graphics.
//  Se usa desde los XIB con la clase TalaveraPatternView y la propiedad
//  "presetName" (welcome, login, signUp, personalInfo, loader).
//

import UIKit

final class TalaveraPatternView: UIView {

    // MARK: - Colores de los azulejos
    enum Hue {
        case green, red, pink, blue, cream, gold

        var color: UIColor {
            switch self {
            case .green: return UIColor(named: "talaveraGreen") ?? .systemGreen
            case .red: return UIColor(named: "talaveraRed") ?? .systemRed
            case .pink: return UIColor(named: "talaveraPink") ?? .systemPink
            case .blue: return UIColor(named: "talaveraBlue") ?? .systemBlue
            case .cream: return UIColor(named: "secondaryBackground") ?? .secondarySystemBackground
            case .gold: return UIColor(named: "talaveraGold") ?? .systemOrange
            }
        }
    }

    // MARK: - Motivos
    enum Motif {
        /// Flor de ocho pétalos con medallones en las esquinas.
        case flower8
        /// Flor de cuatro pétalos con hojas en diagonal.
        case flower4
        /// Roseta con anillo y pétalos pequeños.
        case rosette
        /// Hojas en diagonal con rombo al centro.
        case leaves
    }

    struct Tile {
        let motif: Motif
        let a: Hue
        let b: Hue
        let c: Hue
    }

    // MARK: - Mosaicos predefinidos (mismos que el lienzo de diseño)
    enum Preset: String {
        case welcome, login, signUp, personalInfo, loader

        var columns: Int {
            switch self {
            case .welcome: return 4
            case .loader: return 5
            default: return 7
            }
        }

        var tiles: [Tile] {
            switch self {
            case .welcome:
                return [
                    Tile(motif: .flower8, a: .blue, b: .gold, c: .green),
                    Tile(motif: .flower4, a: .pink, b: .green, c: .gold),
                    Tile(motif: .rosette, a: .blue, b: .gold, c: .red),
                    Tile(motif: .leaves, a: .green, b: .pink, c: .gold),
                    Tile(motif: .leaves, a: .red, b: .gold, c: .blue),
                    Tile(motif: .rosette, a: .green, b: .pink, c: .gold),
                    Tile(motif: .flower8, a: .pink, b: .gold, c: .blue),
                    Tile(motif: .flower4, a: .blue, b: .gold, c: .green),
                    Tile(motif: .flower4, a: .green, b: .gold, c: .pink),
                    Tile(motif: .flower8, a: .gold, b: .red, c: .green),
                    Tile(motif: .leaves, a: .blue, b: .pink, c: .gold),
                    Tile(motif: .rosette, a: .pink, b: .gold, c: .green)
                ]
            case .login:
                return [
                    Tile(motif: .flower8, a: .blue, b: .gold, c: .green),
                    Tile(motif: .flower4, a: .pink, b: .green, c: .gold),
                    Tile(motif: .rosette, a: .green, b: .gold, c: .blue),
                    Tile(motif: .leaves, a: .red, b: .gold, c: .blue),
                    Tile(motif: .flower8, a: .pink, b: .gold, c: .green),
                    Tile(motif: .flower4, a: .blue, b: .gold, c: .pink),
                    Tile(motif: .rosette, a: .green, b: .pink, c: .gold)
                ]
            case .signUp:
                return [
                    Tile(motif: .flower4, a: .green, b: .gold, c: .pink),
                    Tile(motif: .rosette, a: .pink, b: .gold, c: .blue),
                    Tile(motif: .leaves, a: .blue, b: .pink, c: .gold),
                    Tile(motif: .flower8, a: .gold, b: .red, c: .green),
                    Tile(motif: .flower4, a: .pink, b: .green, c: .blue),
                    Tile(motif: .rosette, a: .blue, b: .gold, c: .green),
                    Tile(motif: .leaves, a: .green, b: .gold, c: .pink)
                ]
            case .personalInfo:
                return [
                    Tile(motif: .rosette, a: .blue, b: .gold, c: .pink),
                    Tile(motif: .leaves, a: .green, b: .pink, c: .gold),
                    Tile(motif: .flower8, a: .pink, b: .gold, c: .blue),
                    Tile(motif: .flower4, a: .blue, b: .gold, c: .green),
                    Tile(motif: .rosette, a: .green, b: .gold, c: .red),
                    Tile(motif: .leaves, a: .pink, b: .gold, c: .blue),
                    Tile(motif: .flower8, a: .blue, b: .gold, c: .green)
                ]
            case .loader:
                return [
                    Tile(motif: .flower8, a: .blue, b: .gold, c: .green),
                    Tile(motif: .flower4, a: .pink, b: .green, c: .gold),
                    Tile(motif: .rosette, a: .green, b: .gold, c: .blue),
                    Tile(motif: .leaves, a: .red, b: .gold, c: .blue),
                    Tile(motif: .flower8, a: .pink, b: .gold, c: .green)
                ]
            }
        }
    }

    // MARK: - Propiedades configurables desde el XIB
    @IBInspectable var presetName: String = Preset.login.rawValue {
        didSet { setNeedsDisplay() }
    }

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.cornerCurve = .continuous
            layer.masksToBounds = cornerRadius > 0
        }
    }

    /// Separación entre azulejos (se pinta con el color de línea).
    private let gap: CGFloat = 2

    private var preset: Preset { Preset(rawValue: presetName) ?? .login }

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        contentMode = .redraw
        isOpaque = false
        isAccessibilityElement = false // Es decorativo
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            setNeedsDisplay()
        }
    }

    // MARK: - Dibujo
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let tiles = preset.tiles
        let columns = preset.columns
        let rows = Int(ceil(Double(tiles.count) / Double(columns)))
        guard columns > 0, rows > 0 else { return }

        (UIColor(named: "divider") ?? .separator).setFill()
        context.fill(bounds)

        let tileWidth = (bounds.width - gap * CGFloat(columns - 1)) / CGFloat(columns)
        let tileHeight = (bounds.height - gap * CGFloat(rows - 1)) / CGFloat(rows)

        for (index, tile) in tiles.enumerated() {
            let column = index % columns
            let row = index / columns
            let cell = CGRect(x: CGFloat(column) * (tileWidth + gap),
                              y: CGFloat(row) * (tileHeight + gap),
                              width: tileWidth,
                              height: tileHeight)
            draw(tile, in: cell, context: context)
        }
    }

    /// Dibuja un azulejo en coordenadas de 0 a 100, centrado en la celda.
    private func draw(_ tile: Tile, in cell: CGRect, context: CGContext) {
        context.saveGState()
        context.clip(to: cell)
        Hue.cream.color.setFill()
        context.fill(cell)

        let side = min(cell.width, cell.height)
        let scale = side / 100
        context.translateBy(x: cell.midX - side / 2, y: cell.midY - side / 2)
        context.scaleBy(x: scale, y: scale)

        switch tile.motif {
        case .flower8: drawFlower8(tile)
        case .flower4: drawFlower4(tile)
        case .rosette: drawRosette(tile)
        case .leaves: drawLeaves(tile)
        }
        context.restoreGState()
    }

    // MARK: Motivos (coordenadas de un azulejo de 100 × 100)
    private func drawFlower8(_ tile: Tile) {
        fillCorners(radius: 21, hue: tile.c)
        for angle in stride(from: 0, to: 360, by: 45) {
            fill(ellipse(cx: 50, cy: 27, rx: 8.5, ry: 16), rotatedBy: angle, hue: tile.a)
        }
        fill(circle(cx: 50, cy: 50, r: 9), hue: tile.b)
    }

    private func drawFlower4(_ tile: Tile) {
        for angle in [45, 135, 225, 315] {
            fill(ellipse(cx: 50, cy: 24, rx: 5, ry: 15), rotatedBy: angle, hue: tile.b)
        }
        for angle in [0, 90, 180, 270] {
            let petal = UIBezierPath()
            petal.move(to: CGPoint(x: 50, y: 50))
            petal.addCurve(to: CGPoint(x: 50, y: 6),
                           controlPoint1: CGPoint(x: 31, y: 36),
                           controlPoint2: CGPoint(x: 34, y: 13))
            petal.addCurve(to: CGPoint(x: 50, y: 50),
                           controlPoint1: CGPoint(x: 66, y: 13),
                           controlPoint2: CGPoint(x: 69, y: 36))
            petal.close()
            fill(petal, rotatedBy: angle, hue: tile.a)
        }
        fill(circle(cx: 50, cy: 50, r: 7.5), hue: tile.c)
        fillCorners(radius: 7, hue: tile.c)
    }

    private func drawRosette(_ tile: Tile) {
        fillCorners(radius: 24, hue: tile.c)
        fillCorners(radius: 13, hue: .cream)
        fill(circle(cx: 50, cy: 50, r: 31), hue: tile.a)
        fill(circle(cx: 50, cy: 50, r: 21), hue: .cream)
        for angle in stride(from: 0, to: 360, by: 60) {
            fill(ellipse(cx: 50, cy: 38, rx: 5.5, ry: 10), rotatedBy: angle, hue: tile.b)
        }
        fill(circle(cx: 50, cy: 50, r: 5), hue: tile.a)
    }

    private func drawLeaves(_ tile: Tile) {
        for angle in [45, 135, 225, 315] {
            fill(ellipse(cx: 50, cy: 25, rx: 10, ry: 22), rotatedBy: angle, hue: tile.a)
        }
        for angle in [0, 90, 180, 270] {
            fill(circle(cx: 50, cy: 11, r: 6.5), rotatedBy: angle, hue: tile.b)
        }
        let diamond = UIBezierPath(rect: CGRect(x: 42, y: 42, width: 16, height: 16))
        fill(diamond, rotatedBy: 45, hue: tile.c)
    }

    // MARK: Utilidades de dibujo
    private func circle(cx: CGFloat, cy: CGFloat, r: CGFloat) -> UIBezierPath {
        UIBezierPath(ovalIn: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
    }

    private func ellipse(cx: CGFloat, cy: CGFloat, rx: CGFloat, ry: CGFloat) -> UIBezierPath {
        UIBezierPath(ovalIn: CGRect(x: cx - rx, y: cy - ry, width: rx * 2, height: ry * 2))
    }

    private func fillCorners(radius: CGFloat, hue: Hue) {
        for corner in [CGPoint(x: 0, y: 0), CGPoint(x: 100, y: 0),
                       CGPoint(x: 0, y: 100), CGPoint(x: 100, y: 100)] {
            fill(circle(cx: corner.x, cy: corner.y, r: radius), hue: hue)
        }
    }

    private func fill(_ path: UIBezierPath, rotatedBy degrees: Int = 0, hue: Hue) {
        if degrees != 0 {
            let radians = CGFloat(degrees) * .pi / 180
            var transform = CGAffineTransform(translationX: 50, y: 50)
            transform = transform.rotated(by: radians)
            transform = transform.translatedBy(x: -50, y: -50)
            path.apply(transform)
        }
        hue.color.setFill()
        path.fill()
    }
}
