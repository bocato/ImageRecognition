//
//  ResultsViewController.swift
//  ImageRecognition
//
//  Created by Eduardo Sanches Bocato on 04/09/17.
//  Copyright © 2017 Bocato. All rights reserved.
//

import UIKit
import Vision

private enum ReuseIdentifiers: String {
    case LargeResultTableViewCell = "LargeResultTableViewCell"
    case DefaultResultTableViewCell = "DefaultResultTableViewCell"
}

class ResultsViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var minimumConfidenceLabel: UILabel!
    
    // MARK: - Properties
    var cameraViewController: RecognizerViewController!
    var classifications = [VNClassificationObservation]()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    // MARK: - Configuration
    func configureTableView() {
        tableView.estimatedRowHeight = 85.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    // MARK: Actions
    @IBAction func horizontalSliderValueChanged(_ sender: UISlider) {
        self.cameraViewController.minimumConfidence = sender.value
        self.minimumConfidenceLabel.text = "Minimum Confidence: \(String(format: "%.2g", sender.value))"
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EmbedCameraSegue" {
            cameraViewController = segue.destination as! RecognizerViewController
            cameraViewController.delegate = self
        }
    }
    
}

// MARK: - UITableViewDataSource

extension ResultsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.classifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let observation = self.classifications[indexPath.row]
        
        let description = observation.identifier
        let progress = CGFloat(observation.confidence)
        let score = String(format: "%.2f", observation.confidence)
        
        let cellReuseIdentifier = indexPath.row == 0 ? ReuseIdentifiers.LargeResultTableViewCell.rawValue : ReuseIdentifiers.DefaultResultTableViewCell.rawValue
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! ResultTableViewCell
        
        cell.configure(withDescription: description, progress: progress, score: score)
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate
//extension MainViewController: UITableViewDelegate {}

// MARK: - RecognizerViewControllerDelegate
extension ResultsViewController: RecognizerViewControllerDelegate {
    
    func didReceiveNewClassificationResults(_ classificationResults: [VNClassificationObservation]?) {
        
        guard let newResults = classificationResults else { return }
        
        if self.classifications.count == 0 {
            self.classifications = newResults
            self.tableView.reloadData()
            return
        }
        
        if newResults != self.classifications {
            
            debugPrint("CurrentResult = \(self.classifications.first?.identifier ?? "-"): \(self.classifications.first?.confidence ?? 0.0)")
            debugPrint("NewResult = \(newResults.first?.identifier ?? "-"): \(newResults.first?.confidence ?? 0.0)")
            
            
            if newResults.first?.identifier == self.classifications.first?.identifier && newResults.first!.confidence <= self.classifications.first!.confidence {
                return
            }
            else {
                self.classifications = newResults
                self.tableView.reloadData()
            }
            
        }
        
    }
    
}
