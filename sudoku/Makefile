all: sudoku.bas
	beebasm -i disc_image.6502 -opt 3 -do sudoku.bbc -v > log.sudoku

sudoku.bas: sudoku_head.bas sudoku_vars.bas sudoku_tail.bas
	rm -f sudoku.bas
	cat sudoku_head.bas sudoku_vars.bas sudoku_tail.bas > sudoku.bas

sudoku_vars.bas: sudoku_code.6502
	rm -f sudoku_vars.bas
	beebasm -i variable_dump.6502 -do /dev/null -v \
	| sed -n '/#####/,$$s/ //gp' \
	| awk 'BEGIN{L=200} /=/{printf "%5d%s\n", L, $$0;L+=10}' \
	> sudoku_vars.bas

clean:
	rm -f sudoku_vars.bas sudoku.bas sudoku.bbc log.sudoku
