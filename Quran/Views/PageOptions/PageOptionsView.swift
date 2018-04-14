//
//  PageOptionsView.swift
//  Quran
//
//  Created by Eslam Hanafy on 4/14/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import UIKit

class PageOptionsView: UIView {

    @IBOutlet var containerView: UIView!
    @IBOutlet var soundSliderView: UIView!
    @IBOutlet var modesView: UIView!
    @IBOutlet var pauseImageView: UIImageView!
    @IBOutlet var soundSlider: UISlider!
    @IBOutlet var modeSegmented: UISegmentedControl!
    
    
    @IBOutlet var containerWidthConstraint: NSLayoutConstraint!
    
    
    fileprivate var parent: QuranViewController!
    
    fileprivate var page: Page!
    
    fileprivate var isDisplayingSoundView: Bool {
        get {
            return !soundSliderView.isHidden
        }
    }
    
    fileprivate var isDisplayingModesView: Bool {
        get {
            return !modesView.isHidden
        }
    }
    
    let containerHeight: CGFloat = 359
    let subContainerWidth: CGFloat = 240
    
    /// the show/hide animation duration
    fileprivate let animationDuration: TimeInterval = 0.8
    
    
    
    /// get new instance from PageOptionsView
    ///
    /// - Parameter controller: The view controller that will be responsable for displaying this instance
    /// - Returns: new instance from PageOptionsView
    public static func getInstance(forController controller: QuranViewController) -> PageOptionsView {
        let view = Bundle.main.loadNibNamed("PageOptionsView", owner: controller, options: nil)?.first as! PageOptionsView
        controller.view.addSubview(view)
        
        view.parent = controller
        view.soundSlider.value = QuranManager.manager.soundDegree
        view.modeSegmented.selectedSegmentIndex = QuranManager.manager.audioMode.selectedIndex()
        view.initDesigns()
        return view
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if !containerView.frame.contains(touch.location(in: self)) && !soundSliderView.frame.contains(touch.location(in: self)) && !modesView.frame.contains(touch.location(in: self)) {
                
                self.hide()
            }
        }
    }
    
    
    
    //MARK: - IBActions
    @IBAction func showOrHideSoundAction() {
        isDisplayingSoundView ? hideViewWithAnimation(soundSliderView) : showViewWithAnimation(soundSliderView)
    }
    
    @IBAction func showOrHideModesAction() {
        isDisplayingModesView ? hideViewWithAnimation(modesView) : showViewWithAnimation(modesView)
    }
    
    @IBAction func previousAction() {
        QuranManager.manager.playPreviousAyahIfNeeded()
    }
    
    @IBAction func pauseAction() {
        playOrPauseCurrentAyahIfNeeded()
    }
    
    @IBAction func nextAction() {
        QuranManager.manager.playNextAyahIfNeeded()
    }
    
    @IBAction func bookmarkAction() {
        guard let ayah = page.getAllSurah().first?.allAyah.first else {
            return
        }
        
        if ayah.isBookmarked {
            unBookmark(ayah: ayah)
        }else {
            bookmark(ayah: ayah)
        }
    }
    
    @IBAction func nightModeAction() {
        //TODO: - change the app to night mode
    }
    
    @IBAction func soundChangesAction() {
        QuranManager.manager.soundDegree = soundSlider.value
    }
    
    @IBAction func modeChangesAction() {
        switch modeSegmented.selectedSegmentIndex {
        case 0:
            QuranManager.manager.audioMode = .normal
        case 1:
            QuranManager.manager.audioMode = .memorize
        default:
            QuranManager.manager.audioMode = .learn
        }
    }
}

//MARK: - Helpers
extension PageOptionsView {
    /// make necessary changes to the design
    fileprivate func initDesigns() {
        //add missing constraints
        addMissingConstrinats(withSuperView: parent.view)
        self.isHidden = true
        containerView.layer.cornerRadius = containerWidthConstraint.constant * 0.5
        
        soundSliderView.layer.cornerRadius = 8
        modesView.layer.cornerRadius = 8
    }
    
    /// add missing constraints between self and the given view
    ///
    /// - Parameter view: the super view for this instance
    private func addMissingConstrinats(withSuperView view: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        //leading
        view.addConstraint(NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0.0))
        //trailing
        view.addConstraint(NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0.0))
        //top
        view.addConstraint(NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0))
        //bottom
        view.addConstraint(NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        
        view.layoutIfNeeded()
    }
    
    /// hide the popup view
    func hide() {
        hideContainerAnimation()
    }
    
    
    /// show the popup view with given CartItem
    func show(forPage page: Page) {
        self.page = page
        
        pauseImageView.image = UIImage(named: QuranManager.manager.player?.isPlaying == true ? "pause icon" : "play icon")
        showContainerAnimation()
    }
    
    /// mark current ayah as bookmarked
    fileprivate func bookmark(ayah: Ayah) {
        DBHelper.shared.addBookMark(forAyah: ayah)
        ayah.isBookmarked = true
        displayAlertWithTimer("تم اضافة الفاصل بنجاح", forController: self.parent, timeInSeconds: 3.0)
    }
    
    
    /// mark current ayah as not bookmarked
    fileprivate func unBookmark(ayah: Ayah) {
        DBHelper.shared.delete(bookmarkForAyah: ayah)
        ayah.isBookmarked = false
        displayAlertWithTimer("تم حذف الفاصل بنجاح", forController: self.parent, timeInSeconds: 3.0)
    }
    
    fileprivate func playOrPauseCurrentAyahIfNeeded() {
        if QuranManager.manager.player == nil {
            playFirstAyah()
        }else {
            if QuranManager.manager.player!.isPlaying {
                QuranManager.manager.pauseCurrentAyah()
                pauseImageView.image = UIImage(named: "play icon")
            }else {
                QuranManager.manager.resumeCurrentAyah()
                pauseImageView.image = UIImage(named: "pause icon")
            }
        }
    }
    
    fileprivate func playFirstAyah() {
        guard let ayah = page.getAllSurah().first?.allAyah.first else {
            return
        }
        
        if ayah.audioFiles.path(forMode: QuranManager.manager.audioMode) == nil {
            QuranManager.manager.showDownloadOptions(forAyah: ayah)
        }else {
            QuranManager.manager.play(ayah: ayah)
            pauseImageView.image = UIImage(named: "pause icon")
        }
    }
}

//MARK: - Animation
extension PageOptionsView {
    
    /// display the popup view with animation
    fileprivate func showContainerAnimation() {
        containerView.transform = CGAffineTransform(scaleX: 1, y: 0)
        
        UIView.transition(with: self, duration: animationDuration * 0.8 , options: [.transitionCrossDissolve], animations: {
            self.isHidden = false
        }, completion: nil)
        
        UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [], animations: {
            self.containerView.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    
    /// hide the popup view with animation
    fileprivate func hideContainerAnimation(){
        
        UIView.animate(withDuration: animationDuration * 0.5, animations: {
            self.containerView.transform = CGAffineTransform(scaleX: 1, y: 0.0001)
        }) { (_) in
            self.isHidden = true
            self.alpha = 1.0
            self.containerView.transform = CGAffineTransform.identity
        }
    }
    
    fileprivate func showViewWithAnimation(_ view: UIView) {
        view.transform = CGAffineTransform(scaleX: 0, y: 1)
        view.isHidden = false
        
        UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [], animations: {
            view.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    fileprivate func hideViewWithAnimation(_ view: UIView) {
        
        UIView.animate(withDuration: animationDuration * 0.5, animations: {
            view.transform = CGAffineTransform(scaleX: 0.0001, y: 1)
        }) { (_) in
            view.isHidden = true
            view.transform = CGAffineTransform.identity
        }
    }
}