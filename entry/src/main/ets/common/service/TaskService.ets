import RdbService from '../util/rdb/RdbService'
import { ValuesBucket } from '@kit.ArkData';
import EntryAbility from '../../entryability/EntryAbility'
import { Task, TaskCount } from '../../model/TaskModel';

const calculateFinishedTasks = (taskList: Task[]): number => {
  return taskList.filter(task => task.isCompleted).length;
}

class TaskService {
  // 实例化 rdbStore
  private rdbStore = new EntryAbility().rdbStore
  private TABLE = 'TASK'
  private SQL = `CREATE TABLE IF NOT EXISTS TASK (
                  ID INTEGER PRIMARY KEY AUTOINCREMENT,
                  NAME TEXT NOT NULL,
                  FINISHED bit
                 )`

  // 获取任务列表
  async getTaskList(): Promise<Task[]> {
    try {
      const records: Record<string, string>[] = await this.rdbStore.get(this.TABLE, []);
      const taskList: Task[] = records.map(record => {
        return {
          id: record.id.toString(),
          name: record.name,
          finished: record.finished
        } as Task;
      });
      return taskList;
    } catch (err) {
      console.error('Failed to get task list:', err);
      throw new Error;
    }
  }

  // 获取任务统计信息
  getTaskCount() {

  }

  // 添加任务
  async addTask(name: string): Promise<number> {
    const values: ValuesBucket = {
      NAME: name,
      FINISHED: 0
    };
    return this.add('TASK', values);
  }
}

export default TaskService;