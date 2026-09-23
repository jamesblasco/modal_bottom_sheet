# Android Cupertino 转场优化

基于上游 `4f2bbf33f9e5a13fbcd91aa53b2a878d85ab6010`。保留 Cupertino 的背景缩放、圆角、顶部位移、拖拽回弹和原有动画时长；改动位于 `modal_bottom_sheet` 包，不涉及同仓库的 `sheet` 包。

## 实现

| 开销 | 处理方式 |
| --- | --- |
| 背景变换逐帧重建 widget | RenderTransform 直接监听动画，沿用 Flutter 的命中测试、语义坐标和合成层实现 |
| 圆角逐帧重建 | CustomClipper 的 reclip 驱动绘制更新，保留原有半径插值 |
| 静态背景反复绘制 | 背景内容使用独立 RepaintBoundary；内容自身发生变化时仍正常更新 |
| 重复构造 CupertinoThemeData | 依赖变化时计算主题；起止颜色相同时复用主题，确实需要插值时保留动画路径 |
| 键盘触发无关转场重建 | 顶部安全区读取改用 MediaQuery.paddingOf |
| 弹层外壳与手势子树逐帧构建 | 移除路由外层重复动画 builder，复用手势子树；关闭权限在手势时查询 |
| 前景滑动与回弹逐帧创建布局 widget / delegate | SingleChildLayoutDelegate 的 relayout 直接监听进出场控制器与回弹动画，跳过这两处 build；曲线在布局时读取，保留拖动线性跟手与松手后的衔接 |
| 动画监听和控制器未释放 | 复用回弹动画，显式释放自有控制器，解绑渲染层监听 |
| 多个弹窗抢写同一背景控制器 | CupertinoScaffold 汇总存活路由的最大进度，值不变时不通知，保留监听直到 route.completed |

没有截图冻结背景、修改渲染引擎或缩短动画。RepaintBoundary 只隔离绘制，不会暂停后台业务、视频或其他自主动画。动态背景仍可能消耗帧预算。

前景仍需要布局和合成；回弹会改变子内容的高度约束，不能直接替换成仅绘制位移。控制器替换、expanded 改变和内容尺寸变化仍触发布局；监听的接入、换源和解绑由 Flutter 的 RenderCustomSingleChildLayoutBox 管理。普通业务重建仍正常执行 containerBuilder。此改动也作用于共用 ModalBottomSheet 的 Material / Bar 弹层，需要一并回归。

## 本地接入

在使用方的 `pubspec_overrides.yaml` 中添加下面的覆盖，path 指向本仓库内的包目录：

```yaml
dependency_overrides:
  modal_bottom_sheet:
    path: /absolute/path/to/modal_bottom_sheet/modal_bottom_sheet
```

使用项目固定的 Flutter SDK 执行 `flutter pub get`，检查 `.dart_tool/package_config.json` 中 `modal_bottom_sheet` 的 rootUri 指向该目录。之后进行完整重启；仅热重载不足以确认依赖切换。

发布时使用 Git dependency 的 `path: modal_bottom_sheet` 和固定 commit SHA，避免依赖浮动分支。本次没有修改使用方 App 的依赖。

## 验证

本次仅做静态分析和差异检查，没有运行 App、构建包或测得真机帧耗时。新增回归用例尚需运行：

```sh
# 在 modal_bottom_sheet 包目录，使用与 App 相同的 Flutter SDK
flutter test test/bottom_sheet_test.dart
```

现有测试覆盖背景变换几何和命中、静态背景构建/绘制次数、监听换源及卸载、键盘变化、多层弹窗、容器构建次数、动态 PopScope。它们验证实现约束，不能替代设备性能数据。

前景回归用例另覆盖进出场坐标、运行中切换曲线、expanded 变化、控制器换源/卸载，以及真实上拉回弹时的几何和布局 widget 复用。这些用例已通过静态分析，但按使用方要求未执行 Flutter test 或构建。

真机对照应使用同一 Android 设备、相同刷新率、同一业务页面和 profile 模式，分别运行上游基线与当前分支：

1. 单层弹窗首次打开单独记录；预热后连续打开/关闭至少 20 次。
2. 第一层打开第二层，关闭第二层，再关闭第一层；同时覆盖同一 CupertinoScaffold 上下文快速连续打开的场景。
3. 长列表滚动到顶部后下拉关闭、拖动取消、系统返回、PopScope 禁止/允许关闭。
4. 输入框键盘开关、横竖屏变化，以及弹窗尚在退场时移除底层页面。

通过 DevTools Performance 记录相同交互区间的 UI / Raster 耗时、P95 / P99、超预算帧数。60 / 90 / 120 Hz 的单阶段预算约为 16.67 / 11.11 / 8.33 ms；分别查看 UI 和 Raster，而不是把两者相加。两版各重复三轮，不把空闲帧或调试模式的编译开销混入比较。

若 UI 耗时下降但 Raster 仍超预算，应继续定位具体页面的动态内容、阴影和图片绘制成本；不能据此声称库层优化已解决所有掉帧。iOS 的浅色/深色、嵌套弹层和拖拽也需要回归，因为共用基础实现。
