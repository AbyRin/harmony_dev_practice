import { Task, TaskCount } from '../viewmodel/TaskInfo'
import TaskModel from '../model/TaskModel'

// 公共样式：任务卡片
@Styles function taskCard() {
  .width('95%')
  .padding(16)
  .backgroundColor($r('app.color.PRIMARY_GRAY_1'))
  .borderRadius(15)
}
// 公共样式：浅灰色文字
@Extend(Text) function grayText() {
  .fontSize(20)
  .fontWeight(FontWeight.Bold)
  .fontColor($r('app.color.PRIMARY_GRAY_4'))
}
// 公共样式：任务完成
@Extend(Text) function finishedTask() {
  .decoration({type:TextDecorationType.LineThrough, color: Color.White})
  .fontColor($r('app.color.PRIMARY_GRAY_2'))
}

// 状态管理
// @State 用于：父组件
// @Prop 用于：子组件，单向同步
// @Link 用于：子组件，双向同步
// @Provide/Consume 用于：跨组件，双向同步
// @ObjectLink/Observed 用于：嵌套对象/数组元素为对象，双向同步

@Entry
@Component
struct TaskProgress {
  @Provide taskCount: TaskCount = new TaskCount(0, 0)
  @Provide task: Task = new Task(0, '')

  build() {
    Column({space: 10}) {
      // 1.任务进度组件
      TaskProgressCard()  // 使用 Provide/Comsume 就不用传参了，代价是一点性能开销

      // 2.任务列表组件
      TaskListCard()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.PRIMARY_GRAY_0'))
  }
}

// 组件：任务进度
@Component
struct TaskProgressCard {
  @Consume taskCount: TaskCount

  build() {
    Row() {
      // 标题
      Text('任务进度')
        .grayText()
        .fontSize(30)  // 覆盖 mainText 的 fontSize
      // 进度条
      Stack() {
        Progress({
          value: this.taskCount.finishTask,
          total: this.taskCount.totalTask,
          type: ProgressType.Ring
        })
          .width(80)
          .backgroundColor($r('app.color.PRIMARY_GRAY_2'))
          .color($r('app.color.PRIMARY_GREEN_LIGHT'))
        Row() {
          Text(this.taskCount.finishTask.toString()) {}
          .fontSize(24)
          .fontColor($r('app.color.PRIMARY_GREEN_LIGHT'))
          Text('/' + this.taskCount.totalTask.toString())
            .fontSize(24)
            .fontColor(Color.White)
        }
      }
    }
    .taskCard()
    .margin({top: 20, bottom: 10})
    .justifyContent(FlexAlign.SpaceEvenly)
  }
}

// 组件：任务列表
@Component
struct TaskListCard {
  @State taskList: Task[] = []
  @Consume task: Task
  @Consume taskCount: TaskCount

  dialogController: CustomDialogController = new CustomDialogController({
    builder: TaskInfoDialog({
      onTaskConfirm: (): void => this.handleAddTask(this.task.name)
    })
  })
  
  aboutToAppear(): void {
    // 查询任务列表
    console.log('testTag', '初始化组件，查询任务列表')
    TaskModel.getTaskList()
      .then(res => this.taskList = res)
    // 更新任务状态
    this.handleTaskChange()
  }

  // 函数：更新任务数据
  handleTaskChange() {
    // 更新任务总数
    this.taskCount.totalTask = this.taskList.length
    // 更新已完成任务数量
    this.taskCount.finishTask = this.taskList.filter(item => item.finished).length
  }

  // 添加任务
  handleAddTask(name: string){
    // 1.新增任务
    TaskModel.addTask(name)
      .then(id => {
        console.log('testTag', '处理新增任务: ', name)
        // 回显到数组页面
        this.taskList.push(new Task(id, name))
        // 2.更新任务完成状态
        this.handleTaskChange()
        // 3.关闭对话框
        this.dialogController.close()
      })
      .catch((err: Error) => console.log('testTag', '新增任务失败：', name, JSON.stringify(err)))
  }

  build() {
    Column() {
      // 新增任务按钮
      Button('新增任务 +')
        .width(200)
        .backgroundColor($r('app.color.PRIMARY_GREEN_LIGHT'))
        .fontColor($r('app.color.PRIMARY_GRAY_1'))
        .fontWeight(FontWeight.Bold)
        .fontSize(18)
        .margin({bottom: 20})
        .onClick(() => {
          // 弹窗：添加任务
          this.dialogController.open()
        })

      // 任务列表
      List({space: 10}) {
        ForEach(
          this.taskList,
          (item: Task, index) => {  // 数组元素是对象，监听其属性要用 @Observed + @ObjectLink
            ListItem() {
              TaskItem({item: item, onTaskChange: (): void => this.handleTaskChange()})
              // 传递方法不加括号，不然就变调用了
              // 父组件传递方法给子组件，子组件的this指向自己导致找不到taskList
              // 解决1：用bind()将this指针绑定在父组件（注：失效！）
              // 解决2：改为传递this.handleTaskChange()，要加返回类型和调用的括号！

            }
            // start/end：向右/左滑动，在左/右边出现传入的构造函数
            .swipeAction({end: this.DeleteButton(index, item.id)})
          }
        )
      }
      .width('100%')
      .height('auto')
      .layoutWeight(1)
      .alignListItem(ListItemAlign.Center)
    }
  }

  // 构造函数：删除任务
  @Builder DeleteButton(index: number, id: number) {
    Row() {
      Image($r('app.media.ic_public_delete_filled'))
        .fillColor($r('app.color.PRIMARY_RED'))
        .width(28)
        .onClick(() => {
          // TaskModel.deleteTaskById(this.taskList[index].id)  // 方法1
          TaskModel.deleteTaskById(id)
            .then(() => {
              this.taskList.splice(index, 1)
              console.log('testTag', `尝试删除任务，index: ${index}`)
              this.handleTaskChange()
            })
            .catch((err: Error) => console.log('testTag', '删除任务失败，id = ', id, JSON.stringify(err)))
        })
    }
    .margin({left: 8})
  }
}

// 组件：任务卡片
@Component
struct TaskItem {
  @ObjectLink item: Task
  onTaskChange: () => void = () => {}

  build() {
    Row() {
      if (this.item.finished) {
        Text(this.item.name)
          .grayText()
          .finishedTask()  // 任务完成样式
      } else {
        Text(this.item.name)
          .grayText()
      }
      Checkbox()
        .select(this.item.finished)
        .selectedColor($r('app.color.PRIMARY_GREEN_LIGHT'))
        .onChange(value => {
          TaskModel.updateTaskStatus(this.item.id, value)
            .then(() => {
              // 更新任务状态和已完成任务数量
              this.item.finished = value
              this.onTaskChange()
            })
            .catch((err: Error) => console.log('testTag', '更新任务状态失败，id = ', this.item.id, JSON.stringify(err)))
        })
    }
    .taskCard()
    .justifyContent(FlexAlign.SpaceBetween)
  }
}

// 任务编辑弹窗
@CustomDialog
struct TaskInfoDialog {
  name: string = ''
  // controller?: CustomDialogController
  controller: CustomDialogController = new CustomDialogController({
    builder: TaskInfoDialog()
  })

  onTaskConfirm: (name: string) => void = () => {}

  build() {
    Column({space: 20}) {
      TextInput({placeholder: '输入任务名'})
        .onChange(value => this.name = value)
      Row(){
        Button('确定')
          .onClick(() => {
            if (this.controller != undefined) {
              this.onTaskConfirm(this.name)
            }
          })
        Button('取消')
          .backgroundColor(Color.Grey)
          .onClick(() => {
            if (this.controller != undefined) {
              this.controller.close()
            }
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
    }
    .width('100%')
    .padding(20)
  }
}