//
//  RealmDaoProtocol.swift
//  PTCGSim
//
//  Created by MasatoUchida on 2019/11/07.
//  Copyright © 2019 MasatoUchida. All rights reserved.
//

import Foundation
import RealmSwift

/// レルムの共通処理です。
/// アクションに継承して使用します。
protocol RealmDaoProtocol: class {
    /// レルムデータクラス
    associatedtype RealmType: Object
    /// レルムと紐づくモデルクラス
    associatedtype ModelType
    /// ローカル保存しているレルムデータ
    var datas: [RealmType]? { get set }
    /// レルムデータ→モデル
    func convertToModel(_ realmData: RealmType) -> ModelType
    /// モデル→レルムデータ
    func convertToRealm(_ modelData: ModelType) -> RealmType
    /// 自動採番ありの新規追加
    func post(_ realmData: RealmType)
    /// 自動採番ありの新規追加
    func post(_ realmDatas: [RealmType])
    /// 自動採番ありの新規追加
    func post(_ modelData: ModelType)
    /// 自動採番ありの新規追加
    func post(_ modelDatas: [ModelType])
    /// レルムデータ更新
    func put(_ modelData: ModelType)
    /// レルムデータ更新
    func put(_ modelDatas: [ModelType])
    /// レルムデータ取得
    func getModel() -> [ModelType]
    /// レルムデータ取得
    func getModel(_ id: Int) -> ModelType
    /// レルムデータ削除
    func delete(_ modelData: ModelType)
    /// レルムデータ削除
    func delete(_ modelDatas: [ModelType])
}

extension RealmDaoProtocol {
    
    /// レルムデータを追加します
    ///
    /// - Parameter realmDatas : レルムデータ
    public func corePost(_ realmDatas: [RealmType]) {
        do {
            let realm = try Realm()
            for realmData in realmDatas {
                let _realmData = realmData
                try realm.write {
                    realm.add(_realmData)
                }
                // ローカルにも設定
                addDatas(_realmData)
            }
        } catch {
            Logger.debug(error.localizedDescription)
        }
    }
    
    /// レルムデータを追加します
    ///
    /// - Parameter realmDatas: レルムデータ
    public func corePost(_ realmData: RealmType) {
        let _realmData = realmData
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(_realmData)
            }
            // ローカルにも設定
            addDatas(_realmData)
        } catch {
            Logger.debug(error.localizedDescription)
        }
    }
    
    /// データを更新します
    /// - Parameter realmDatas: レルムデータ
    public func put(_ realmDatas: [RealmType]) {
        do {
            let realm = try Realm()
            for realmData in realmDatas {
                try realm.write {
                    realm.add(realmData, update: .modified)
                }
            }
        } catch {
            Logger.debug(error.localizedDescription)
        }
    }
    
    /// データを更新します
    /// - Parameter realmData: レルムデータ
    public func put(_ realmData: RealmType) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(realmData, update: .modified)
            }
        } catch {
            Logger.debug(error.localizedDescription)
        }
    }
    
    /// レルムデータを取得します
    ///
    /// - Returns: レルムデータ
    public func get() -> [RealmType] {
        // すでに取得すみならそれを返す
        if let tmpDatas = datas {
            return tmpDatas;
        }
        // 初回のみ取得しにいく
        var tmpDatas: [RealmType] = []
        do {
            let realm = try Realm()
            let realmClasses = realm.objects(RealmType.self)
            for realmClass in realmClasses {
                tmpDatas.append(realmClass as RealmType)
            }
        } catch {
            Logger.debug(error.localizedDescription)
        }
        datas = tmpDatas
        return tmpDatas
    }
    
    /// レルムデータを全て削除します
    public func deleteAll() {
        do {
            let realm = try Realm()
            let realmClasses = realm.objects(RealmType.self)
            if realmClasses.count < 1 {
                return
            }
            try realm.write {
                realm.delete(realmClasses)
            }
        } catch {
            Logger.debug(error.localizedDescription)
        }
    }
    
    /// レルムデータを削除します
    /// - Parameter realmData: レルムデータ
    public func delete(_ realmData: RealmType) {
        do {
            let realm = try Realm()
            let realmClasses = realm.objects(RealmType.self)
            if realmClasses.count < 1 {
                return
            }
            try realm.write {
                realm.delete(realmData)
            }
        } catch {
            Logger.debug(error.localizedDescription)
        }
    }
    
    /// レルムデータを削除します
    /// - Parameter realmData: レルムデータ
    public func delete(_ realmDatas: [RealmType]) {
        do {
            let realm = try Realm()
            let realmClasses = realm.objects(RealmType.self)
            if realmClasses.count < 1 {
                return
            }
            for realmData in realmDatas {
                try realm.write {
                    realm.delete(realmData)
                }
            }
        } catch {
            Logger.debug(error.localizedDescription)
        }
    }
    
    /// プライマリキーを自動採番します
    /// - Parameter model: レルムデータ
    public func autoIncrement<T: Object>(model: T) -> Int {
        guard let key = T.primaryKey() else {
            Logger.debug("このオブジェクトにはプライマリキーがありません")
            return 0
        }
        // Realmのインスタンスを取得
        let realm = try! Realm()
        // 最後のプライマリーキーを取得
        if let last = realm.objects(T.self).sorted(byKeyPath: "id", ascending: true).last,
            let lastId = last[key] as? Int {
            return lastId + 1 // 最後のプライマリキーに+1した数値を返す
        } else {
            return 0  // 初めて使う際は0を返す
        }
    }
    
    /// レルムデータをローカルに保存します
    /// - Parameter realmData: レルムデータ
    private func addDatas(_ realmData: RealmType) {
        if datas == nil {
            datas = []
        }
        datas?.append(realmData)
    }
}
