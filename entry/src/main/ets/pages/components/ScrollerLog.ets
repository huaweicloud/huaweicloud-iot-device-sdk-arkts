// Copyright 2024 Huawei Cloud IoT Authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/**
 * 显示业务日志的组件
 */
@Component
export struct ScrollerLogComponent {
  @State logArr: string[] = [];
  private scroller: Scroller = new Scroller(); // 创建一个滚动控制器

  build() {
    Row() {
      Scroll(this.scroller) { // 绑定滚动控制器
        Column() {
          ForEach(this.logArr, (log: string) => { // ForEach语法循环创建子组件
            Text(log)
              .fontSize(12)
              .width('98%')
              .borderRadius(10)
              .backgroundColor(Color.White)
              .margin({ top: 10 })
          })
        }
        .width("100%")
      }
      .scrollable(ScrollDirection.Vertical) // 设置竖直方向滚动
      .scrollBarColor(Color.Gray) // 设置滚动条颜色
      .scrollBarWidth(10) // 设置滚动条宽度
      .scrollBar(BarState.On) // 设置滚动条永久显示
      .width('100%')
      .height(220)
      .padding({ top: 10, bottom: 10 })
      .border({ width: 0.5 })

      if (this.logArr.length > 0) {
        Button($r('app.string.clear_log'))
          .width(300)
          .margin({ top: 10 })
          .onClick(() => {
            this.logArr = []
          })
      }
    }
  }
}