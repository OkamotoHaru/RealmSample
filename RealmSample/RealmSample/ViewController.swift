//
//  ViewController.swift
//  RealmSample
//
//  Created by MasatoUchida on 2019/11/11.
//  Copyright © 2019 MasatoUchida. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {

    // MARK: - ライフサイクル
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
#if DEBUG
        // レルムデータがあるなら削除
//        if let url = Realm.Configuration.defaultConfiguration.fileURL {
//            let realmURLs = [
//                url,
//                url.appendingPathExtension("lock"),
//                url.appendingPathExtension("note"),
//                url.appendingPathExtension("management")
//            ]
//            for URL in realmURLs {
//                do {
//                    try FileManager.default.removeItem(at: URL)
//                } catch {
//                    Logger.debug(error.localizedDescription)
//                }
//            }
//        }
#endif
        
        // レルムファイルパス取得
        if let url = Realm.Configuration.defaultConfiguration.fileURL {
            Logger.debug(url.description)
            realmFilePath.text = url.description
        }
        
        // モデル作成
        let sample = Sample()
        // sample.id = 0 //自動採番するため不要
        sample.name = "sample!"
        // モデル全削除（初期化）
        SampleAction.shared.deleteAll()
        // モデル新規追加
        SampleAction.shared.post(sample)
        // モデル取得
        guard let modelData = SampleAction.shared.getModel().first else {
            id.text = "unknown"
            name.text = "unknown"
            return
        }
        // 表示
        Logger.debug("get first id: \(modelData.id)")
        Logger.debug("get first name: \(modelData.name)")
        id.text = modelData.id.description
        name.text = modelData.name
        // モデル更新
        modelData.name = "sample sample"
        SampleAction.shared.put(modelData)
        // モデル取得
        guard let putModelData = SampleAction.shared.getModel().first else {
            id.text = "unknown"
            name.text = "unknown"
            return
        }
        // 表示
        Logger.debug("get first id: \(putModelData.id)")
        Logger.debug("get first name: \(putModelData.name)")
        id.text = putModelData.id.description
        name.text = putModelData.name
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: - ラベル
    
    /// レルムファイルパス
    @IBOutlet weak var realmFilePath: UILabel!
    @IBOutlet weak var id: UILabel!
    @IBOutlet weak var name: UILabel!
}

