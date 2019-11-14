//
//  Sample.swift
//  RealmSample
//
//  Created by MasatoUchida on 2019/11/12.
//  Copyright © 2019 MasatoUchida. All rights reserved.
//

import RealmSwift

/// レルムデータのサンプルクラス
class RealmSample: Object {
    /// プライマリキー
    @objc dynamic var id: Int = 0
    /// 名前
    @objc dynamic var name: String = ""
    
    /// プライマリキーを設定します
    ///
    /// - Returns: 設定するメンバの名称
    override static func primaryKey() -> String? {
        return "id"
    }
}

/// レルムデータに紐づくモデルクラスのサンプル
class Sample {
    /// プライマリキー
    var id: Int = 0
    /// 名前
    var name: String = ""
}

/// サンプルクラスにサクセスするDaoクラスです
/// realm -> model間を解決したメソッドを提供します
class SampleAction: RealmDaoProtocol {
    
    // MARK: - パラメータ
    
    /// レルムデータ
    typealias RealmType = RealmSample
    /// レルムデータに紐づくモデルクラス
    typealias ModelType = Sample
    /// ローカルデータ
    var datas: [RealmType]? = nil
    /// シングルトン
    static let shared = SampleAction()
    
    // MARK: - 変換処理
    
    /// レルムデータをモデルクラスに変換します
    /// - Parameter realmData: レルムデータ
    public func convertToModel(_ realmData: RealmType) -> ModelType {
        let modelData = ModelType()
        modelData.id = realmData.id
        modelData.name = realmData.name
        return modelData
    }
    
    /// モデルクラスをレルムデータに変換します
    /// - Parameter modelData: モデルクラス
    public func convertToRealm(_ modelData: ModelType) -> RealmType {
        let realmData = RealmType()
        realmData.id = modelData.id
        realmData.name = modelData.name
        return realmData
    }
    
    // MARK: - アクション
    
    /// レルムにデータを新規追加します
    /// - Parameter realmData: レルムデータクラス
    public func post(_ realmData: RealmType) {
        let _realmData = realmData
        _realmData.id = autoIncrement(model: realmData)
        corePost(_realmData)
    }
    
    /// レルムにデータを新規追加します
    /// - Parameter realmData: レルムデータクラス
    public func post(_ realmDatas: [RealmType]) {
        var _realmDatas: [RealmType] = []
        realmDatas.forEach {
            let _realmData = $0
            _realmData.id = autoIncrement(model: $0) + _realmDatas.count
            _realmDatas.append(_realmData)
        }
        corePost(_realmDatas)
    }
    
    /// レルムにデータを新規追加します
    /// - Parameter modelData: モデルクラス
    public func post(_ modelData: ModelType) {
        let realmData = convertToRealm(modelData)
        post(realmData)
    }
    
    /// レルムにデータを新規追加します
    /// - Parameter modelData: モデルクラス
    public func post(_ modelDatas: [ModelType]) {
        var _realmDatas: [RealmType] = []
        modelDatas.forEach {
            _realmDatas.append(convertToRealm($0))
        }
        post(_realmDatas)
    }
    
    /// レルムにデータを更新します
    /// - Parameter modelData: モデルクラス
    public func put(_ modelData: ModelType) {
        let realmData = convertToRealm(modelData)
        put(realmData)
    }
    
    /// レルムにデータを更新します
    /// - Parameter modelDatas: モデルクラス
    public func put(_ modelDatas: [ModelType]) {
        var realmDatas: [RealmType] = []
        modelDatas.forEach {
            realmDatas.append(convertToRealm($0))
        }
        put(realmDatas)
    }
    
    /// レルムからデータを取得します
    public func getModel() -> [ModelType] {
        var modelDatas: [ModelType] = []
        get().forEach {
            modelDatas.append(convertToModel($0))
        }
        return modelDatas
    }
    
    /// レルムからデータを取得します
    /// - Parameter id: プライマリキー
    public func getModel(_ id: Int) -> ModelType {
        let modelDatas = getModel().filter { $0.id == id }
        guard let modelData = modelDatas.first else {
            Logger.debug("return empty model.")
            return ModelType()
        }
        return modelData
    }
    
    /// レルムのデータを削除します
    /// - Parameter modelData: モデルクラス
    public func delete(_ modelData: ModelType) {
        let realmData = convertToRealm(modelData)
        delete(realmData)
    }
    
    /// レルムのデータを削除します
    /// - Parameter modelData: モデルクラス
    public func delete(_ modelDatas: [ModelType]) {
        var realmDatas: [RealmType] = []
        modelDatas.forEach {
            realmDatas.append(convertToRealm($0))
        }
        delete(realmDatas)
    }
}
