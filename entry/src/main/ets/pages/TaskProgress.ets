import { Task, TaskCount } from '../model/TaskModel'
import { TaskProgressCard, TaskListCard } from '../common/components/TaskProgressComponents'
import TaskService from '../common/service/TaskService'

// 快捷笔记：状态管理
// @State 用于：父组件
// @Prop 用于：子组件，单向同步
// @Link 用于：子组件，双向同步
// @Provide/Consume 用于：跨组件，双向同步
// @ObjectLink/Observed 用于：嵌套对象/数组元素为对象，双向同步

@Entry
@Component
struct TaskProgressByRdb {
  @Provide taskCount: TaskCount = new TaskCount(0, 0)
  @Provide task: Task = new Task(0, '')

  aboutToAppear(): void {
    // 实例化
    const taskService = new TaskService()
    // 获取任务数统计信息
    this.taskCount = taskService.getTaskCount()
  }

  build() {
    Column({space: 10}) {
      // 1.任务进度组件
      TaskProgressCard()

      // 2.任务列表组件
      TaskListCard()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.PRIMARY_GRAY_0'))
  }
}