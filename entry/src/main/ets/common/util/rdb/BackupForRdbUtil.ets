// import relationalStore from '@ohos.data.relationalStore';
import { relationalStore } from '@kit.ArkData'
import { Task } from '../../../model/TaskModel'

class TaskModel {
  private rdbStore: relationalStore.RdbStore = new relationalStore.getRdbStore()  // 初始化赋值待优化
  private tableName: string = 'TASK'  // 表名

  // 初始化任务表
  initTaskDB(context: Context) {
    // 1.rdb 数据库配置
    const config: relationalStore.StoreConfig = {
      name: 'MyApplication.db',  // 数据库名
      securityLevel: relationalStore.SecurityLevel.S1  // 数据库安全级别
    }
    // 2.初始化 SQL 语句
    const sql = `CREATE TABLE IF NOT EXISTS TASK (
                  ID INTEGER PRIMARY KEY AUTOINCREMENT,
                  NAME TEXT NOT NULL,
                  FINISHED bit
                 )`
    // 3.获取 rdb
    relationalStore.getRdbStore(context, config, (err, rdbStore) => {
      if (err) {
        console.log('testTag', '获取rdbStore失败！', err)
        return
      }
      // 执行 Sql
      // 初次建表后，由于以后表都存在，因此这句 sql 会执行，但没有效果（终止于 CREATE TABLE IF NOT EXISTS TASK）
      // 如果加 bindArgs: Array<ValueType> 参数，则可以传参，对于完整 SQL 则该参应该置为 空数组
      rdbStore.executeSql(sql, [], (err, res) => {
        if (err) {
          console.log('testTag', '表初始化失败', err)
        }
        console.log('testTag', '表初始化成功！', res)
      })
      // 保存 rdbStore
      this.rdbStore = rdbStore
    })
  }

  // 查询任务列表
  async getTaskList() {
    // 1.查询条件
    let predicates = new relationalStore.RdbPredicates(this.tableName)
    // 2.查询
    let result = await this.rdbStore.query(predicates, ['ID', 'NAME', 'FINISHED'])
    // 3.解析查询结果
    // 3.1.定义一个数组，组装最终的查询结果
    let taskList: Task[] = []
    // 3.2.遍历封装
    while(!result.isAtLastRow){
      // 3.3.指针移动到下一行
      result.goToNextRow()
      // 3.4.获取数据
      // getLong()，获取数字型数据，boolean 存储为 0/1 所以也用 getLong()
      let id = result.getLong(result.getColumnIndex('ID'))
      let name = result.getString(result.getColumnIndex('NAME'))
      let finished = result.getLong(result.getColumnIndex('FINISHED'))
      // 3.5.封装到数组
      // 不能直接传 finished，因为还是 0/1，取反2次即可变为 boolean
      // taskList.push({id, name, finished: !!finished})  // 警告：该写法不知为何有Bug，请勿替换
      let task = new Task(id, name);
      task.finished = !!finished;
      taskList.push(task);
    }
    console.log('testTag', '查询到数据：', JSON.stringify(taskList))
    return taskList
  }

  // 添加任务
  addTask(name: string): Promise<number> {
    return this.rdbStore.insert(this.tableName, {name, finished: false})
  }

  // 根据 id 更新任务状态
  updateTaskStatus(id: number, finished: boolean): Promise<number> {
    // 1.要更新的数据
    let data: relationalStore.ValuesBucket = {finished}
    // 2.更新的条件
    let predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('ID', id)
    // 3.更新操作
    // ValuesBucket类型：键值对，键为 string，值为 ValueType(number、string、boolean) | Uint8Array | null
    return this.rdbStore.update(data, predicates)
  }

  // 根据 id 删除任务
  deleteTaskById(id: number): Promise<number> {
    // 1.删除的条件
    let predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('ID', id)
    // 2.删除操作
    return this.rdbStore.delete(predicates)
  }
}

let taskModel = new TaskModel();
export default taskModel as TaskModel;