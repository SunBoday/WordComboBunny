//
//  GameScene.swift
//  WordComboBunny
//
//  Created by SunTory2025 on 2025/10/28.
//

import SpriteKit
import UIKit
import QuartzCore

final class GameScene: SKScene {

    // MARK: - Grid / Layout
    private let rows = 6
    private let cols = 6

    private var TILE_SIZE: CGFloat = 60
    private var TILE_SPACING: CGFloat = 8

    private var safeAreaTop: CGFloat = 0
    private var safeAreaBottom: CGFloat = 0

    private var gridOrigin: CGPoint = .zero
    private var gridSize: CGSize = .zero

    // MARK: - Game state
    private var gameBoard: GameBoard!
     var gameState: GameState!
    private var gameMode: GameMode!
    private var firstTouchedTile: Tile?

    // Locks & motion tracking
    private var inputLocked = false { didSet { refreshButtons() } }
    private var movingCounter = 0 { didSet { refreshButtons() } }
    private var lastMovementTimestamp: TimeInterval = 0

    // Queue “press while busy”
    private var queuedHintRequest = false
    private var queuedShuffleRequest = false

    // MARK: - UI callbacks
    var onScoreUpdate: ((Int) -> Void)?
    var onMovesUpdate: ((Int) -> Void)?
    var onGameOver: ((Bool, Int, String) -> Void)?
    var onShuffleEnabledChanged: ((Bool) -> Void)?
    var onHintEnabledChanged: ((Bool) -> Void)?

    // MARK: - HUD (no overlap, auto-fit)
    private let hudLayer = SKNode()
    private struct HUDMessage { let text: String; let baseSize: CGFloat; let color: UIColor; let dur: TimeInterval }
    private var hudQueue: [HUDMessage] = []
    private var hudShowing = false

    // MARK: - Lifecycle
    override func didMove(to view: SKView) {
        if let window = view.window {
            safeAreaTop = window.safeAreaInsets.top
            safeAreaBottom = window.safeAreaInsets.bottom
        }
        calculateTileSize()
        setupBackground()

        hudLayer.zPosition = 1000
        addChild(hudLayer)

        refreshButtons()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        calculateTileSize()
        for r in 0..<rows {
            for c in 0..<cols {
                gameBoard?.getTile(row: r, col: c)?.sprite?.position = getPosition(row: r, col: c)
            }
        }
    }

    // Watchdog: if locked but nothing moves for a moment, release
    override func update(_ currentTime: TimeInterval) {
        if movingCounter == 0 && (currentTime - lastMovementTimestamp) > 0.25 {
            if inputLocked { inputLocked = false }
        }
        // Run any queued button press now that we're idle
        if movingCounter == 0 && !inputLocked {
            if queuedShuffleRequest { queuedShuffleRequest = false; shuffleBoard() }
            else if queuedHintRequest { queuedHintRequest = false; showHint() }
        }
        refreshButtons()
    }

    // MARK: - Public
    func initializeGame(mode: GameMode) {
        gameMode = mode
        gameBoard = GameBoard(rows: rows, cols: cols)

        switch mode {
        case .level(let level):
            gameState = GameState(level: level)
        case .endless:
            let endlessLevel = Level(number: 0, targetScore: 99999, movesLimit: 999,
                                     objectives: [], minWordLength: 3, stars: 0, isUnlocked: true)
            gameState = GameState(level: endlessLevel)
        }

        renderBoard()

        // Auto-clear any starting matches (no move cost)
        run(.sequence([
            .wait(forDuration: 1.5),
            .run { [weak self] in self?.autoResolveBoard() }
        ]))
    }

    // MARK: - Layout

    private func calculateTileSize() {
        let topReserved: CGFloat = 180 + safeAreaTop
        let bottomReserved: CGFloat = 110 + safeAreaBottom
        let sideMargin: CGFloat = 25

        let availableWidth = size.width - (sideMargin * 2)
        let availableHeight = size.height - topReserved - bottomReserved

        let gridW = CGFloat(cols), gridH = CGFloat(rows)

        let maxFromWidth  = (availableWidth  - (gridW - 1) * TILE_SPACING) / gridW
        let maxFromHeight = (availableHeight - (gridH - 1) * TILE_SPACING) / gridH

        TILE_SIZE = min(maxFromWidth, maxFromHeight)
        TILE_SIZE = min(max(TILE_SIZE, 50), 72) // clamp for phones
        TILE_SPACING = 8

        let totalWidth  = gridW * TILE_SIZE + (gridW - 1) * TILE_SPACING
        let totalHeight = gridH * TILE_SIZE + (gridH - 1) * TILE_SPACING
        gridSize = CGSize(width: totalWidth, height: totalHeight)

        let centerX = size.width / 2
        let availableCenterY = bottomReserved + (availableHeight / 2)
        gridOrigin = snapped(CGPoint(x: centerX - totalWidth / 2,
                                     y: availableCenterY - totalHeight / 2))
    }

    private func getPosition(row: Int, col: Int) -> CGPoint {
        let x = gridOrigin.x + TILE_SIZE / 2 + CGFloat(col) * (TILE_SIZE + TILE_SPACING)
        // row 0 is top
        let yTop = gridOrigin.y + gridSize.height - TILE_SIZE / 2
        let y = yTop - CGFloat(row) * (TILE_SIZE + TILE_SPACING)
        return snapped(CGPoint(x: x, y: y))
    }

    private func snap(_ v: CGFloat) -> CGFloat {
        let scale = view?.contentScaleFactor ?? UIScreen.main.scale
        return (v * scale).rounded() / scale
    }
    private func snapped(_ p: CGPoint) -> CGPoint { CGPoint(x: snap(p.x), y: snap(p.y)) }

    // MARK: - Background

    private func setupBackground() {
        removeChildren(in: children.filter { $0.name == "bg" || $0.name == "overlay" })

        if let bgImage = UIImage(named: "bg") {
            let texture = SKTexture(image: bgImage)
            let bg = SKSpriteNode(texture: texture)
            bg.name = "bg"; bg.zPosition = -10
            bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
            let s = max(size.width / texture.size().width, size.height / texture.size().height)
            bg.xScale = s; bg.yScale = s
            addChild(bg)
        }

        let overlay = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.35), size: size)
        overlay.name = "overlay"; overlay.zPosition = -9
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(overlay)
    }

    // MARK: - Rendering

    private func renderBoard() {
        for child in children where child.name?.hasPrefix("tile-") == true { child.removeFromParent() }

        for r in 0..<rows {
            for c in 0..<cols {
                if let tile = gameBoard.getTile(row: r, col: c) {
                    let sprite = createTile(tile)
                    tile.sprite = sprite
                    addChild(sprite)

                    sprite.setScale(0.0)
                    sprite.alpha = 0.0
                    let delay = Double(r + c) * 0.05
                    sprite.run(.sequence([
                        .wait(forDuration: delay),
                        .group([ .scale(to: 1.0, duration: 0.6),
                                 .fadeIn(withDuration: 0.5) ]),
                        .run { [weak sprite, weak self] in
                            sprite?.run(.sequence([
                                .scale(to: 1.12, duration: 0.18),
                                .scale(to: 1.0,  duration: 0.18)
                            ]), withKey: "bounce")
                            if let p = sprite?.position { sprite?.position = self?.snapped(p) ?? p }
                            sprite?.xScale = 1.0; sprite?.yScale = 1.0
                        }
                    ]))
                }
            }
        }

        ensureGridIntegrity()
    }

    private func createTile(_ tile: Tile) -> SKSpriteNode {
        let sprite = SKSpriteNode(color: .clear, size: CGSize(width: TILE_SIZE, height: TILE_SIZE))
        sprite.position = getPosition(row: tile.row, col: tile.col)
        sprite.name = "tile-\(tile.row)-\(tile.col)"
        sprite.zPosition = 10
        sprite.xScale = 1.0; sprite.yScale = 1.0
        sprite.alpha = 1.0

        let gradImg = createGradient(tile.letter)
        let bg = SKSpriteNode(texture: SKTexture(image: gradImg))
        bg.name = "bgTile"
        bg.size = sprite.size
        bg.zPosition = -1
        bg.alpha = 1.0
        bg.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        // Optional smoothing for the texture:
        bg.texture?.filteringMode = .linear
        sprite.addChild(bg)

        let border = SKShapeNode(rectOf: sprite.size, cornerRadius: TILE_SIZE * 0.28)
        border.strokeColor = .white.withAlphaComponent(0.8)
        border.lineWidth = 4
        border.fillColor = .clear
        border.glowWidth = 2
        border.zPosition = 1
        sprite.addChild(border)

        let shine = SKShapeNode(rectOf: CGSize(width: TILE_SIZE - 10, height: TILE_SIZE - 10),
                                cornerRadius: TILE_SIZE * 0.24)
        shine.strokeColor = .white.withAlphaComponent(0.4)
        shine.lineWidth = 2
        shine.fillColor = .clear
        shine.glowWidth = 4
        shine.zPosition = 2
        sprite.addChild(shine)

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = tile.letter.uppercased()
        label.fontSize = TILE_SIZE * 0.65
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.zPosition = 3
        sprite.addChild(label)

        let shadow = SKLabelNode(fontNamed: "AvenirNext-Bold")
        shadow.text = tile.letter.uppercased()
        shadow.fontSize = TILE_SIZE * 0.65
        shadow.fontColor = .black.withAlphaComponent(0.3)
        shadow.verticalAlignmentMode = .center
        shadow.horizontalAlignmentMode = .center
        shadow.position = CGPoint(x: 0, y: -2)
        shadow.zPosition = 2
        sprite.addChild(shadow)

        return sprite
    }

    // Rebuild missing sprites / children and resnap positions
    private func ensureGridIntegrity() {
        for r in 0..<rows {
            for c in 0..<cols {
                guard let t = gameBoard.getTile(row: r, col: c) else { continue }

                let missingSprite = (t.sprite == nil) || (t.sprite?.parent == nil)
                let missingBG = t.sprite?.childNode(withName: "bgTile") == nil

                if missingSprite || missingBG {
                    t.sprite?.removeFromParent()
                    let sp = createTile(t)
                    t.sprite = sp
                    sp.position = getPosition(row: r, col: c)
                    addChild(sp)
                } else {
                    t.sprite?.name = "tile-\(r)-\(c)"
                    t.sprite?.size = CGSize(width: TILE_SIZE, height: TILE_SIZE)
                    t.sprite?.position = getPosition(row: r, col: c)
                }
            }
        }
    }

    // MARK: - Graphics

    private func createGradient(_ letter: String) -> UIImage {
        let s = CGSize(width: TILE_SIZE, height: TILE_SIZE)
        UIGraphicsBeginImageContextWithOptions(s, false, 0)
        guard let ctx = UIGraphicsGetCurrentContext() else { return UIImage() }

        let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: s), cornerRadius: s.width * 0.28)
        ctx.addPath(path.cgPath); ctx.clip()

        let colors = getColors(letter)
        let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                              colors: colors.map { $0.cgColor } as CFArray,
                              locations: [0.0, 0.5, 1.0])!
        ctx.drawLinearGradient(grad, start: .zero, end: CGPoint(x: s.width, y: s.height), options: [])

        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return img
    }

    private func getColors(_ letter: String) -> [UIColor] {
        let grads: [[UIColor]] = [
            [UIColor(red: 1.0, green: 0.3, blue: 0.6, alpha: 1), UIColor(red: 0.8, green: 0.2, blue: 0.8, alpha: 1), UIColor(red: 0.6, green: 0.2, blue: 0.9, alpha: 1)],
            [UIColor(red: 0.2, green: 0.5, blue: 1.0, alpha: 1), UIColor(red: 0.3, green: 0.7, blue: 1.0, alpha: 1), UIColor(red: 0.4, green: 0.9, blue: 1.0, alpha: 1)],
            [UIColor(red: 0.2, green: 0.8, blue: 0.3, alpha: 1), UIColor(red: 0.4, green: 0.9, blue: 0.4, alpha: 1), UIColor(red: 0.6, green: 1.0, blue: 0.5, alpha: 1)],
            [UIColor(red: 1.0, green: 0.5, blue: 0.2, alpha: 1), UIColor(red: 1.0, green: 0.7, blue: 0.3, alpha: 1), UIColor(red: 1.0, green: 0.9, blue: 0.4, alpha: 1)],
            [UIColor(red: 1.0, green: 0.2, blue: 0.3, alpha: 1), UIColor(red: 1.0, green: 0.4, blue: 0.3, alpha: 1), UIColor(red: 1.0, green: 0.6, blue: 0.3, alpha: 1)],
            [UIColor(red: 0.6, green: 0.3, blue: 1.0, alpha: 1), UIColor(red: 0.8, green: 0.3, blue: 0.9, alpha: 1), UIColor(red: 1.0, green: 0.4, blue: 0.8, alpha: 1)],
            [UIColor(red: 0.2, green: 0.8, blue: 0.8, alpha: 1), UIColor(red: 0.3, green: 0.9, blue: 0.9, alpha: 1), UIColor(red: 0.5, green: 1.0, blue: 1.0, alpha: 1)],
            [UIColor(red: 0.9, green: 1.0, blue: 0.3, alpha: 1), UIColor(red: 0.7, green: 1.0, blue: 0.4, alpha: 1), UIColor(red: 0.5, green: 1.0, blue: 0.5, alpha: 1)]
        ]
        return grads[Int(letter.uppercased().unicodeScalars.first?.value ?? 65) % grads.count]
    }

    // MARK: - Input

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !inputLocked, let touch = touches.first else { return }
        if let tile = findTile(at: touch.location(in: self)) {
            firstTouchedTile = tile
            highlight(tile, true)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !inputLocked, let touch = touches.first, let first = firstTouchedTile else { return }
        if let target = findTile(at: touch.location(in: self)),
           target !== first,
           gameBoard.isAdjacent(tile1: first, tile2: target) {
            highlight(first, false)
            swap(first, target)
            firstTouchedTile = nil
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let tile = firstTouchedTile { highlight(tile, false); firstTouchedTile = nil }
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let tile = firstTouchedTile { highlight(tile, false); firstTouchedTile = nil }
    }

    private func findTile(at location: CGPoint) -> Tile? {
        let hit = atPoint(location)
        var n: SKNode? = hit
        while let cur = n {
            if let name = cur.name, name.hasPrefix("tile-") {
                let comps = name.dropFirst(5).split(separator: "-")
                if comps.count == 2, let r = Int(comps[0]), let c = Int(comps[1]) {
                    return gameBoard.getTile(row: r, col: c)
                }
            }
            n = cur.parent
        }
        return nil
    }

    private func normalize(_ s: SKSpriteNode?) {
        guard let s = s else { return }
        s.removeAction(forKey: "pulse")
        s.removeAction(forKey: "bounce")
        s.removeAllActions()
        s.xScale = 1.0; s.yScale = 1.0
        s.alpha = 1.0
        s.position = snapped(s.position)
    }

    private func highlight(_ tile: Tile, _ on: Bool) {
        guard let s = tile.sprite else { return }
        s.removeAction(forKey: "pulse")
        s.run(.scale(to: on ? 1.25 : 1.0, duration: 0.2))
        if on {
            s.run(.repeatForever(.sequence([
                .fadeAlpha(to: 0.85, duration: 0.3),
                .fadeAlpha(to: 1.0,  duration: 0.3)
            ])), withKey: "pulse")
        } else {
            s.alpha = 1.0
        }
    }

    // MARK: - Motion tracking & buttons

    private func beginMove() {
        movingCounter += 1
        lastMovementTimestamp = CACurrentMediaTime()
    }
    private func endMove() {
        movingCounter = max(0, movingCounter - 1)
        lastMovementTimestamp = CACurrentMediaTime()
    }
    private func refreshButtons() {
        let canPress = !inputLocked && movingCounter == 0
        onShuffleEnabledChanged?(canPress)
        onHintEnabledChanged?(canPress)
    }

    // MARK: - Swapping / Matching

    private func swap(_ t1: Tile, _ t2: Tile) {
        guard !inputLocked,
              let s1 = t1.sprite, let s2 = t2.sprite else { return }
        inputLocked = true

        normalize(s1); normalize(s2)

        let p1 = snapped(s1.position)
        let p2 = snapped(s2.position)

        // Swap MODEL first so matcher sees swapped letters
        gameBoard.swapTiles(tile1: t1, tile2: t2)

        let mid = CGPoint(x: (p1.x + p2.x)/2, y: (p1.y + p2.y)/2 + 30)
        let path1 = UIBezierPath(); path1.move(to: p1); path1.addQuadCurve(to: p2, controlPoint: mid)
        let path2 = UIBezierPath(); path2.move(to: p2); path2.addQuadCurve(to: p1, controlPoint: mid)

        let a1 = SKAction.follow(path1.cgPath, asOffset: false, orientToPath: false, duration: 0.28)
        let a2 = SKAction.follow(path2.cgPath, asOffset: false, orientToPath: false, duration: 0.28)

        let group = DispatchGroup()
        beginMove(); group.enter(); s1.run(a1) { self.endMove(); group.leave() }
        beginMove(); group.enter(); s2.run(a2) { self.endMove(); group.leave() }

        group.notify(queue: .main) {
            var matched: Set<Tile> = []
            self.findMatches(&matched)

            if matched.isEmpty {
                // No match: revert model and animate back (snapped)
                self.gameBoard.swapTiles(tile1: t1, tile2: t2)

                let back1 = SKAction.move(to: self.snapped(p1), duration: 0.22)
                let back2 = SKAction.move(to: self.snapped(p2), duration: 0.22)
                let shake = SKAction.sequence([
                    .moveBy(x: -8, y: 0, duration: 0.05),
                    .moveBy(x: 16,  y: 0, duration: 0.10),
                    .moveBy(x: -8, y: 0, duration: 0.05)
                ])

                self.beginMove()
                s1.run(shake)
                s1.run(back1) { self.normalize(s1); self.endMove() }

                self.beginMove()
                s2.run(shake)
                s2.run(back2) { self.normalize(s2); self.endMove() }

                self.gameState.resetCombo()
                self.inputLocked = false
                self.refreshButtons()
            } else {
                // Valid swap → handle matches; move counts once
                self.handleMatches(Array(matched), consumeMove: true, showFX: true)
                // unlock in cascade end
            }
        }
    }

    private func findMatches(_ matched: inout Set<Tile>) {
        // Horizontal
        for r in 0..<rows {
            var streak: [Tile] = []
            var last = ""
            for c in 0..<cols {
                if let t = gameBoard.getTile(row: r, col: c) {
                    if t.letter == last { streak.append(t) }
                    else {
                        if streak.count >= 3 { streak.forEach { matched.insert($0) } }
                        streak = [t]; last = t.letter
                    }
                }
            }
            if streak.count >= 3 { streak.forEach { matched.insert($0) } }
        }
        // Vertical
        for c in 0..<cols {
            var streak: [Tile] = []
            var last = ""
            for r in 0..<rows {
                if let t = gameBoard.getTile(row: r, col: c) {
                    if t.letter == last { streak.append(t) }
                    else {
                        if streak.count >= 3 { streak.forEach { matched.insert($0) } }
                        streak = [t]; last = t.letter
                    }
                }
            }
            if streak.count >= 3 { streak.forEach { matched.insert($0) } }
        }
    }

    // consumeMove: true only for the first, player-caused match
    // showFX: false for silent auto-resolve (spawn/shuffle)
    private func handleMatches(_ tiles: [Tile], consumeMove: Bool, showFX: Bool = true) {
        inputLocked = true

        gameState.incrementCombo()
        let count = tiles.count
        let points = count * 100 * gameState.comboMultiplier
        gameState.addScore(points)
        onScoreUpdate?(gameState.score)

        if showFX {
            enqueueHUD("\(count) MATCH! +\(points)", 48, .white, 1.0)
            if gameState.comboMultiplier > 1 {
                enqueueHUD("\(gameState.comboMultiplier)x COMBO! 🔥", 40,
                           UIColor(red: 1, green: 0.85, blue: 0, alpha: 1), 0.9)
            }
        }

        for tile in tiles {
            if let s = tile.sprite {
                if showFX { explode(s.position) }
                let kill = SKAction.sequence([
                    .group([
                        .scale(to: 1.6, duration: 0.25),
                        .rotate(byAngle: .pi * 2, duration: 0.3),
                        .fadeOut(withDuration: 0.3)
                    ]),
                    .removeFromParent()
                ])
                s.run(kill)
                tile.sprite = nil
            }
        }

        if consumeMove { updateMoves() } // only once per valid swap

        run(.sequence([
            .wait(forDuration: 0.5),
            .run { [weak self] in self?.refill(tiles, showFX: showFX) }
        ]))
    }

    private func refill(_ tiles: [Tile], showFX: Bool) {
        for tile in tiles {
            let r = tile.row, c = tile.col
            let pos = getPosition(row: r, col: c)

            let newTile = Tile(letter: Tile.randomLetter(), row: r, col: c)
            gameBoard.tiles[r][c] = newTile

            let sprite = createTile(newTile)
            newTile.sprite = sprite
            sprite.position = CGPoint(x: pos.x, y: pos.y + 700)
            sprite.alpha = 0
            addChild(sprite)

            let move = SKAction.move(to: pos, duration: 0.75)
            let fade = SKAction.fadeIn(withDuration: 0.45)

            beginMove()
            sprite.run(.group([move, fade])) { [weak self, weak sprite] in
                sprite?.run(.sequence([
                    .scale(to: 1.15, duration: 0.12),
                    .scale(to: 1.0,  duration: 0.12)
                ]), withKey: "bounce")
                if let p = sprite?.position { sprite?.position = self?.snapped(p) ?? p }
                sprite?.xScale = 1.0; sprite?.yScale = 1.0
                self?.endMove()
            }
        }

        run(.sequence([
            .wait(forDuration: 0.85),
            .run { [weak self] in
                self?.ensureGridIntegrity()
                self?.cascade(showFX: showFX)
            }
        ]))
    }

    private func cascade(showFX: Bool) {
        var matched: Set<Tile> = []
        findMatches(&matched)
        if !matched.isEmpty {
            // Cascades shouldn’t cost extra moves
            handleMatches(Array(matched), consumeMove: false, showFX: showFX)
        } else {
            gameState.resetCombo()
            inputLocked = false
            refreshButtons()
            checkForPossibleMoves()
        }
    }

    // MARK: - Auto resolve (spawn / shuffle)
    private func autoResolveBoard() {
        var matched: Set<Tile> = []
        findMatches(&matched)
        if matched.isEmpty {
            refreshButtons()
            checkForPossibleMoves()
        } else {
            // Silent clear; no move cost
            handleMatches(Array(matched), consumeMove: false, showFX: false)
        }
    }

    // MARK: - Shuffle / Hints (queued if busy)

    func shuffleBoard() {
        guard !inputLocked, movingCounter == 0 else {
            queuedShuffleRequest = true
            return
        }
        queuedShuffleRequest = false
        refreshButtons()

        var attempts = 0
        repeat {
            attempts += 1
            let all = getAllTiles()
            let shuffled = all.map { $0.letter }.shuffled()
            for (i, t) in all.enumerated() { t.letter = shuffled[i] }
            if hasMoves() {
                animateShuffle(all)
                showToast("🔄 Board Shuffled!")
                run(.sequence([
                    .wait(forDuration: 1.0),
                    .run { [weak self] in
                        self?.ensureGridIntegrity()
                        self?.autoResolveBoard()
                    }
                ]))
                return
            }
        } while attempts < 100

        createGuaranteed()
        let all = getAllTiles()
        animateShuffle(all)
        showToast("🔄 Board Shuffled!")
        run(.sequence([
            .wait(forDuration: 1.0),
            .run { [weak self] in
                self?.ensureGridIntegrity()
                self?.autoResolveBoard()
            }
        ]))
    }

    func showHint() {
        guard !inputLocked, movingCounter == 0 else {
            queuedHintRequest = true
            return
        }
        queuedHintRequest = false

        for r in 0..<rows {
            for c in 0..<cols {
                if let t = gameBoard.getTile(row: r, col: c) {
                    if c < cols - 1, let rt = gameBoard.getTile(row: r, col: c + 1) {
                        gameBoard.swapTiles(tile1: t, tile2: rt)
                        var m: Set<Tile> = []; findMatches(&m)
                        gameBoard.swapTiles(tile1: t, tile2: rt)
                        if !m.isEmpty { hintHighlight(t, rt); return }
                    }
                    if r < rows - 1, let bt = gameBoard.getTile(row: r + 1, col: c) {
                        gameBoard.swapTiles(tile1: t, tile2: bt)
                        var m: Set<Tile> = []; findMatches(&m)
                        gameBoard.swapTiles(tile1: t, tile2: bt)
                        if !m.isEmpty { hintHighlight(t, bt); return }
                    }
                }
            }
        }
        // no hint found
    }

    private func animateShuffle(_ tiles: [Tile]) {
        for t in tiles {
            guard let s = t.sprite else { continue }
            let pos = s.position
            s.removeAllChildren()

            let newSprite = createTile(t)
            newSprite.position = snapped(pos)
            s.parent?.addChild(newSprite)
            t.sprite = newSprite
            s.removeFromParent()

            newSprite.setScale(0.8); newSprite.alpha = 0.5
            let wait = SKAction.wait(forDuration: Double.random(in: 0...0.3))
            let anim = SKAction.sequence([
                wait,
                .group([
                    .scale(to: 1.3, duration: 0.25),
                    .fadeAlpha(to: 1.0, duration: 0.25),
                    .rotate(byAngle: .pi * 2, duration: 0.4)
                ]),
                .scale(to: 1.0, duration: 0.2),
                .run { [weak self, weak newSprite] in
                    newSprite?.xScale = 1.0; newSprite?.yScale = 1.0
                    if let p = newSprite?.position { newSprite?.position = self?.snapped(p) ?? p }
                }
            ])

            beginMove()
            newSprite.run(anim) { [weak self] in
                self?.endMove()
                self?.ensureGridIntegrity()
            }
        }
    }

    private func getAllTiles() -> [Tile] {
        var all: [Tile] = []
        for r in 0..<rows {
            for c in 0..<cols {
                if let t = gameBoard.getTile(row: r, col: c) { all.append(t) }
            }
        }
        return all
    }

    private func createGuaranteed() {
        let letters = (65...90).map { String(UnicodeScalar($0)!) }
        var used: Set<String> = []

        for _ in 0..<5 {
            let l = letters.randomElement()!
            if createH(l, &used) != nil { continue }
            else if createV(l, &used) != nil { continue }
        }
        for r in 0..<rows {
            for c in 0..<cols {
                if let t = gameBoard.getTile(row: r, col: c) {
                    let key = "\(r),\(c)"
                    if !used.contains(key) { t.letter = letters.randomElement()! }
                }
            }
        }
    }

    private func createH(_ letter: String, _ used: inout Set<String>) -> [Tile]? {
        for _ in 0..<20 {
            let r = Int.random(in: 0..<rows)
            let sc = Int.random(in: 0..<(cols - 2))
            var ok = true
            var tiles: [Tile] = []
            for o in 0..<3 {
                let c = sc + o
                let key = "\(r),\(c)"
                if used.contains(key) { ok = false; break }
                if let t = gameBoard.getTile(row: r, col: c) { tiles.append(t) }
            }
            if ok && tiles.count == 3 {
                for t in tiles { t.letter = letter; used.insert("\(t.row),\(t.col)") }
                return tiles
            }
        }
        return nil
    }

    private func createV(_ letter: String, _ used: inout Set<String>) -> [Tile]? {
        for _ in 0..<20 {
            let c = Int.random(in: 0..<cols)
            let sr = Int.random(in: 0..<(rows - 2))
            var ok = true
            var tiles: [Tile] = []
            for o in 0..<3 {
                let r = sr + o
                let key = "\(r),\(c)"
                if used.contains(key) { ok = false; break }
                if let t = gameBoard.getTile(row: r, col: c) { tiles.append(t) }
            }
            if ok && tiles.count == 3 {
                for t in tiles { t.letter = letter; used.insert("\(t.row),\(t.col)") }
                return tiles
            }
        }
        return nil
    }

    // MARK: - Hints

    private func hintHighlight(_ t1: Tile, _ t2: Tile) {
        for t in [t1, t2] {
            t.sprite?.run(.repeatForever(.sequence([
                .fadeAlpha(to: 0.4, duration: 0.3),
                .fadeAlpha(to: 1.0, duration: 0.3)
            ])), withKey: "hint")
        }
        run(.sequence([
            .wait(forDuration: 3.0),
            .run {
                for t in [t1, t2] {
                    t.sprite?.removeAction(forKey: "hint")
                    t.sprite?.alpha = 1.0
                }
            }
        ]))
    }

    private func checkForPossibleMoves() {
        if !hasMoves() {
            run(.sequence([
                .wait(forDuration: 1.0),
                .run { [weak self] in self?.shuffleBoard() }
            ]))
        }
    }

    private func hasMoves() -> Bool {
        for r in 0..<rows {
            for c in 0..<cols {
                if let t = gameBoard.getTile(row: r, col: c) {
                    if c < cols - 1, let rt = gameBoard.getTile(row: r, col: c + 1) {
                        gameBoard.swapTiles(tile1: t, tile2: rt)
                        var m: Set<Tile> = []; findMatches(&m)
                        gameBoard.swapTiles(tile1: t, tile2: rt)
                        if !m.isEmpty { return true }
                    }
                    if r < rows - 1, let bt = gameBoard.getTile(row: r + 1, col: c) {
                        gameBoard.swapTiles(tile1: t, tile2: bt)
                        var m: Set<Tile> = []; findMatches(&m)
                        gameBoard.swapTiles(tile1: t, tile2: bt)
                        if !m.isEmpty { return true }
                    }
                }
            }
        }
        return false
    }

    // MARK: - HUD / Toast / FX

    private func enqueueHUD(_ text: String, _ baseSize: CGFloat, _ color: UIColor, _ dur: TimeInterval) {
        hudQueue.append(HUDMessage(text: text, baseSize: baseSize, color: color, dur: dur))
        if !hudShowing { showNextHUD() }
    }

    private func showNextHUD() {
        guard !hudQueue.isEmpty else { hudShowing = false; return }
        hudShowing = true
        let m = hudQueue.removeFirst()

        let lbl = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        lbl.text = m.text
        lbl.fontSize = m.baseSize
        lbl.fontColor = m.color
        lbl.verticalAlignmentMode = .center
        lbl.horizontalAlignmentMode = .center
        // Keep in safe vertical band
        let minY = safeAreaBottom + 140
        let maxY = size.height - safeAreaTop - 120
        let hudY = min(max(size.height * 0.55, minY), maxY)
        lbl.position = CGPoint(x: size.width / 2, y: hudY)
        lbl.zPosition = 0
        lbl.setScale(0); lbl.alpha = 0
        hudLayer.addChild(lbl)

        // drop shadows
        let s1 = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        s1.text = m.text; s1.fontSize = m.baseSize
        s1.fontColor = .black.withAlphaComponent(0.4)
        s1.position = CGPoint(x: 4, y: -4); s1.zPosition = -1
        lbl.addChild(s1)

        let s2 = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        s2.text = m.text; s2.fontSize = m.baseSize
        s2.fontColor = .black.withAlphaComponent(0.2)
        s2.position = CGPoint(x: 8, y: -8); s2.zPosition = -2
        lbl.addChild(s2)

        // Auto-fit to 90% width
        let maxWidth = size.width * 0.9
        lbl.setScale(1.0)
        var neededScale: CGFloat = 1.0
        let currentWidth = lbl.frame.width
        if currentWidth > maxWidth && currentWidth > 0 {
            neededScale = maxWidth / currentWidth
        }
        lbl.setScale(0.0)

        let appear = SKAction.group([ .scale(to: neededScale, duration: 0.18),
                                      .fadeIn(withDuration: 0.18) ])
        let pop = SKAction.scale(to: neededScale * 1.05, duration: 0.08)
        let settle = SKAction.scale(to: neededScale, duration: 0.08)
        let wait = SKAction.wait(forDuration: m.dur)
        let disappear = SKAction.group([ .scale(to: neededScale * 0.8, duration: 0.18),
                                         .fadeOut(withDuration: 0.18) ])

        lbl.run(.sequence([
            appear, pop, settle, wait, disappear, .removeFromParent(),
            .run { [weak self] in self?.hudShowing = false; self?.showNextHUD() }
        ]))
    }

    private func show3D(_ text: String, _ font: CGFloat, _ color: UIColor, _ dur: TimeInterval) {
        enqueueHUD(text, font, color, dur)
    }

    private func showToast(_ msg: String) {
        let toast = SKShapeNode(rectOf: CGSize(width: 280, height: 60), cornerRadius: 30)
        toast.fillColor = .black.withAlphaComponent(0.85)
        toast.strokeColor = .white.withAlphaComponent(0.6)
        toast.lineWidth = 3
        toast.position = CGPoint(x: size.width / 2, y: 120)
        toast.zPosition = 250
        toast.setScale(0.5)
        toast.alpha = 0
        addChild(toast)

        let lbl = SKLabelNode(fontNamed: "AvenirNext-Bold")
        lbl.text = msg
        lbl.fontSize = 20
        lbl.fontColor = .white
        lbl.verticalAlignmentMode = .center
        toast.addChild(lbl)

        toast.run(.sequence([
            .group([.scale(to: 1.0, duration: 0.25), .fadeIn(withDuration: 0.25)]),
            .wait(forDuration: 1.2),
            .group([.scale(to: 0.5, duration: 0.25), .fadeOut(withDuration: 0.25)]),
            .removeFromParent()
        ]))
    }

    private func explode(_ pos: CGPoint) {
        let e = SKEmitterNode()
        e.position = pos
        e.particleBirthRate = 250
        e.numParticlesToEmit = 60
        e.particleLifetime = 1.8
        e.particleSpeed = 300
        e.particleSpeedRange = 120
        e.emissionAngle = 0
        e.emissionAngleRange = .pi * 2
        e.particleScale = 0.6
        e.particleScaleRange = 0.5
        e.particleScaleSpeed = -0.5
        e.particleAlpha = 1.0
        e.particleAlphaSpeed = -0.7
        e.particleColor = .white
        e.particleColorBlendFactor = 1.0
        e.particleBlendMode = .add
        e.particleTexture = circleTexture()
        e.zPosition = 50
        addChild(e)
        run(.sequence([.wait(forDuration: 3.0), .run { e.removeFromParent() }]))
    }

    private func circleTexture() -> SKTexture {
        let s = CGSize(width: 24, height: 24)
        UIGraphicsBeginImageContextWithOptions(s, false, 0)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.setFillColor(UIColor.white.cgColor)
        ctx.fillEllipse(in: CGRect(origin: .zero, size: s))
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return SKTexture(image: img)
    }

    // MARK: - Moves / Game Over

    private func updateMoves() {
        gameState.movesRemaining -= 1
        onMovesUpdate?(gameState.movesRemaining)
        if gameState.movesRemaining <= 0 { checkGameOver() }
    }

    private func checkGameOver() {
        switch gameMode {
        case .endless:
            // ✅ THIS SAVES THE SCORE
            LeaderboardManager.shared.addScore(gameState.score)
            
            // Check if it's a high score
            if LeaderboardManager.shared.isHighScore(gameState.score) {
                show3D("🎉 NEW HIGH SCORE! 🎉", 40, UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0), 2.0)
            }
            
            onGameOver?(false, gameState.score, gameState.longestWord)
        case .none:
            break
        case .some(.level(_)):
            break
        }
    }

}
