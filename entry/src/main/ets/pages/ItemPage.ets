import { Header } from '../common/components/CommonComponents'

// 全局自定义构件函数
// 商品卡片
// @Builder
// function ItemCard(item: Item) {
//   Row({space: 10}) {
//     // 商品图
//     Image(item.image)
//       .width(100)
//       .borderRadius(12)
//     // 商品信息
//     Column({space: 4}) {
//       // 有折扣
//       if (item.discount) {
//         Text(item.name)
//           .fontSize(20)
//           .fontWeight(FontWeight.Bold)
//         Text('原价：￥' + item.price)
//           .fontColor(Color.Gray)
//           .fontSize(12)
//           .decoration({type: TextDecorationType.LineThrough})
//         Text('折扣价：￥' + (item.price - item.discount))
//           .fontColor(Color.Red)
//           .fontSize(16)
//         Text('补贴：￥' + item.discount)
//           .fontColor(Color.Orange)
//           .fontSize(16)
//       } else {  // 无折扣
//         Text(item.name)
//           .fontSize(20)
//           .fontWeight(FontWeight.Bold)
//         Text('￥' + item.price)
//           .fontColor(Color.Orange)
//           .fontSize(16)
//       }
//     }
//     .height('100%')
//     .alignItems(HorizontalAlign.Start)
//   }
//   .width('100%')
//   .height(120)
//   .backgroundColor('#FFF')
//   .borderRadius(20)
//   .padding(10)
// }

// 全局自定义公共样式
// @Styles
// function fillScreen() {
//   .width('100%')
//   .height('100%')
//   .backgroundColor('#EFEFEF')
//   .padding(20)
// }

// （只能全局）公共继承样式，因为 @Styles 里的属性必须是组件通用属性，而 font 类是 text 特有的
@Extend(Text)
function priceText() {
  .fontColor('#F36')
  .fontSize(14)
}

// 商品类
class Item {
  name: string
  image: ResourceStr
  price: number
  discount: number

  constructor(name: string, image: ResourceStr, price: number, discount: number = 0) {
    this.name = name
    this.image = image
    this.price = price
    this.discount = discount
  }
}

@Entry
@Component
struct ItemPage {
  // 商品数据
  private items: Array<Item> = [
    new Item('华为Mate60', $r('app.media.freeBudsPro3'),6999, 500),
    new Item('MateBookProX', $r('app.media.watchGT4'),13999),
    new Item('WatchGT4', $r('app.media.mateX5'),1438),
    new Item('FreeBuds Pro3', $r('app.media.mateBookProX'),1499),
    new Item('Mate X5', $r('app.media.mate60'),12999),
    new Item('华为Mate60', $r('app.media.freeBudsPro3'),6999, 500),
    new Item('MateBookProX', $r('app.media.watchGT4'),13999),
    new Item('WatchGT4', $r('app.media.mateX5'),1438),
    new Item('FreeBuds Pro3', $r('app.media.mateBookProX'),1499),
    new Item('Mate X5', $r('app.media.mate60'),12999)
  ]

  build() {
    Column({space: 8}) {
      // List 组件：自带滚动效果
      List({space: 8}) {
        // 循环遍历渲染
        ForEach(
          this.items,
          (item: Item) => {  // 此处加上 Item 类型便于系统识别到 item 中有哪些属性，进而产生编码提示
            ListItem() {
              this.ItemCard(item)  // ItemCard 是定义在组件内的局部构件函数，要加 this 指针引用
            }
          }
        )
      }
      .width('100%')
      .height('100%')
      .layoutWeight(1)  // 空间占比，类似 flex(1)
    }
    .fillScreen()  // 自定义公共样式
  }

  // 局部自定义构件函数，无 function 关键字
  // 商品卡片
  @Builder
  ItemCard(item: Item) {
    Row({space: 10}) {
      // 商品图
      Image(item.image)
        .width(100)
        .borderRadius(12)
      // 商品信息
      Column({space: 4}) {
        // 有折扣
        if (item.discount) {
          Text(item.name)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
          Text('原价：￥' + item.price)
            .fontColor('#CCC')
            .fontSize(14)
            .decoration({type: TextDecorationType.LineThrough})
          Text('折扣价：￥' + (item.price - item.discount))
            .priceText()
          Text('补贴：￥' + item.discount)
            .priceText()
        } else {  // 无折扣
          Text(item.name)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
          Text('￥' + item.price)
            .priceText()
        }
      }
      .height('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('96%')
    .height(120)
    .backgroundColor('#FFF')
    .borderRadius(20)
    .padding(10)
  }

  // 局部自定义公共样式，无 function 关键字
  @Styles
  fillScreen() {
    .width('100%')
    .height('100%')
    .backgroundColor('#EFEFEF')
    .padding(16)
  }
}

