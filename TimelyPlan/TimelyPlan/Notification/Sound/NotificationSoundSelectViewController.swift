//
//  NotificationSoundSelectViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/28.
//

import Foundation

class NotificationSoundSelectViewController: TPTableSectionsViewController,
                                             TPTableSectionControllerDelegate {
    
    var completion: ((NotificationSound?) -> Void)?
    
    private var sound: NotificationSound?

    private let defaultSectionController = NotificationSoundDefaultSectionController()
    private let customSectionController = NotificationSoundCustomSectionController()
    
    init(sound: NotificationSound?) {
        self.sound = sound
        super.init(style: .insetGrouped)
        self.defaultSectionController.headerItem.height = 5.0
        self.defaultSectionController.delegate = self
        self.customSectionController.headerItem.height = 20.0
        self.customSectionController.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = resGetString("Sound")
        setupActionsBar(actions: [saveAction])
        sectionControllers = [defaultSectionController,
                              customSectionController]
        adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        adapter.reloadData()
     }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override func clickSave() {
        navigationController?.popViewController(animated: true)
        callback(after: 0.2) {
            self.completion?(self.sound)
        }
    }
    
    // MARK: - TPTableSectionControllerDelegate
    func tableSectionController(_ sectionController: TPTableBaseSectionController, didSelectRowAt index: Int) {
        TPImpactFeedback.impactWithSoftStyle()
        if sectionController == customSectionController {
            self.sound = customSectionController.sounds[index]
        } else {
            self.sound = nil
        }
        
        adapter.updateCheckmarks()
        NotificationSoundManager.shared.previewSound(self.sound)
    }
    
    func tableSectionController(_ sectionController: TPTableBaseSectionController, shouldShowCheckmarkForRowAt index: Int) -> Bool {
        if sectionController == customSectionController {
            let sound = customSectionController.sounds[index]
            return self.sound == sound
        } else {
            return self.sound == nil
        }
    }
    
}

// MARK: - 静音

//class NotificationSoundMutedSectionController: TPTableItemSectionController {
//
//    override init() {
//        super.init()
//
//
//        let mutedImage = resGetImage("notification_muted_24")
//        let trailingText = resGetString("Your device is muted!")
//        let title: ASAttributedString
//        if let mutedImage = mutedImage {
//            title = .string(image: mutedImage,
//                            imageSize: .mini,
//                            imageColor: .danger6,
//                            trailingText: trailingText,
//                            textColor: resGetColor(.title),
//                            separator: nil)
//        } else {
//            title = .string(with: trailingText)
//        }
//
//        let cellItem = TPDefaultInfoTableCellItem()
//        cellItem.selectionStyle = .none
//        cellItem.autoResizable = true
//        cellItem.contentPadding = UIEdgeInsets(horizontal: 16.0, vertical: 20.0)
//        cellItem.titleConfig.font = .boldSystemFont(ofSize: 16.0)
//        cellItem.subtitleTopMargin = 10.0
//        cellItem.subtitleConfig.font = .boldSystemFont(ofSize: 13.0)
//        cellItem.subtitleConfig.textColor = .secondaryLabel
//        cellItem.title = title
//        cellItem.subtitle = resGetString("Notification sounds are off, but vibration alerts are still enabled.")
//        self.cellItems = [cellItem]
//    }
//}

// MARK: - 系统默认

class NotificationSoundDefaultSectionController: TPTableItemSectionController {
        
    override init() {
        super.init()
        let cellItem = TPCheckmarkTableCellItem()
        cellItem.imageName = "notification_sound_24"
        cellItem.title = NotificationSound.displayName(of: nil)
        self.cellItems = [cellItem]
    }
}


// MARK: - 自定义

class NotificationSoundCustomSectionController: TPTableItemSectionController {
    
    let sounds: [NotificationSound]
    
    override init() {
        let manager = NotificationSoundManager.shared
        self.sounds = manager.getAvailableSounds()
        super.init()
        var cellItems = [NotificationSoundCellItem]()
        for sound in self.sounds {
            let cellItem = NotificationSoundCellItem(sound: sound)
            cellItems.append(cellItem)
        }
        
        self.cellItems = cellItems
    }
}

class NotificationSoundCellItem: TPCheckmarkTableCellItem {
    
    let sound: NotificationSound
    
    init(sound: NotificationSound) {
        self.sound = sound
        super.init()
        self.imageName = "notification_sound_24"
        self.title = sound.displayName
    }
}
