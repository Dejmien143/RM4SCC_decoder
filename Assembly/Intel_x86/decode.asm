section	.text
global  decodeRM4SCC


decodeRM4SCC:
	push	ebp
	mov	ebp, esp
	sub     esp, 0

	
	xor	esi,esi
	xor eax,eax
	xor	edi,edi
	xor	edx,edx
	xor	ecx,ecx

	mov     esi, [ebp+8]
	

	mov eax,50
	sub eax,[ebp+12]
	mov ecx,1800
	mul ecx
	add esi,eax
	
	mov ecx, DWORD[ebp+16]
	mov		edi, 1

	find_start:
		cmp		BYTE [esi], 0 
		je		check_start
		cmp		esi, 1800
		je		no_start_symbol
		add		esi, 3
		inc		edi

		jmp find_start

	check_start:
		add esi,9000
		cmp		BYTE [esi], 0 
		je		before_count_distancefirst
		
		jmp		wrong_start


	before_count_distancefirst:
		sub esi,9000
		mov edi,0
		jmp		count_distancefirst

	count_distancefirst:
		cmp		BYTE [esi], 0 
		jne		count_distancesecond
		
		add edi,3
		add esi,3
		jmp		count_distancefirst
	count_distancesecond:
		cmp		BYTE [esi], 0 
		je		setup_char
		
		add edi,3
		add esi,3

		jmp		count_distancesecond



	setup_char:
		add esi,9000
		mov dl,0
		jmp start_reading_top
		
	start_reading_top:
		cmp		BYTE [esi], 0 
		je		first_top_one
		
		cmp		BYTE [esi], 0 
		jne		first_top_zero
		

	first_top_one:
		add 	esi,edi
		cmp		BYTE [esi], 0 
		je		second_top_oneone

		cmp		BYTE [esi], 0 
		jne		second_top_onezero	

	second_top_oneone:
		add esi,edi
		add dl,30
		jmp start_reading_bottom

	second_top_onezero:
		add esi,edi
		cmp		BYTE [esi], 0 
		je		third_top_zeroone
		cmp		BYTE [esi], 0 
		jne		third_top_zerozero	

	third_top_zerozero:
		add dl,18
		jmp start_reading_bottom

	third_top_zeroone:
		add dl,24
		jmp start_reading_bottom

	first_top_zero:
		add esi,edi
		cmp		BYTE [esi], 0 
		je		second_top_one
		cmp		BYTE [esi], 0 
		jne		second_top_zero

	second_top_zero:
		add esi,edi
		add dl,0
		jmp start_reading_bottom

	second_top_one:
		add esi,edi
		cmp		BYTE [esi], 0 
		je		third_top_one
		cmp		BYTE [esi], 0 
		jne		third_top_zero	

	third_top_zero:
		add dl,6
		jmp start_reading_bottom

	third_top_one:
		add dl,12
		jmp start_reading_bottom

	start_reading_bottom:
		sub esi,edi
		sub esi,edi
		sub esi,19800
		cmp		BYTE [esi], 0 
		je		first_bottom_one
		cmp		BYTE [esi], 0 
		jne		first_bottom_zero		
		
	first_bottom_zero:
		add esi,edi
		cmp		BYTE [esi], 0 
		je		second_bottom_zeroone
		
		cmp		BYTE [esi], 0 
		jne		second_bottom_zerozero

	second_bottom_zerozero:
		add esi,edi
		add dl,1
		jmp store_character	

	second_bottom_zeroone:
		add esi,edi
		cmp		BYTE [esi], 0 
		je		third_bottom_oneone
		cmp		BYTE [esi], 0 
		jne		third_bottom_onezero

	third_bottom_onezero:
		add dl,2
		jmp store_character	

	third_bottom_oneone:
		add dl,3
		jmp store_character

	first_bottom_one:
		add esi,edi
		cmp		BYTE [esi], 0 
		je		second_bottom_one
		cmp		BYTE [esi], 0 
		jne		second_bottom_zero	

	second_bottom_zero:
		add esi,edi
		cmp		BYTE [esi], 0 
		je		third_bottom_one
		cmp		BYTE [esi], 0 
		jne		third_bottom_zero	

	second_bottom_one:
		add esi,edi
		add dl,6
		jmp store_character

	third_bottom_zero:	
		add dl,4
		jmp store_character
	
	third_bottom_one:
		add dl,5
		jmp store_character

	store_character:
		cmp dl,11
		jae alphabet_chars
	
		cmp dl,11
		jb numeric_chars
	
	alphabet_chars:
		add dl,54
		mov BYTE[ecx],dl
		inc ecx
	
		jmp before_next_char

	numeric_chars:
		add dl,47
		mov BYTE[ecx],dl
		inc ecx
		
		jmp before_next_char
		
	before_next_char:
		add esi,10800	
		mov eax,7
		mul edi
		add esi,eax

		mov eax,0
		cmp		BYTE [esi], 0 
		jne		exit_loop
	
		mov eax,5
		mul edi
		sub esi,eax
		add esi,9000
		mov dl,0
		
		jmp start_reading_top

	wrong_start:
		mov eax,1
		jmp exit_loop

	no_start_symbol:
		mov eax,2
		jmp exit_loop

	exit_loop:		
		mov	eax, eax
		pop	ebp
		ret