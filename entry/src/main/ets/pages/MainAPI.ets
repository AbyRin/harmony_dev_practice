@Entry
@Component
struct Test1 {
  @State imageWidth: number = 150

  build() {
    Column() {
      Row() {
        // 图片
        Image($r('app.media.asuka'))
          .width(this.imageWidth)
          .interpolation(ImageInterpolation.High)  // 抗锯齿：高
      }
      .width('100%')
      .height(400)
      .justifyContent(FlexAlign.Center)

      // 层叠布局
      Stack() {
        // 进度条
        Progress({
          value: this.imageWidth - 100,
          total: 200,
          type: ProgressType.Ring
        })
          .width(180)
          .style({strokeWidth: 12, shadow: true})
          .color(Color.Green)

        Column() {
          // 文本框
          Text($r('app.string.AsukaImage_label'))
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .margin({bottom: 10})

          Text()
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .margin({bottom: 10})

          // 文本输入框
          TextInput({text: this.imageWidth.toFixed(0)})
            .width(80)
            .type(InputType.Number)
            .textAlign(TextAlign.Center)
            .onChange(value => {
              this.imageWidth = parseInt(value)
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')

      // 分割线
      Divider()
        .width('90%')

      Row() {
        // 按钮
        Button('缩小')
          .width(80)
          .height(30)
          .backgroundColor(Color.Green)
          .onClick(() => {
            if (this.imageWidth >= 100) {
              this.imageWidth -= 10
            }
          })
        Button('放大')
          .width(80)
          .height(30)
          .backgroundColor(Color.Red)
          .onClick(() => {
            if (this.imageWidth <= 300) {
              this.imageWidth += 10
            }
          })
      }
      .width('100%')
      .margin({top: 24, bottom: 8})
      .justifyContent(FlexAlign.SpaceEvenly)

      // 滑动条
      Slider({
        min: 100,
        max: 300,
        value: this.imageWidth,
        step: 10,
        style: SliderStyle.OutSet,  // 滑块在滑动条外/内
        direction: Axis.Horizontal,
        reverse: false
      })
        .width('100%')
        .showTips(true)
        .blockColor(Color.Orange)  // 滑块颜色
        .onChange(value => {
          this.imageWidth = value
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }
}