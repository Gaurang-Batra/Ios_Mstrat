import UIKit

class ActivityTrackViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the background color
        view.backgroundColor = UIColor.systemGray6

        // Scroll View to contain the stack view
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        // Stack View for Information Cards
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)

        // Dark green color for consistency
        let darkGreenColor = UIColor(red: 85/255, green: 173/255, blue: 156/255, alpha: 1.0)

        // Adding components iteratively
        let cardDetails = [
            ("Calories burned", "120 Kcal", "10:30 AM", 0.6),
            ("Workout Minutes", "30 Mins", nil, 0.3),
            ("Body Weight", "72 Kg", nil, nil)
        ]

//        for (title, value, time, progress) in cardDetails {
//            let progressFloat: Float? = progress != nil ? Float(progress!) : nil
//            let card = createCard(title: title, value: value, time: time, color: darkGreenColor, progress: progressFloat, isCircular: progress != nil)
//            stackView.addArrangedSubview(card)
//        }

        // Steps card with progress pillars
        let stepsCard = createStepsPillarsCard(steps: 6000, target: 10000, color: darkGreenColor)
        stackView.addArrangedSubview(stepsCard)

        // Auto Layout Constraints
        NSLayoutConstraint.activate([
            // Scroll View constraints
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            // Stack View constraints inside Scroll View
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),

            // Stack View width matches the Scroll View's width
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }

    // Helper functions remain unchanged
//    private func createCard(title: String, value: String, time: String?, color: UIColor, progress: Float?, isCircular: Bool) -> UIView {
//        let cardView = UIView()
//        cardView.backgroundColor = .white
//        cardView.layer.cornerRadius = 12
//        cardView.layer.shadowColor = UIColor.black.cgColor
//        cardView.layer.shadowOpacity = 0.1
//        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
//        cardView.layer.shadowRadius = 8
//        cardView.translatesAutoresizingMaskIntoConstraints = false
//
//        if let timeText = time {
//            let timeLabel = UILabel()
//            timeLabel.text = timeText
//            timeLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
//            timeLabel.textColor = UIColor.darkGray
//            timeLabel.translatesAutoresizingMaskIntoConstraints = false
//            cardView.addSubview(timeLabel)
//
//            NSLayoutConstraint.activate([
//                timeLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 8),
//                timeLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -8)
//            ])
//        }
//
//        let titleLabel = UILabel()
//        titleLabel.text = title
//        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//
//        let valueLabel = UILabel()
//        valueLabel.text = value
//        valueLabel.font = UIFont.boldSystemFont(ofSize: 18)
//        valueLabel.textColor = UIColor.black
//        valueLabel.translatesAutoresizingMaskIntoConstraints = false
//
//        cardView.addSubview(titleLabel)
//        cardView.addSubview(valueLabel)
//
//        if let progressValue = progress {
//            if isCircular {
//                // Add circular progress bar
//                let circularProgressView = createCircularProgressBar(progress: progressValue, color: color)
//                cardView.addSubview(circularProgressView)
//
//                NSLayoutConstraint.activate([
//                    circularProgressView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
//                        circularProgressView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
//                        circularProgressView.widthAnchor.constraint(equalToConstant: 50),
//                        circularProgressView.heightAnchor.constraint(equalTo: circularProgressView.widthAnchor)
//                    ])
//                
//            }
//        }
//
//        NSLayoutConstraint.activate([
//            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10),
//            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
//            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: cardView.trailingAnchor, constant: -16),
//
//            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
//            valueLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
//            valueLabel.trailingAnchor.constraint(lessThanOrEqualTo: cardView.trailingAnchor, constant: -16),
//
//            cardView.bottomAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 16),
//            cardView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100)
//        ])
//
//        return cardView
//    }

    private func createCircularProgressBar(progress: Float, color: UIColor) -> UIView {
        let size: CGFloat = 50
        let progressView = UIView()
        progressView.translatesAutoresizingMaskIntoConstraints = false

        let circularPath = UIBezierPath(arcCenter: CGPoint(x: size / 2, y: size / 2), radius: size / 2 - 5, startAngle: -.pi / 2, endAngle: 2 * .pi - .pi / 2, clockwise: true)

        let trackLayer = CAShapeLayer()
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = UIColor.systemGray5.cgColor
        trackLayer.lineWidth = 5
        trackLayer.fillColor = UIColor.clear.cgColor
        progressView.layer.addSublayer(trackLayer)

        let progressLayer = CAShapeLayer()
        progressLayer.path = circularPath.cgPath
        progressLayer.strokeColor = color.cgColor
        progressLayer.lineWidth = 5
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeEnd = CGFloat(progress)
        progressView.layer.addSublayer(progressLayer)

        return progressView
    }

    private func createStepsPillarsCard(steps: Int, target: Int, color: UIColor) -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowOffset = CGSize(width: 10, height: 10)
        cardView.layer.shadowRadius = 8
        cardView.translatesAutoresizingMaskIntoConstraints = false

        // Title Label
        let titleLabel = UILabel()
//        titleLabel.text = "Steps"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(titleLabel)

        // Steps Label
        let stepsLabel = UILabel()
//        stepsLabel.text = "\(steps) steps"
        stepsLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        stepsLabel.textColor = UIColor.darkGray
        stepsLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(stepsLabel)

        // Bar Graph Container
        let barGraphContainer = UIView()
        barGraphContainer.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(barGraphContainer)

        NSLayoutConstraint.activate([
            barGraphContainer.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            barGraphContainer.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
            barGraphContainer.widthAnchor.constraint(equalToConstant: 300),
            barGraphContainer.heightAnchor.constraint(equalToConstant: 10000)
        ])

        // Bar Stack View
        let barStackView = UIStackView()
        barStackView.axis = .horizontal
        barStackView.spacing = 4
        barStackView.alignment = .bottom
        barStackView.distribution = .fillEqually
        barStackView.translatesAutoresizingMaskIntoConstraints = false
        barGraphContainer.addSubview(barStackView)

        NSLayoutConstraint.activate([
            barStackView.topAnchor.constraint(equalTo: barGraphContainer.topAnchor),
            barStackView.leadingAnchor.constraint(equalTo: barGraphContainer.leadingAnchor),
            barStackView.trailingAnchor.constraint(equalTo: barGraphContainer.trailingAnchor),
            barStackView.bottomAnchor.constraint(equalTo: barGraphContainer.bottomAnchor)
        ])

        // Progress Bars
        let stepsPerPillar = max(1, target / 10) // Avoid division by zero
        for i in 0..<7 {
            let progressView = UIView()
            if i == 6 {
                progressView.backgroundColor = UIColor(named: "#6CAB9C") // Set color for 4th bar
                    } else {
                        progressView.backgroundColor = UIColor.systemGray5 // Grey color for other bars
                    }
                    progressView.layer.cornerRadius = 0
                    progressView.translatesAutoresizingMaskIntoConstraints = false
                    barStackView.addArrangedSubview(progressView)

            NSLayoutConstraint.activate([
                progressView.heightAnchor.constraint(equalToConstant: CGFloat(Int.random(in: 30...80)))
            ])
        }

        // Layout Constraints
        NSLayoutConstraint.activate([
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
                titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
                titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: cardView.trailingAnchor, constant: -16),

            // Steps Label
            stepsLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
            stepsLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            cardView.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            cardView.heightAnchor.constraint(greaterThanOrEqualToConstant: 350)
        ])

        return cardView
    }

}
