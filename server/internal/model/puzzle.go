package model

import "time"

// Difficulty 难度等级
type Difficulty int

const (
	Easy   Difficulty = 1
	Medium Difficulty = 2
	Hard   Difficulty = 3
	Expert Difficulty = 4
)

// Puzzle 数独题目
type Puzzle struct {
	ID          string     `json:"id"`
	Puzzle      string     `json:"puzzle"`      // 81位字符串，0表示空格
	Solution    string     `json:"solution"`    // 81位字符串，完整解答
	Difficulty  Difficulty `json:"difficulty"`
	CreatedAt   time.Time  `json:"createdAt"`
}

// BatchRequest 批量拉取请求
type BatchRequest struct {
	Difficulty Difficulty `json:"difficulty" binding:"required,min=1,max=4"`
	Count      int        `json:"count" binding:"required,min=1,max=500"`
}

// BatchResponse 批量拉取响应
type BatchResponse struct {
	Puzzles []Puzzle `json:"puzzles"`
	Total   int      `json:"total"`
}

// Response 通用响应结构
type Response struct {
	Code    int         `json:"code"`
	Message string      `json:"message"`
	Data    interface{} `json:"data,omitempty"`
}
