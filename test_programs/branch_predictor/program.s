# Тест предсказателя переходов

# Счет от 0 до 10 с выводом значения в порт по адресу 0x10000000

        li      t0, 0
        li      t1, 10
        li      t2, 0x10000000

loop:
	sw      t0, 0(t2)
	addi    t0, t0, 1
	bne     t0, t1, loop

sleep:
	j       sleep
