//
//  LaunchViewController.swift
//  iOSExcelAccounting
//
//  Created by cyc on 2020/5/4.
//  Copyright © 2020 cyc. All rights reserved.
//

import UIKit
import AVFoundation

class LaunchViewController: UIViewController {

    @IBOutlet weak var cycLogo: UIImageView!
    @IBOutlet weak var cycText: UILabel!
    /// **must** define instance variable outside, because .play() will deallocate AVAudioPlayer immediately and you won't hear a thing
    var player: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        cycLogo.alpha = 0
        cycText.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 3, animations: {
            self.cycLogo.alpha = 1
            self.cycText.alpha = 1
        }) { (finished) in
            self.performSegue(withIdentifier: "launched", sender: self)
        }
        guard let url = Bundle.main.url(forResource: "RobotVoice", withExtension: "wav") else {
            print("Cannot find RobotVoice.wav!")
            return
        }
        do {
            /// this codes for making this app ready to takeover the device audio
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue)
            player!.play()
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
