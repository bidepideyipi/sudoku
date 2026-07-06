# 数独题库服务端

Go + Gin + SQLite 实现的数独题库服务。

## 项目结构

```
server/
├── cmd/server/          # 主入口
├── internal/
│   ├── handler/        # HTTP 处理器
│   ├── model/          # 数据模型
│   ├── repository/     # 数据库操作
│   ├── generator/      # 数独生成器
│   └── config/         # 配置读取
├── config.yml          # 配置文件
├── go.mod
└── README.md
```

## 快速开始

### 1. 安装依赖
```bash
cd server
go mod download
```

### 2. 配置
编辑 `config.yml` 配置文件：
```yaml
server:
  port: 9000
db:
  path: ./puzzles.db
```

### 3. 生成题库
```bash
go test -v -run TestGeneratePuzzles ./internal/generator/
```

### 4. 编译运行
```bash
go build -o bin/server ./cmd/server
./bin/server
```

### 5. 测试 API
```bash
curl -X POST http://localhost:9000/api/v1/sudoku/puzzle/batch \
  -H "Content-Type: application/json" \
  -d '{"difficulty": 1, "count": 3}'
```

## API 说明

### 批量拉取题目
- **路径**: `POST /api/v1/sudoku/puzzle/batch`
- **请求**:
  ```json
  {
    "difficulty": 1,  // 难度: 1=简单, 2=中等, 3=困难, 4=专家
    "count": 50       // 数量: 1-500
  }
  ```
- **响应**:
  ```json
  {
    "code": 0,
    "message": "success",
    "data": {
      "puzzles": [...],
      "total": 50
    }
  }
  ```

## 核心功能

- **数独生成**: 回溯算法生成完整终盘，按难度挖空
- **唯一解验证**: 确保每题有且仅有一个解
- **SQLite 存储**: 生成的题目持久化到本地数据库
- **分离架构**: 生成与查询分离，预生成题库

## 错误码

| 错误码 | 说明 |
|--------|------|
| 0 | 成功 |
| 1001 | 题库存量不足 |
| 1002 | 参数错误 |
| 1003 | 难度等级无效 |
| 2001 | 服务内部错误 |
