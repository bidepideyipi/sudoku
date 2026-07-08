# Widgets 调用关系

## 调用层级图

```
┌─────────────────────────────────────────────────────────────────┐
│                        SudokuHomePage                          │
│                     (主页面 - 入口组件)                          │
└──────────────────────────┬────────────────────────────────────┘
                           │
           ┌───────────────┼───────────────┐
           │               │               │
           ▼               ▼               ▼
┌──────────────────┐ ┌─────────────┐ ┌──────────────────┐
│   GameHeader     │ │ SudokuBoard │ │ ControlButtons   │
│  (游戏头部)      │ │ (棋盘容器)  │ │  (控制按钮组)     │
└──────────────────┘ └──────┬──────┘ └──────────────────┘
                            │
                            ▼
                    ┌──────────────┐
                    │ SudokuGrid   │
                    │ (9×9 网格)   │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │SudokuCellWidget│ (×81)
                    │ (单个单元格)  │
                    └──────────────┘
```

## 组件说明

| 层级 | Widget | 职责 |
|------|--------|------|
| **页面层** | `SudokuHomePage` | 主入口，协调所有子组件，连接 Provider |
| **容器层** | `SudokuBoard` → `SudokuGrid` | 棋盘容器 → 网格布局 |
| **叶子层** | `SudokuCellWidget` | 单个格子，渲染状态（选中/冲突/高亮） |
| **功能层** | `GameHeader`, `ControlButtons` | 头部信息、操作按钮 |

## 调用链详解

1. **SudokuHomePage** (页面层)
   - 使用 `Consumer<SudokuGameProvider>` 获取状态
   - 调用 `GameHeader` - 显示游戏头部（标题、难度、进度条）
   - 调用 `SudokuBoard` - 数独棋盘容器
   - 调用 `ControlButtons` - 控制按钮（擦除、铅笔、验证、提示）
   - 使用内部组件 `_NumberPadSection` - 数字键盘（内嵌在页面中）

2. **SudokuBoard** (棋盘容器)
   - 调用 `SudokuGrid` - 9×9 网格

3. **SudokuGrid** (9×9 网格)
   - 调用 `SudokuCellWidget` - 单个单元格（81 个）

4. **SudokuCellWidget** (单个单元格)
   - 叶子节点，不调用其他 widgets

5. **GameHeader** (游戏头部)
   - 叶子节点，不调用其他 widgets

6. **ControlButtons** (控制按钮)
   - 叶子节点，不调用其他 widgets

## 注意点

- `number_pad.dart` 文件存在但未被使用，当前数字键盘是 `SudokuHomePage` 中的内部组件 `_NumberPadSection`
- 所有 widget 都是 `StatelessWidget`，状态由 `SudokuGameProvider` 集中管理
