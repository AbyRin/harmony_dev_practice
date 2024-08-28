// 类：任务
@Observed
export class Task {
  id: number
  name: string  // 任务名称
  finished: boolean  // 任务状态

  constructor(id: number, name: string) {
    this.id = id
    this.name = name
    this.finished = false
  }
}

// 类：任务统计信息
@Observed
export class TaskCount {
  totalTask: number  // 总任务数
  finishTask: number  // 已完成任务数

  constructor(totalTask: number, finishTask: number) {
    this.totalTask = totalTask
    this.finishTask = finishTask
  }
}