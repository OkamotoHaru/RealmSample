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
protocol RealmDaoProtocol: AnyObject {
    /// レルムデータクラス
    associatedtype RealmType: Object
    /// レルムと紐づくモデルクラス
    associatedtype ModelType
    /// レルムデータ→モデル
    func convertToModel(_ realmData: RealmType) -> ModelType
    /// モデル→レルムデータ
    func convertToRealm(_ modelData: ModelType) -> RealmType
    /// Realmクラスの新規追加
    func post(_ realmData: RealmType)
    /// Realmクラスの複数新規追加
    func post(_ realmDatas: [RealmType])
    /// モデルクラスの新規追加
    func post(_ modelData: ModelType)
    /// モデルクラスの複数新規追加
    func post(_ modelDatas: [ModelType])
    /// Realmデータ更新
    func put(_ realmData: RealmType)
    /// Realmデータの複数更新
    func put(_ realmDatas: [RealmType])
    /// モデルデータ更新
    func put(_ modelData: ModelType)
    /// モデルデータの複数更新
    func put(_ modelDatas: [ModelType])
    /// モデルデータの全件取得
    func getModel() -> [ModelType]
    /// 指定したプライマリキーのモデルデータの取得
    func getModel(_ id: Int) -> ModelType
    /// レルムデータ全件削除
    func deleteAll()
    /// レルムデータ削除
    func delete(_ modelData: ModelType)
    /// レルムデータ削除
    func delete(_ modelDatas: [ModelType])
}

extension RealmDaoProtocol {
    
    // MARK: - 新規追加
    
    /// レルムデータを複数追加します
    ///
    /// - Parameter realmDatas : レルムデータ
    public func post(_ realmDatas: [RealmType]) {
        do {
            let realm = try Realm()
            for realmData in realmDatas {
                let _realmData = realmData
                try realm.write {
                    realm.add(_realmData)
                }
            }
        } catch {
            Logger.debug(error.localizedDescription)
        }
    }
    
    /// レルムデータを追加します
    ///
    /// - Parameter realmDatas: レルムデータ
    public func post(_ realmData: RealmType) {
        let _realmData = realmData
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(_realmData)
            }
        } catch {
            Logger.debug(error.localizedDescription)
        }
    }
    
    /// モデルデータを追加します
    ///
    /// - Parameter modelData: モデルデータ
    public func post(_ modelData: ModelType) {
        let realmData = convertToRealm(modelData)
        post(realmData)
    }
    
    /// モデルデータを複数追加します
    ///
    /// - Parameter modelData: モデルデータ
    public func post(_ modelDatas: [ModelType]) {
        var realmDatas: [RealmType] = []
        modelDatas.forEach {
            let realmData = convertToRealm($0)
            realmDatas.append(realmData)
        }
        post(realmDatas)
    }
    
    // MARK: - 更新
    
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
    
    // MARK: - 取得
    
    /// レルムデータを取得します
    ///
    /// - Returns: レルムデータ
    public func get() -> [RealmType] {
        // 初回のみ取得しにいく
        var datas: [RealmType] = []
        do {
            let realm = try Realm()
            let realmClasses = realm.objects(RealmType.self)
            for realmClass in realmClasses {
                datas.append(realmClass as RealmType)
            }
        } catch {
            Logger.debug(error.localizedDescription)
        }
        return datas
    }
    
    // MARK: - 削除
    
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
    
    // MARK: - 採番
    
    /// プライマリキーを自動採番します
    /// - Parameter model: レルムデータ
    public func autoIncrement(realmModel: RealmType) -> Int {
        guard let key = RealmType.primaryKey() else {
            Logger.debug("このオブジェクトにはプライマリキーがありません")
            return 0
        }
        // Realmのインスタンスを取得
        let realm = try! Realm()
        // 最後のプライマリーキーを取得
        if let last = realm.objects(RealmType.self).sorted(byKeyPath: "id", ascending: true).last,
            let lastId = last[key] as? Int {
            return lastId + 1 // 最後のプライマリキーに+1した数値を返す
        } else {
            return 0  // 初めて使う際は0を返す
        }
    }
}
