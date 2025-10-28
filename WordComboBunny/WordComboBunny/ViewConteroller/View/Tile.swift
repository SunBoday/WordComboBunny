//
//  Tile.swift
//  WordComboBunny
//
//  Created by SunTory2025 on 2025/10/28.
//

import Foundation
import UIKit
import SpriteKit  // ← ADD THIS LINE

// MARK: -
// MARK: - Tile Model
class Tile: Hashable, Equatable {
    var letter: String
    var row: Int
    var col: Int
    var state: TileState
    var sprite: SKSpriteNode?
    let id: UUID  // ← ADD unique identifier
    
    enum TileState {
        case normal
        case selected
        case matched
        case falling
    }
    
    init(letter: String, row: Int, col: Int) {
        self.letter = letter
        self.row = row
        self.col = col
        self.state = .normal
        self.id = UUID()  // ← ADD unique ID
    }
    
    // MARK: - Hashable Conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)  // Hash based on unique ID
    }
    
    // MARK: - Equatable Conformance
    static func == (lhs: Tile, rhs: Tile) -> Bool {
        return lhs.id == rhs.id  // Compare by unique ID
    }
    
    // Letter frequency distribution for better gameplay
    static func randomLetter() -> String {
        let letterDistribution = [
            "A": 8, "B": 2, "C": 3, "D": 4, "E": 12, "F": 2,
            "G": 2, "H": 3, "I": 8, "J": 1, "K": 1, "L": 4,
            "M": 2, "N": 6, "O": 8, "P": 2, "Q": 1, "R": 6,
            "S": 6, "T": 9, "U": 4, "V": 2, "W": 2, "X": 1,
            "Y": 2, "Z": 1
        ]
        
        var pool: [String] = []
        for (letter, frequency) in letterDistribution {
            pool.append(contentsOf: Array(repeating: letter, count: frequency))
        }
        return pool.randomElement() ?? "A"
    }
}


// MARK: - GameBoard Model
class GameBoard {
    let rows: Int
    let cols: Int
    var tiles: [[Tile]]
    
    init(rows: Int, cols: Int) {
        self.rows = rows
        self.cols = cols
        self.tiles = []
        
        for row in 0..<rows {
            var rowTiles: [Tile] = []
            for col in 0...cols {
                let tile = Tile(letter: Tile.randomLetter(), row: row, col: col)
                rowTiles.append(tile)
            }
            tiles.append(rowTiles)
        }
    }
    
    func getTile(row: Int, col: Int) -> Tile? {
        guard row >= 0, row < rows, col >= 0, col < cols else { return nil }
        return tiles[row][col]
    }
    
    func swapTiles(tile1: Tile, tile2: Tile) {
        let tempRow = tile1.row
        let tempCol = tile1.col
        
        tiles[tile1.row][tile1.col] = tile2
        tiles[tile2.row][tile2.col] = tile1
        
        tile1.row = tile2.row
        tile1.col = tile2.col
        tile2.row = tempRow
        tile2.col = tempCol
    }
    
    func isAdjacent(tile1: Tile, tile2: Tile) -> Bool {
        let rowDiff = abs(tile1.row - tile2.row)
        let colDiff = abs(tile1.col - tile2.col)
        return (rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1)
    }
}

// MARK: - Level Model
struct Level: Codable {
    let number: Int
    let targetScore: Int
    let movesLimit: Int
    let objectives: [String]
    let minWordLength: Int
    var stars: Int
    var isUnlocked: Bool
    
    static func loadLevels() -> [Level] {
        return [
            Level(number: 1, targetScore: 1000, movesLimit: 20, objectives: ["Score 1000 points"], minWordLength: 3, stars: 0, isUnlocked: true),
            Level(number: 2, targetScore: 1500, movesLimit: 18, objectives: ["Score 1500 points", "Form 3 words of 5+ letters"], minWordLength: 3, stars: 0, isUnlocked: false),
            Level(number: 3, targetScore: 2000, movesLimit: 15, objectives: ["Score 2000 points", "Form 10 words"], minWordLength: 4, stars: 0, isUnlocked: false),
            Level(number: 4, targetScore: 2500, movesLimit: 20, objectives: ["Score 2500 points"], minWordLength: 3, stars: 0, isUnlocked: false),
            Level(number: 5, targetScore: 3000, movesLimit: 15, objectives: ["Score 3000 points", "Form 5 words of 6+ letters"], minWordLength: 4, stars: 0, isUnlocked: false),
            Level(number: 6, targetScore: 3500, movesLimit: 12, objectives: ["Score 3500 points"], minWordLength: 4, stars: 0, isUnlocked: false),
            Level(number: 7, targetScore: 4000, movesLimit: 18, objectives: ["Score 4000 points", "Form 15 words"], minWordLength: 3, stars: 0, isUnlocked: false),
            Level(number: 8, targetScore: 4500, movesLimit: 10, objectives: ["Score 4500 points"], minWordLength: 4, stars: 0, isUnlocked: false),
            Level(number: 9, targetScore: 5000, movesLimit: 15, objectives: ["Score 5000 points", "Form 7 words of 6+ letters"], minWordLength: 4, stars: 0, isUnlocked: false),
            Level(number: 10, targetScore: 6000, movesLimit: 20, objectives: ["Score 6000 points", "Form 20 words"], minWordLength: 3, stars: 0, isUnlocked: false)
        ]
    }
    
    func calculateStars(score: Int) -> Int {
        if score >= targetScore * 2 {
            return 3
        } else if score >= Int(Double(targetScore) * 1.5) {
            return 2
        } else if score >= targetScore {
            return 1
        }
        return 0
    }
}

// MARK: - GameState Model
class GameState {
    var score: Int = 0
    var movesRemaining: Int
    var currentLevel: Int
    var comboMultiplier: Int = 1
    var longestWord: String = ""
    var wordsFormed: [String] = []
    var fiveLetterWords: Int = 0
    var sixLetterWords: Int = 0
    var totalWords: Int = 0
    
    init(level: Level) {
        self.currentLevel = level.number
        self.movesRemaining = level.movesLimit
    }
    
    func addScore(_ points: Int) {
        score += points * comboMultiplier
    }
    
    func incrementCombo() {
        comboMultiplier = min(comboMultiplier + 1, 5)
    }
    
    func resetCombo() {
        comboMultiplier = 1
    }
    
    func trackWord(_ word: String) {
        wordsFormed.append(word)
        totalWords += 1
        if word.count >= 5 {
            fiveLetterWords += 1
        }
        if word.count >= 6 {
            sixLetterWords += 1
        }
        if word.count > longestWord.count {
            longestWord = word
        }
    }
}

// MARK: - Game Mode
enum GameMode {
    case level(Level)
    case endless
}
