// 快捷笔记：状态管理
import { Task, TaskCount } from '../viewmodel/TaskInfo'
import { TaskProgressCard, TaskListCard, RdbTableCreateButton } from '../common/components/TaskProgressComponents'

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

  build() {
    Column({space: 10}) {
      // 1.任务进度组件
      TaskProgressCard()

      // 2.任务列表组件
      TaskListCard()

      // 临时按钮：创建任务表
      RdbTableCreateButton()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.PRIMARY_GRAY_0'))
  }
}