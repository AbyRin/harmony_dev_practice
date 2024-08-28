import { router } from '@kit.ArkUI'
import { Header, TabBar } from '../common/components/CommonComponents'
import PreferencesUtil from '../common/util/PreferencesUtil'

// 样式：浅绿色文字
@Extend(Text) function GreenText() {
  .fontSize(20)
  .fontWeight(FontWeight.Bold)
  .fontColor($r('app.color.PRIMARY_GREEN_LIGHT'))
}
// 样式：浅灰色文字
@Extend(Text) function grayText() {
  .fontSize(20)
  .fontWeight(FontWeight.Bold)
  .fontColor($r('app.color.PRIMARY_GRAY_4'))
}

// 类：路由信息
class RouterInfo {
  url: string  // 页面路径
  title: string  // 页面标题

  constructor(url: string, title: string) {
    this.url = url
    this.title = title
  }
}

@Entry
@Component
struct Index {
  @Provide fontSize: number = 16
  @State showPanel: boolean = false

  async aboutToAppear() {
    this.fontSize = await PreferencesUtil.getPreferenceValue('MyPreferences', 'FontSize', 16) as number
  }

  build() {
    Column() {
      // 组件：标题
      Header()

      // 组件：路由列表
      RouterList()

      // 组件：字体调节面板
      FontSizePanel()

      // 组件：底部导航栏
      TabBar()
    }
    .height('100%')
    .width('100%')
    .backgroundColor($r('app.color.PRIMARY_GRAY_0'))
  }
}

// 组件：标题
// @Component
// struct Header {
//   build() {
//     Text('主页 | 目录')
//       .GreenText()
//       .fontSize(36)
//       .margin(16)
//   }
// }

// 组件：路由列表
@Component
struct RouterList {
  private routers: RouterInfo[] = [
    new RouterInfo('pages/MainAPI', '主要API'),
    new RouterInfo('pages/ItemPage', '商品列表'),
    new RouterInfo('pages/TaskProgress', '任务进度条'),
    new RouterInfo('pages/Net', '网络请求'),
    new RouterInfo('pages/DB', '数据持久化'),
  ]

  build() {
    List({space: 15}) {
      // 循环控制
      ForEach(
        // （1）要遍历的数组
        this.routers,
        (router: RouterInfo, index: number) => {
          // （2）渲染页面组件
          ListItem() {
            RouterItem({routerInfo: router, index: index + 1})
          }
        }
      )
    }
    .layoutWeight(1)  // 类似flex(1)，各个 dom 按比例分配占满剩余空间
    .alignListItem(ListItemAlign.Center)
    .width('100%')
    .height('100%')
  }
}

// 组件：路由单元
@Component
struct RouterItem {
  @Prop routerInfo: RouterInfo
  @Prop index: number  // 选中路由序号
  @Consume fontSize: number

  build() {
    Row() {
      Text(this.index + '.')
        .grayText()
        .fontSize(this.fontSize)
      Blank()  // 自动填满剩余空间
      Text(this.routerInfo.title)
        .grayText()
        .fontSize(this.fontSize)
    }
    .width('90%')
    .backgroundColor($r('app.color.PRIMARY_GRAY_1'))
    .padding(12)
    .borderRadius(20)
    .onClick(() => {
      // 路由跳转
      router.pushUrl(
        {
          url: this.routerInfo.url,
          params: {id: 1}  // 携带参数
        },
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

// 组件：字体调节面板
// 类：字体尺寸模板
class FontSizeTemplate {
  size: number  // 页面路径
  name: string  // 页面标题

  constructor(size: number, name: string) {
    this.size = size
    this.name = name
  }
}
@Component
struct FontSizePanel {
  @Consume fontSize: number
  // 字体尺寸模板
  fontSizeTemplate: Array<FontSizeTemplate> = [
    new FontSizeTemplate(14, '小'),
    new FontSizeTemplate(16, '标准'),
    new FontSizeTemplate(18, '大'),
    new FontSizeTemplate(20, '特大')
  ]

  build() {
    Column() {
      // ArkTS规则：加上?来确保不会是 undefined，且可以设置 undefined 时显示的值
      Text(this.fontSizeTemplate.find(item => item.size === this.fontSize)?.name || '无法匹配字体尺寸')
        .fontSize(20)
      Row({ space: 5 }) {
        Text('A')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
        Slider({
          min: 14,
          max: 20,
          step: 2,
          value: this.fontSize
        })
          .showSteps(true)
          .trackThickness(6)
          .layoutWeight(1)
          .onChange(value => {
            // 修改字体大小
            this.fontSize = value
            // 写入用户偏好Preferences
            // 注意：预览器无法检验该功能的实现，请使用模拟器
            PreferencesUtil.putPreferenceValue('MyPreferences', 'FontSize', value)
          })
        Text('A').fontSize(20).fontWeight(FontWeight.Bold)
      }.width('100%')
    }
    .width('100%')
    .padding(15)
    .backgroundColor('#fff1f0f0')
    .borderRadius(20)
  }
}