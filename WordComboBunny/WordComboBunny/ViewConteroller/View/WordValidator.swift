//
//  WordValidator.swift
//  WordComboBunny
//
//  Created by SunTory2025 on 2025/10/28.
//

import UIKit

class WordValidator {
    static let shared = WordValidator()
    private var validWords: Set<String> = []
    
    init() {
        loadWordList()
    }
    
    private func loadWordList() {
        // Comprehensive word list for better validation
        let commonWords = [
            "THE", "CAT", "DOG", "RUN", "SIT", "EAT", "PLAY", "WORD", "GAME", "LOVE",
            "MAKE", "TIME", "FIRE", "STAR", "GRID", "TILE", "SWAP", "CRUSH", "MATCH", "SCORE",
            "LEVEL", "WINS", "FALL", "DROP", "SHAKE", "GLOW", "SPIN", "TURN", "FLIP", "SLIDE",
            "RISE", "DIVE", "JUMP", "DASH", "RUSH", "BLAST", "CRACK", "BREAK", "BUILD", "CREATE",
            "QUEST", "MAGIC", "POWER", "FORCE", "LIGHT", "DARK", "BRIGHT", "SHINE", "FLASH", "SPARK",
            "STORM", "WIND", "RAIN", "SNOW", "CLOUD", "MOON", "SUN", "SKY", "EARTH", "WATER",
            "FIRE", "ICE", "GOLD", "SILVER", "BRONZE", "DIAMOND", "CRYSTAL", "PEARL", "RUBY", "EMERALD",
            "KING", "QUEEN", "PRINCE", "KNIGHT", "WARRIOR", "HERO", "CHAMPION", "MASTER", "LEGEND", "EPIC",
            "DRAGON", "WIZARD", "CASTLE", "TOWER", "DUNGEON", "TREASURE", "CROWN", "SWORD", "SHIELD", "ARMOR",
            "BATTLE", "VICTORY", "GLORY", "HONOR", "BRAVE", "STRONG", "MIGHTY", "FIERCE", "WILD", "FREE"
        ]
        validWords = Set(commonWords)
    }
    
    func isValidWord(_ word: String) -> Bool {
        let upperWord = word.uppercased()
        guard upperWord.count >= 3 else { return false }
        
        // Check custom word list first
        if validWords.contains(upperWord) {
            return true
        }
        
        // Use system dictionary as fallback
        return UIReferenceLibraryViewController.dictionaryHasDefinition(forTerm: word.lowercased())
    }
    
    func scoreForWord(_ word: String) -> Int {
        switch word.count {
        case 3: return 100
        case 4: return 200
        case 5: return 500
        case 6: return 800
        case 7: return 1200
        case 8: return 1600
        default: return word.count * 250
        }
    }
}
