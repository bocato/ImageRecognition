//
//  ResultTableViewCell.swift
//  ImageRecognition
//
//  Created by Eduardo Sanches Bocato on 01/09/17.
//  Copyright © 2017 Bocato. All rights reserved.
//

import UIKit

class ResultTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var descriptionLabel : UILabel!
    @IBOutlet weak var scoreLabel : UILabel!
    @IBOutlet weak var progressBar : ProgressBar!
    
    func configure(withDescription description: String, progress: CGFloat, score: String){
        descriptionLabel.text = description
        progressBar.progress = CGFloat(progress)
        scoreLabel.text = score
    }

}
