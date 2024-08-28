import { UIAbility } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { relationalStore } from '@kit.ArkData';  // API 12，似乎要真机才能调试

// RdbUtils 工具包
export default class RdbUtil {
  private static rdbStore: relationalStore.RdbStore

  // 建立数据库
  static setStore(store: relationalStore.RdbStore) {
    RdbUtil.rdbStore = store
  }

  // 获取数据库
  static getStore(): relationalStore.RdbStore {
    return RdbUtil.rdbStore;
  }

  // 执行SQL
  static executeSql(sql: string) {
    return RdbUtil.getStore().executeSql(sql)
  }

  // 插入
  // static insertData(data: relationalStore.ValuesBucket) {
  //   this.rdbStore.insert(this.ta)
  // }
}

// 在生命周期中配置数据库
let store: relationalStore.RdbStore | undefined = undefined;

class EntryAbility extends UIAbility {
  onWindowStageCreate(windowStage: window.WindowStage){
    // 数据库配置
    const STORE_CONFIG: relationalStore.StoreConfig = {
      name: "RdbTest.db",
      securityLevel: relationalStore.SecurityLevel.S1
    };

    // 数据库操作的异步回调：（1）callback回调；（2）promise 回调
    // 本工程使用 promise 回调
    // 获取数据库
    relationalStore.getRdbStore(this.context, STORE_CONFIG)
      .then(async (rdbStore: relationalStore.RdbStore) => {
        console.info('Get RdbStore successfully.')
        store = rdbStore;
        RdbUtil.setStore(store)
      })
      .catch((err: BusinessError) => {
        console.error(`Get RdbStore failed, code is ${err.code},message is ${err.message}`);
      })

    // 删除数据库
    // relationalStore.deleteRdbStore(this.context, STORE_CONFIG)
    //   .then(()=>{
    //     store = undefined;
    //     console.info('Delete RdbStore successfully.');
    //   })
    //   .catch((err: BusinessError) => {
    //     console.error(`Delete RdbStore failed, code is ${err.code},message is ${err.message}`);
    //   })
  }
}