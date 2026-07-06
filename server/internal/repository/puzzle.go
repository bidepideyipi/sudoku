package repository

import (
	"database/sql"
	"sudoku-server/internal/model"
	"sync"
	"time"

	_ "github.com/mattn/go-sqlite3"
)

// PuzzleRepository 题目仓储
type PuzzleRepository struct {
	db *sql.DB
	mu sync.RWMutex
}

// NewPuzzleRepository 创建仓储
func NewPuzzleRepository(dbPath string) (*PuzzleRepository, error) {
	db, err := sql.Open("sqlite3", dbPath)
	if err != nil {
		return nil, err
	}

	repo := &PuzzleRepository{db: db}
	if err := repo.initTable(); err != nil {
		return nil, err
	}

	return repo, nil
}

// initTable 初始化数据表
func (r *PuzzleRepository) initTable() error {
	query := `
	CREATE TABLE IF NOT EXISTS puzzles (
		id TEXT PRIMARY KEY,
		puzzle TEXT NOT NULL,
		solution TEXT NOT NULL,
		difficulty INTEGER NOT NULL,
		created_at INTEGER NOT NULL
	);

	CREATE INDEX IF NOT EXISTS idx_difficulty ON puzzles(difficulty);
	`
	_, err := r.db.Exec(query)
	return err
}

// Save 保存题目
func (r *PuzzleRepository) Save(puzzle *model.Puzzle) error {
	r.mu.Lock()
	defer r.mu.Unlock()

	query := `
	INSERT INTO puzzles (id, puzzle, solution, difficulty, created_at)
	VALUES (?, ?, ?, ?, ?)
	`
	_, err := r.db.Exec(query, puzzle.ID, puzzle.Puzzle, puzzle.Solution, int(puzzle.Difficulty), puzzle.CreatedAt.Unix())
	return err
}

// SaveBatch 批量保存题目
func (r *PuzzleRepository) SaveBatch(puzzles []model.Puzzle) error {
	r.mu.Lock()
	defer r.mu.Unlock()

	tx, err := r.db.Begin()
	if err != nil {
		return err
	}

	stmt, err := tx.Prepare(`
		INSERT INTO puzzles (id, puzzle, solution, difficulty, created_at)
		VALUES (?, ?, ?, ?, ?)
	`)
	if err != nil {
		tx.Rollback()
		return err
	}
	defer stmt.Close()

	for _, puzzle := range puzzles {
		if _, err := stmt.Exec(puzzle.ID, puzzle.Puzzle, puzzle.Solution, int(puzzle.Difficulty), puzzle.CreatedAt.Unix()); err != nil {
			tx.Rollback()
			return err
		}
	}

	return tx.Commit()
}

// FindByDifficulty 按难度查找题目
func (r *PuzzleRepository) FindByDifficulty(difficulty model.Difficulty, limit int) ([]model.Puzzle, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()

	query := `
	SELECT id, puzzle, solution, difficulty, created_at
	FROM puzzles
	WHERE difficulty = ?
	ORDER BY RANDOM()
	LIMIT ?
	`

	rows, err := r.db.Query(query, int(difficulty), limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var puzzles []model.Puzzle
	for rows.Next() {
		var p model.Puzzle
		var createdAt int64
		err := rows.Scan(&p.ID, &p.Puzzle, &p.Solution, &p.Difficulty, &createdAt)
		if err != nil {
			return nil, err
		}
		p.CreatedAt = timeFromUnix(createdAt)
		puzzles = append(puzzles, p)
	}

	return puzzles, nil
}

// FindByID 根据ID查找题目
func (r *PuzzleRepository) FindByID(id string) (*model.Puzzle, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()

	query := `
	SELECT id, puzzle, solution, difficulty, created_at
	FROM puzzles
	WHERE id = ?
	`

	var p model.Puzzle
	var createdAt int64
	err := r.db.QueryRow(query, id).Scan(&p.ID, &p.Puzzle, &p.Solution, &p.Difficulty, &createdAt)
	if err != nil {
		return nil, err
	}
	p.CreatedAt = timeFromUnix(createdAt)
	return &p, nil
}

// CountByDifficulty 统计各难度题目数量
func (r *PuzzleRepository) CountByDifficulty(difficulty model.Difficulty) (int, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()

	var count int
	err := r.db.QueryRow("SELECT COUNT(*) FROM puzzles WHERE difficulty = ?", int(difficulty)).Scan(&count)
	return count, err
}

// Close 关闭数据库连接
func (r *PuzzleRepository) Close() error {
	return r.db.Close()
}

// ClearAll 清空所有题目
func (r *PuzzleRepository) ClearAll() error {
	r.mu.Lock()
	defer r.mu.Unlock()
	_, err := r.db.Exec("DELETE FROM puzzles")
	return err
}

func timeFromUnix(ts int64) time.Time {
	return time.Unix(ts, 0)
}
