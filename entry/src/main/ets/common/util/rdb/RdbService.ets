// import relationalStore from '@ohos.data.relationalStore';
import { relationalStore, ValueType } from '@kit.ArkData'
import { Context } from '@ohos.arkui.UIContext';

/*
思路：
* 总的 RdbService 类，内部封装 CRUD 操作
* 给各个 Entity 设置 Store，让它们继承 RdbService 类，重写封装方法
* 给各个 Entity 引用自身 Store 封装好的方法，具体实现并导出为 API
*/

// 旧 RdbUtil 见同目录下 BackupForRdbUtil.ets

class RdbService {
  private rdbStore?: relationalStore.RdbStore;

  /*
  // 初始化 RDB STore
  *//*
  参数注释
  context: 上下文
  sql: 初始化表的SQL
  *//*
  async initRdbStore(context: Context, sql: string) {
    // 数据库配置
    const STORE_CONFIG: relationalStore.StoreConfig = {
      name: 'MyApplication.db',
      securityLevel: relationalStore.SecurityLevel.S1
    };

    // 获取 RdbStore
    relationalStore.getRdbStore(context, STORE_CONFIG, (err, rdbStore) => {
      if (err) {
        console.log('testTag', '获取rdbStore失败！', err)
        return
      }

      // 执行 表初始化SQL
      // 初次建表后，由于以后表都存在，因此这句 sql 会执行，但没有效果（终止于 CREATE TABLE IF NOT EXISTS TASK）
      // 如果加 bindArgs: Array<ValueType> 参数，则可以传参，对于完整 SQL 则该参应该置为 空数组
      rdbStore.executeSql(sql, [], (err, res) => {
        if (err) {
          console.log('testTag', '表初始化失败', err)
        }
        console.log('testTag', '表初始化成功！', res)
      })

      // 保存 RdbStore
      this.rdbStore = rdbStore;
    });
  }
  */

  // 改写：初始化 RdbSTore
  init(context: Context): Promise<relationalStore.RdbStore> {
    // 数据库配置
    const STORE_CONFIG: relationalStore.StoreConfig = {
      name: 'MyApplication.db',
      securityLevel: relationalStore.SecurityLevel.S1
    };
    // 获取 RdbStore
    return relationalStore.getRdbStore(context, STORE_CONFIG)
      .catch((err: Error) => {
        throw err
      })
  }

  // 初始化表
  create(sql: string): Promise<void> {
    if (!this.rdbStore) {
      throw new Error('表初始化失败！');
    }
    return this.rdbStore.executeSql(sql, [])
      .then(res => {
        console.log('testTag', '表初始化成功！', res);
      })
      .catch((err: Error) => {
        throw err
      })
  }

  // 封装CRUD：查 get 1.0
  /*
  参数注释
  table：表名
  columns：表示要查询的(多个)列。如果值为空，则查询应用于所有列。例子：['ID', 'NAME', 'FINISHED']
  * 返回值 Promise<T[] | undefined>：某类型的数组 或者 查不到返回 undefined
  */
  /*
  async get(table: string, columns?: Array<string>): Promise<Record<string, string>[]> {
    if (!this.rdbStore) {
      throw new Error('RdbStore is not initialized');
    }

    try {
      // 1.查询条件
      let predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(table)
      // 2.查询
      let result = await this.rdbStore.query(predicates, columns)
      // 3.解析查询结果
      const data: Record<string, string>[] = [];
      // 遍历封装
      while (!result.isAtLastRow) {
        result.goToNextRow();  // 指针移动到下一行
        const rowData: Record<string, string> = {};
        columns?.forEach(column => {
          rowData[column] = result.getString(result.getColumnIndex(column));
        });
        data.push(rowData);
      }
      return data
    } catch (err) {
      return Promise.reject(err)
    }
  }
*/


/*
  // 重写get 2.0
  async get(table: string, columns?: Array<string>): Promise<Record<string, string>[]> {
    if (!this.rdbStore) {
      throw new Error('rdbStore is not defined');
    }

    if (!columns) {
      throw new Error('Must specify columns when fetching all data from the table');
    }

    try {
      const resultSet = await this.rdbStore.query(new relationalStore.RdbPredicates(table), columns);
      console.info(`ResultSet column names: ${resultSet.columnNames}, column count: ${resultSet.columnCount}`);

      const data: Record<string, string>[] = [];

      while (resultSet.goToNextRow()) {
        const rowData: Record<string, string> = {};
        columns.forEach(column => {
          rowData[column] = resultSet.getString(resultSet.getColumnIndex(column));
        });
        data.push(rowData);
      }
      // 释放数据集的内存（如果 resultSet 有这个方法的话）
      resultSet.close();
      return data;
    } catch (err) {
      if (err instanceof Error) {
        console.error(`Query failed, name is ${err.name}, message is ${err.message}`);
      }
      throw new Error
    }
  }*/

  // 重写get 3.0
  get(table: string, columns: Array<string> | []): Array<relationalStore.ValuesBucket> {
    if (!this.rdbStore) {
      throw new Error('rdbStore is not defined');
    }

    return this.rdbStore.query(new relationalStore.RdbPredicates(table), columns)
      .then((resultSet: relationalStore.ResultSet) => {
        console.info(`ResultSet column names: ${resultSet.columnNames}, column count: ${resultSet.columnCount}`);
        // const data: Record<string, string>[] = [];

        const data: Array<relationalStore.ValuesBucket> = []
        while (resultSet.goToNextRow()) {
          const rowData: Record<string, string> = {};
          columns.forEach(column => {
            rowData[column] = resultSet.getString(resultSet.getColumnIndex(column));
          });
          data.push(rowData);
        }
        return data
      })
      .catch((err: Error) => {
        throw err
      })
    }


  // 封装CRUD：增 add
  /*
  参数注释
  table：表名
  values：表示要插入到表中的数据行。
  返回值 Promise<number>：如果操作成功，返回行ID；否则返回-1。
  */
  add(table: string, values: relationalStore.ValuesBucket): Promise<number> {
    if (!this.rdbStore) {
      throw new Error('RdbStore is not initialized');
    }
    /*
    ValuesBucket 类型：
    键值对，键为 string，可以用''，"" 或直接写
    值为 ValueType(number、string、boolean) | Uint8Array | null
    */
    // relationalStore.RdbStore.insert(table: string, values: relationalStore.ValuesBucket): Promise<number>
    return this.rdbStore.insert(table, values)
  }

  // 封装CRUD：改 update
  /*
  参数注释
  table：表名
  field：字段名
  type：字段类型
  value：修改后的字段值
  *
  返回值 Promise<number>：如果操作成功，返回行ID；否则返回-1。
  */
  update(table: string, field: string, type: ValueType, value: string): Promise<number> {
    if (!this.rdbStore) {
      throw new Error('RdbStore is not initialized');
    }

    let data: relationalStore.ValuesBucket = { value }
    // 由于 update 只接受 ValuesBucket，必须先通过 id 找到数据行 ValuesBucket
    let predicates = new relationalStore.RdbPredicates(table)
    predicates.equalTo(field, type)
    // 执行更新操作
    return this.rdbStore.update(data, predicates)
  }

  // 封装CRUD：删 delete（原理同上 update）
  /*
  参数注释
  table：表名
  field：字段名
  type：字段类型
  *
  返回值 Promise<number>：如果操作成功，返回行ID；否则返回-1。
  */
  delete(table: string, field: string, type: number): Promise<number> {
    if (!this.rdbStore) {
      throw new Error('RdbStore is not initialized');
    }

    let predicates = new relationalStore.RdbPredicates(table)
    predicates.equalTo(field, type)
    return this.rdbStore.delete(predicates)
  }
}

export default RdbService;