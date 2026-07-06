package generator

import (
	"fmt"
	"log"
	"sudoku-server/internal/config"
	"sudoku-server/internal/model"
	"sudoku-server/internal/repository"
	"testing"
	"time"
)

// 生成题库工具
// 运行方式: go test -v -run TestGeneratePuzzles ./internal/generator/
// 或直接运行: go run internal/generator/generator_tool.go

func TestGeneratePuzzles(t *testing.T) {
	tasks := []struct {
		difficulty model.Difficulty
		count      int
	}{
		{model.Easy, 15},
		{model.Medium, 15},
		{model.Hard, 15},
		{model.Expert, 1},
	}

	// 从配置文件读取数据库路径
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

	// 清空已有数据
	if err := repo.ClearAll(); err != nil {
		log.Fatal("Failed to clear database:", err)
	}
	fmt.Println("已清空数据库")

	gen := NewSudokuGenerator()

	total := 0
	for _, task := range tasks {
		fmt.Printf("正在生成难度 %d 的题目...\n", task.difficulty)
		stepStart := time.Now()

		// 检查现有数量
		existing, _ := repo.CountByDifficulty(task.difficulty)
		fmt.Printf("  现有题目: %d\n", existing)

		if existing >= task.count {
			fmt.Printf("  已有足够题目，跳过生成\n")
			continue
		}

		needed := task.count - existing
		fmt.Printf("  需要生成: %d\n", needed)

		// 生成并保存
		batchSize := 10
		for i := 0; i < needed; i += batchSize {
			currentBatch := batchSize
			if i+batchSize > needed {
				currentBatch = needed - i
			}

			puzzles := generateBatch(gen, task.difficulty, currentBatch)
			if err := repo.SaveBatch(puzzles); err != nil {
				log.Printf("  保存失败: %v", err)
				continue
			}

			total += currentBatch
			fmt.Printf("  已生成: %d/%d\n", i+currentBatch, needed)
		}

		// 验证最终数量
		final, _ := repo.CountByDifficulty(task.difficulty)
		elapsed := time.Since(stepStart)
		fmt.Printf("  完成，当前题库数量: %d，耗时: %v\n", final, elapsed)
	}

	fmt.Printf("\n生成完成！总计新增: %d 道题目\n", total)
}

func generateBatch(gen *SudokuGenerator, difficulty model.Difficulty, count int) []model.Puzzle {
	puzzles := make([]model.Puzzle, 0, count)

	for i := 0; i < count; i++ {
		puzzle, err := gen.Generate(difficulty)
		if err != nil {
			continue
		}
		puzzles = append(puzzles, *puzzle)
	}

	return puzzles
}
