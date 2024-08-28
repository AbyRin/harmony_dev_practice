// 样式：浅绿色文字
import { router } from '@kit.ArkUI'

@Extend(Text) function TabBarFontGreen() {
  .fontSize(16)
  .fontWeight(FontWeight.Bold)
  .fontColor($r('app.color.PRIMARY_GREEN_LIGHT'))
}

// 样式：浅灰色文字
@Extend(Text) function TabBarFontGray() {
  .fontSize(16)
  .fontWeight(FontWeight.Bold)
  .fontColor($r('app.color.PRIMARY_GRAY_4'))
}

// 类：导航路由信息
class TabBarInfo {
  url: string  // 导航路径
  title: string  // 导航标题
  isSelected: boolean  // 是否选中

  constructor(url: string, title: string, isSelected: boolean = false) {
    this.url = url
    this.title = title
    this.isSelected = isSelected
  }
}

// 头部
@Component
export struct Header {
  @State headerTitle: ResourceStr = '头部标题'

  build() {
    Row() {
      Image($r('app.media.ic_public_back'))
        .width(30)
        .margin({right: 10})
      Text(this.headerTitle)
        .TabBarFontGreen()
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
      Blank()
      Image($r('app.media.ic_public_refresh'))
        .width(30)
    }
    .width('100%')
    .height('auto')
    .margin(12)
  }
}

// 底部导航栏
@Component
export struct TabBar {

  // 导航列表
  private tabBarRouter: TabBarInfo[] = [
    new TabBarInfo('pages/MainAPI', '主要API', false),
    new TabBarInfo('pages/ItemPage', '商品列表', false),
    new TabBarInfo('pages/TaskProgress', '任务进度条', false)
  ]

  build() {
    // 渲染底部导航栏
    List() {
      ForEach(
        this.tabBarRouter,
        (router: TabBarInfo) => {
          ListItem() {
            TabBarItem({
              tabBarInfo: router
            })
          }
        }
      )
    }
    .width('100%')
    .height(30)
    .listDirection(Axis.Horizontal)
    .alignListItem(ListItemAlign.Center)
    .backgroundColor($r('app.color.PRIMARY_GRAY_1'))
  }
}

// 组件：底部导航栏单元
@Component
struct TabBarItem {
  @Prop tabBarInfo: TabBarInfo
  @Prop isSelected: boolean

  build() {
    Column() {
      // 根据isSelected的值选择样式
      if (this.tabBarInfo.isSelected) {
        Text(this.tabBarInfo.title)
          .TabBarFontGreen()
      } else {
        Text(this.tabBarInfo.title)
          .TabBarFontGray()
      }
    }
    .width('auto')
    .height('auto')
    .backgroundColor($r('app.color.PRIMARY_GRAY_1'))
    .padding(12)
    .borderRadius(20)
    .onClick(() => {
      // 改变颜色
      this.tabBarInfo.isSelected = true
      // 路由跳转
      router.pushUrl(
        { url: this.tabBarInfo.url },
        router.RouterMode.Single,  // 路由模式
        err => {
          if (err) {
            console.log(`路由跳转失败，errCode: ${err.code}，errMessage: ${err.message}`)
          }
        }
      )
    })
  }
}