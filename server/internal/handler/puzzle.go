package handler

import (
	"net/http"
	"sudoku-server/internal/model"
	"sudoku-server/internal/repository"

	"github.com/gin-gonic/gin"
)

// PuzzleHandler 题目处理器
type PuzzleHandler struct {
	repo *repository.PuzzleRepository
}

// NewPuzzleHandler 创建处理器
func NewPuzzleHandler(repo *repository.PuzzleRepository) *PuzzleHandler {
	return &PuzzleHandler{
		repo: repo,
	}
}

// Batch 批量拉取题目
func (h *PuzzleHandler) Batch(c *gin.Context) {
	var req model.BatchRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusOK, model.Response{
			Code:    1002,
			Message: "参数错误",
		})
		return
	}

	// 从数据库获取题目
	puzzles, err := h.repo.FindByDifficulty(req.Difficulty, req.Count)
	if err != nil {
		c.JSON(http.StatusOK, model.Response{
			Code:    2001,
			Message: "服务内部错误",
		})
		return
	}

	// 检查是否有足够题目
	if len(puzzles) < req.Count {
		c.JSON(http.StatusOK, model.Response{
			Code:    1001,
			Message: "题库存量不足",
		})
		return
	}

	c.JSON(http.StatusOK, model.Response{
		Code:    0,
		Message: "success",
		Data: model.BatchResponse{
			Puzzles: puzzles[:req.Count],
			Total:   req.Count,
		},
	})
}
