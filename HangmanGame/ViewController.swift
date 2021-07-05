//
//  ViewController.swift
//  HangmanGame
//
//  Created by Igor Chernyshov on 03.07.2021.
//

import UIKit

final class ViewController: UIViewController {

	// MARK: - Subviews
	@IBOutlet var levelLabel: UILabel!
	@IBOutlet var scoreLabel: UILabel!
	@IBOutlet var wrongGuessesLabel: UILabel!

	// MARK: - Properties
	private var words: [String] = []

	private var currentWord: String = ""

	private var openedLetters: [String] = []

	private var wrongGuesses: [String] = []

	private var level = 0 {
		didSet {
			levelLabel.text = "Level: \(level + 1)"
			loadLevel()
		}
	}

	private var score = 0 {
		didSet {
			scoreLabel.text = "Score: \(score)"
		}
	}

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		configureUI()
		loadWords()
		loadLevel()
	}

	// MARK: - UI Configuration
	private func configureUI() {
		let guessLetterButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(didTapGuessLetter))
		navigationItem.rightBarButtonItem = guessLetterButton
	}

	// MARK: - Game Logic
	private func loadWords() {
		guard let wordsFileURL = Bundle.main.url(forResource: "words", withExtension: "txt"),
			  let loadedStrings = try? String(contentsOf: wordsFileURL) else { return }
		words = loadedStrings.components(separatedBy: "\n")
	}

	private func loadLevel() {
		guard level < words.count else {
			showAlert(title: "No more levels left", message: "Congratulations, you've beaten every level in the game!")
			return
		}
		currentWord = words[level].uppercased()
		openedLetters.removeAll()
		wrongGuesses.removeAll()
		wrongGuessesLabel.text = ""
		updateTitle()
	}

	private func updateTitle(newLetter: String? = nil) {
		var newTitle = ""
		for letter in currentWord {
			let letterAsString = String(letter)
			if openedLetters.contains(letterAsString) {
				newTitle += letterAsString
			} else {
				newTitle += "?"
			}
		}

		if title != newTitle {
			if newLetter != nil {
				score += 1
			}
		} else {
			if let wrongGuess = newLetter {
				didGuessWrong(guess: wrongGuess)
				score -= 1
			}
			return
		}

		title = newTitle

		if title == currentWord {
			increaseLevel()
		}
	}

	private func didGuessWrong(guess: String) {
		wrongGuesses.append(guess)
		if wrongGuesses.count >= 7 {
			gameOver()
		}

		let guesses = wrongGuesses.reduce(into: "") { $0 += "\($1) " }
		let string = NSMutableAttributedString(string: guesses)
		string.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, string.length))
		wrongGuessesLabel.attributedText = string
	}

	private func increaseLevel() {
		showAlert(title: "Correct!", message: "You've guessed the word. Now prepare for the next level") { [weak self] _ in
			self?.level += 1
		}
	}

	private func gameOver() {
		showAlert(title: "Game over", message: "You have no chances left. Try again!") { [weak self] _ in
			self?.score = 0
			self?.level = 0
		}
	}

	@objc private func didTapGuessLetter() {
		let alertController = UIAlertController(title: "Guess a letter", message: nil, preferredStyle: .alert)
		alertController.addTextField()
		alertController.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
			guard let self = self,
				  let text = alertController.textFields?.first?.text?.uppercased(),
				  text.count == 1,
				  !self.openedLetters.contains(text) else { return }
			self.openedLetters.append(text)
			self.updateTitle(newLetter: text)
		})
		present(alertController, animated: UIView.areAnimationsEnabled)
	}

	// MARK: - Alerts
	private func showAlert(title: String, message: String? = nil, completion: ((UIAlertAction) -> Void)? = nil) {
		let alertController = makeInfoAlertController(title: title, message: message, completion: completion)
		present(alertController, animated: UIView.areAnimationsEnabled)
	}

	private func makeInfoAlertController(title: String,
										 message: String? = nil,
										 completion: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))
		return alertController
	}
}

