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

func TestGeneratePuzzles(t *testing.T) {
	tasks := []struct {
		difficulty model.Difficulty
		count      int
	}{
		{model.Easy, 100},
		{model.Medium, 100},
		{model.Hard, 100},
		{model.Expert, 20},
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
		generatedCount := 0
		for generatedCount < needed {
			currentBatch := batchSize
			if generatedCount+batchSize > needed {
				currentBatch = needed - generatedCount
			}

			puzzles, successCount := generateBatch(gen, task.difficulty, currentBatch)
			if len(puzzles) > 0 {
				if err := repo.SaveBatch(puzzles); err != nil {
					log.Printf("  保存失败: %v", err)
					continue
				}
			}

			generatedCount += successCount
			total += successCount
			fmt.Printf("  已生成: %d/%d\n", generatedCount, needed)

			// 如果这批全部失败，避免死循环
			if successCount == 0 {
				fmt.Printf("    警告: 连续生成失败，跳过剩余\n")
				break
			}
		}

		// 验证最终数量
		final, _ := repo.CountByDifficulty(task.difficulty)
		elapsed := time.Since(stepStart)
		fmt.Printf("  完成，当前题库数量: %d，耗时: %v\n", final, elapsed)
	}

	fmt.Printf("\n生成完成！总计新增: %d 道题目\n", total)
}

func generateBatch(gen *SudokuGenerator, difficulty model.Difficulty, count int) ([]model.Puzzle, int) {
	puzzles := make([]model.Puzzle, 0, count)
	failedCount := 0

	for i := 0; i < count; i++ {
		puzzle, err := gen.Generate(difficulty)
		if err != nil {
			failedCount++
			continue
		}
		puzzles = append(puzzles, *puzzle)
	}

	successCount := count - failedCount
	if failedCount > 0 {
		fmt.Printf("    警告: %d 个生成失败\n", failedCount)
	}

	return puzzles, successCount
}
