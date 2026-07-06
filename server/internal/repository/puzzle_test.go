package repository

import (
	"flag"
	"fmt"
	"log"
	"sudoku-server/internal/config"
	"testing"
)

var puzzleID string

func init() {
	flag.StringVar(&puzzleID, "id", "", "题目ID")
}

// TestPrintPuzzle 根据ID查询并打印题目
// 运行方式: go test -v -run TestPrintPuzzle ./internal/repository/ -id=<uuid>
func TestPrintPuzzle(t *testing.T) {
	flag.Parse()

	if puzzleID == "" {
		t.Skip("请指定题目ID: go test -v -run TestPrintPuzzle ./internal/repository/ -id=<uuid>")
		return
	}

	id := puzzleID

	// 加载配置
	cfg, err := config.Load("config.yml")
	if err != nil {
		log.Fatal("Failed to load config:", err)
	}

	// 初始化数据库
	repo, err := NewPuzzleRepository(cfg.DB.Path)
	if err != nil {
		log.Fatal("Failed to initialize repository:", err)
	}
	defer repo.Close()

	// 查询题目
	puzzle, err := repo.FindByID(id)
	if err != nil {
		log.Fatal("查询题目失败:", err)
	}

	// 格式化输出
	fmt.Printf("\nID: %s\n", puzzle.ID)
	fmt.Printf("难度: %d\n", puzzle.Difficulty)
	fmt.Println("题目:")
	printBoard(puzzle.Puzzle)
	fmt.Println("解答:")
	printBoard(puzzle.Solution)
}

// printBoard 格式化输出9x9网格
func printBoard(s string) {
	if len(s) != 81 {
		fmt.Println("无效的题目格式")
		return
	}

	fmt.Println("+-------+-------+-------+")
	for row := 0; row < 9; row++ {
		fmt.Print("| ")
		for col := 0; col < 9; col++ {
			char := s[row*9+col]
			if char == '0' {
				fmt.Print(". ")
			} else {
				fmt.Printf("%c ", char)
			}

			if col == 2 || col == 5 {
				fmt.Print("| ")
			}
		}
		fmt.Println("|")
		if row == 2 || row == 5 {
			fmt.Println("+-------+-------+-------+")
		}
	}
	fmt.Println("+-------+-------+-------+")
}
