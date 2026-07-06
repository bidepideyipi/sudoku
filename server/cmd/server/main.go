package main

import (
	"fmt"
	"log"
	"sudoku-server/internal/config"
	"sudoku-server/internal/handler"
	"sudoku-server/internal/repository"

	"github.com/gin-gonic/gin"
)

func main() {
	// 加载配置
	cfg, err := config.Load("config.yml")
	if err != nil {
		log.Fatal("Failed to load config:", err)
	}

	// 初始化数据库
	repo, err := repository.NewPuzzleRepository(cfg.DB.Path)
	if err != nil {
		log.Fatal("Failed to initialize repository:", err)
	}
	defer repo.Close()

	// 创建 Gin 路由
	r := gin.Default()

	// 注册处理器
	puzzleHandler := handler.NewPuzzleHandler(repo)

	// 路由配置
	api := r.Group("/api/v1/sudoku")
	{
		api.POST("/puzzle/batch", puzzleHandler.Batch)
	}

	// 启动服务
	addr := fmt.Sprintf(":%d", cfg.Server.Port)
	log.Printf("Server starting on %s", addr)
	if err := r.Run(addr); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}
