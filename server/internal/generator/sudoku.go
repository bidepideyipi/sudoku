package generator

import (
	"crypto/rand"
	"fmt"
	"math/big"
	"sudoku-server/internal/model"
	"time"
)

// SudokuGenerator 数独生成器
type SudokuGenerator struct{}

// NewSudokuGenerator 创建生成器
func NewSudokuGenerator() *SudokuGenerator {
	return &SudokuGenerator{}
}

// Generate 生成指定难度的数独题目
func (g *SudokuGenerator) Generate(difficulty model.Difficulty) (*model.Puzzle, error) {
	maxAttempts := 100
	if difficulty == model.Expert {
		maxAttempts = 5000 // 专家级需要更多尝试
	}

	for attempt := 0; attempt < maxAttempts; attempt++ {
		// 1. 生成完整终盘
		solution := g.generateFullGrid()

		// 2. 根据难度确定挖空数量
		holes := g.getHolesByDifficulty(difficulty)

		// 3. 逐步挖空并验证（每次挖空后检查）
		puzzle, ok := g.digHolesWithValidation(solution, holes)

		if ok {
			return &model.Puzzle{
				ID:         generateUUID(),
				Puzzle:     boardToString(puzzle),
				Solution:   boardToString(solution),
				Difficulty: difficulty,
				CreatedAt:  time.Now(),
			}, nil
		}
	}

	return nil, fmt.Errorf("生成失败，超过最大尝试次数")
}

// generateFullGrid 生成完整的9x9数独终盘
func (g *SudokuGenerator) generateFullGrid() [9][9]int {
	var board [9][9]int
	g.fillBoard(&board)
	return board
}

// fillBoard 用回溯法填充数独板
func (g *SudokuGenerator) fillBoard(board *[9][9]int) bool {
	empty := findEmpty(board)
	if empty == nil {
		return true
	}

	row, col := empty[0], empty[1]

	// 随机尝试1-9
	nums := shuffleNumbers()
	for _, num := range nums {
		if isValid(board, row, col, num) {
			board[row][col] = num
			if g.fillBoard(board) {
				return true
			}
			board[row][col] = 0
		}
	}

	return false
}

// digHoles 挖空指定数量的格子
func (g *SudokuGenerator) digHoles(board [9][9]int, holes int) [9][9]int {
	puzzle := board
	positions := shufflePositions()

	count := 0
	for _, pos := range positions {
		if count >= holes {
			break
		}
		row, col := pos[0], pos[1]
		if puzzle[row][col] != 0 {
			puzzle[row][col] = 0
			count++
		}
	}
	return puzzle
}

// digHolesWithValidation 挖空并逐步验证唯一解
func (g *SudokuGenerator) digHolesWithValidation(board [9][9]int, holes int) ([9][9]int, bool) {
	puzzle := board
	positions := shufflePositions()

	count := 0
	for _, pos := range positions {
		if count >= holes {
			break
		}
		row, col := pos[0], pos[1]
		if puzzle[row][col] != 0 {
			puzzle[row][col] = 0
			count++

			// 每挖空一定数量后验证唯一解
			if count%5 == 0 || count == holes {
				if !g.hasUniqueSolution(puzzle) {
					return board, false // 不满足唯一解
				}
			}
		}
	}
	return puzzle, true
}

// hasUniqueSolution 验证是否有唯一解
func (g *SudokuGenerator) hasUniqueSolution(board [9][9]int) bool {
	solutionCount := 0
	g.solveWithCount(board, &solutionCount)
	return solutionCount == 1
}

// solveWithCount 计算解的数量
func (g *SudokuGenerator) solveWithCount(board [9][9]int, count *int) bool {
	if *count > 1 {
		return false
	}

	empty := findEmpty(&board)
	if empty == nil {
		*count++
		return true
	}

	row, col := empty[0], empty[1]

	for num := 1; num <= 9; num++ {
		if isValid(&board, row, col, num) {
			board[row][col] = num
			g.solveWithCount(board, count)
			board[row][col] = 0
		}
	}

	return *count == 1
}

// getHolesByDifficulty 根据难度获取挖空数量
func (g *SudokuGenerator) getHolesByDifficulty(difficulty model.Difficulty) int {
	switch difficulty {
	case model.Easy:
		return 25
	case model.Medium:
		return 35
	case model.Hard:
		return 45
	case model.Expert:
		return 55
	default:
		return 25
	}
}

// 辅助函数

func findEmpty(board *[9][9]int) []int {
	for row := 0; row < 9; row++ {
		for col := 0; col < 9; col++ {
			if board[row][col] == 0 {
				return []int{row, col}
			}
		}
	}
	return nil
}

func isValid(board *[9][9]int, row, col, num int) bool {
	// 检查行
	for c := 0; c < 9; c++ {
		if board[row][c] == num {
			return false
		}
	}

	// 检查列
	for r := 0; r < 9; r++ {
		if board[r][col] == num {
			return false
		}
	}

	// 检查3x3宫
	startRow, startCol := (row/3)*3, (col/3)*3
	for r := startRow; r < startRow+3; r++ {
		for c := startCol; c < startCol+3; c++ {
			if board[r][c] == num {
				return false
			}
		}
	}

	return true
}

func shuffleNumbers() []int {
	nums := []int{1, 2, 3, 4, 5, 6, 7, 8, 9}
	for i := len(nums) - 1; i > 0; i-- {
		j, _ := rand.Int(rand.Reader, big.NewInt(int64(i+1)))
		nums[i], nums[j.Int64()] = nums[j.Int64()], nums[i]
	}
	return nums
}

func shufflePositions() [][]int {
	positions := make([][]int, 81)
	idx := 0
	for row := 0; row < 9; row++ {
		for col := 0; col < 9; col++ {
			positions[idx] = []int{row, col}
			idx++
		}
	}
	for i := len(positions) - 1; i > 0; i-- {
		j, _ := rand.Int(rand.Reader, big.NewInt(int64(i+1)))
		positions[i], positions[j.Int64()] = positions[j.Int64()], positions[i]
	}
	return positions
}

func boardToString(board [9][9]int) string {
	var result string
	for row := 0; row < 9; row++ {
		for col := 0; col < 9; col++ {
			result += fmt.Sprintf("%d", board[row][col])
		}
	}
	return result
}

func randRange(min, max int) int {
	n, _ := rand.Int(rand.Reader, big.NewInt(int64(max-min+1)))
	return min + int(n.Int64())
}

func generateUUID() string {
	b := make([]byte, 16)
	rand.Read(b)
	b[6] = (b[6] & 0x0f) | 0x40
	b[8] = (b[8] & 0x3f) | 0x80
	return fmt.Sprintf("%x-%x-%x-%x-%x", b[0:4], b[4:6], b[6:8], b[8:10], b[10:])
}
