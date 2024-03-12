; ********************************************************************************************
; * IST-UL
; * Modulo: grupo58.asm
; * Descrição: Entrega intermédia do projeto cujo objetivo é construir o jogo Space Invaders.       
; * Alunos : 106930 ; 106933; 99212
; ********************************************************************************************

; **********************************************************************
; * Constantes
; **********************************************************************
; ATENÇÃO: constantes hexadecimais que comecem por uma letra devem ter 0 antes.
; Isto não altera o valor de 16 bits e permite distinguir números de identificadores

;MediaCenter
COMANDOS				    EQU	6000H			; endereço de base dos comandos do MediaCenter
DEFINE_LINHA    		    EQU COMANDOS + 0AH		; endereço do comando para definir a linha
DEFINE_COLUNA   		    EQU COMANDOS + 0CH		; endereço do comando para definir a coluna
DEFINE_PIXEL    		    EQU COMANDOS + 12H		; endereço do comando para escrever um pixel
APAGA_AVISO     	        EQU COMANDOS + 40H		; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRÃ	 		        EQU COMANDOS + 02H		; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_CENARIO_FUNDO     EQU COMANDOS + 42H		; endereço do comando para selecionar uma imagem de fundo
SELECT_SND                  EQU COMANDOS + 48H     ; endereco do comando para selecionar um som
PLAY_SND                    EQU COMANDOS + 5AH     ; endereco do comando para tocar o som

;NAVE
LINHA_NAVE        		EQU 27        	; linha da nave 
COLUNA_NAVE		        EQU 24        	; coluna da nave 
LARGURA_NAVE			EQU	15			; largura da nave
TAMANHO_NAVE            EQU 5           ; tamanho da nave 
RED		                EQU	0FF00H		; cor do pixel: vermelho em ARGB 
GREEN		            EQU	0FAC6H		; cor do pixel: esverdeado em ARGB 
BLUE                    EQU 0F0AFH      ; cor do pixel: azulado em ARGB

;SONDA
MIN_LINHA               EQU 0
LARGURA_SONDA			EQU	1			; largura da nave 
COR_SONDA               EQU	0F0AFH      ; cor da sonda (azulado)
LINHA_SONDA_0           EQU 26          ; linha inicial da sonda do meio
LINHA_SONDA_1           EQU 26          ; linha inicial da sonda da esquerda      
LINHA_SONDA_2           EQU 26          ; linha inicial da sonda da direita   
COLUNA_SONDA_0          EQU 31          ; coluna inicial da sonda do meio 
COLUNA_SONDA_1          EQU 25          ; coluna inicial da sonda da esquerda   
COLUNA_SONDA_2          EQU 36          ; coluna inicial da sonda da direita 
VALOR_AST_MINERAVEL     EQU 25          ; valor que se ganha de energia ao destruir um ast mineravel
MAX_MOVIMENTOS          EQU 12          ; max nº de movimentos da sonda
RESET                   EQU 40          ; reset nos valores da linha atual da sonda

;ASTEROIDE
LINHA_AST_0             EQU 0           ; linha do asteróide (5 trajetórias possiveis)
COLUNA_AST_0            EQU 0           ; coluna do asteróide
LINHA_AST_1             EQU 0           ; linha do asteróide
COLUNA_AST_1            EQU 28          ; coluna do asteróide
LINHA_AST_2             EQU 0           ; linha do asteróide
COLUNA_AST_2            EQU 28          ; coluna do asteróide
LINHA_AST_3             EQU 0           ; linha do asteróide
COLUNA_AST_3            EQU 28          ; coluna do asteróide
LINHA_AST_4             EQU 0           ; linha do asteróide
COLUNA_AST_4            EQU 56          ; coluna do asteróide
LARGURA_AST             EQU 7           ; largura da asteróide
COR_AST                 EQU 0FF0FH      ; cor do asteróide (roxo)
COR_AST_MIN             EQU 0FF00H      ; cor do asteroide mineravel (verde)
TAMANHO_AST             EQU 5           ; tamanho do ast    
LIMITE_AST              EQU 28          ; limite do ecrã para o asteróide

;TECLADO
DISPLAYS            EQU 0A000H  ; endereço dos displays de 7 segmentos(pe POUT-1)
TEC_LIN             EQU 0C000H  ; endereço das linhas do teclado (periférico POUT-2)
TEC_COL             EQU 0E000H  ; endereço das colunas do teclado (periférico PIN)
FIM_TECLADO         EQU 8H      ; ultima linha do teclado (4ª linha, 1000b)
MASCARA             EQU 0FH     ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
INICIO              EQU 0100H   ; início do display do contador de energia
EN_INICIAL          EQU 0064H
BOTAO_AST           EQU 4H      ; botão que faz o asteróide descer
BOTAO_SONDA_E       EQU 1H	    ; botão para diminuir o contador de energia
BOTAO_SONDA_D       EQU 2H	    ; botão para aumentar o contador de energia
BOTAO_SONDA         EQU 3H      ; botão para mover sonda
BOTAO_PAUSE         EQU 07H     ; botao pause/resume
BOTAO_START         EQU 04H     ;botao start
BOTAO_OVER          EQU 06H     ;botao start
N_SONDAS            EQU 3
TAMANHO_PILHA       EQU 100H
N_AST               EQU 5

; #######################################################################
; * ZONA DE DADOS PILHA
; #######################################################################
	PLACE       2000H
pilha:
	STACK 100H			; espaço reservado para a pilha 
						; (200H bytes, pois são 100H words)
SP_inicial:				; este é o endereço (1200H) com que o SP deve ser 
						; inicializado. O 1.º end. de retorno será 
						; armazenado em 11FEH (1200H-2)

	STACK 100H			    ; espaço reservado para a pilha do processo "teclado"
SP_inicial_teclado:			; este é o endereço com que o SP deste processo deve ser inicializado
							
    STACK 100H			    ; espaço reservado para a pilha do processo "display"
SP_inicial_energia:			; este é o endereço com que o SP deste processo deve ser inicializado

    STACK TAMANHO_PILHA * N_SONDAS 			; espaço reservado para a pilha do processo "sonda"
SP_inicial_sonda:			                ; este é o endereço com que o SP deste processo deve ser inicializado

    STACK 100H			    ; espaço reservado para a pilha do processo "sonda"
SP_inicial_nave:			; este é o endereço com que o SP deste processo deve ser inicializado

    STACK 100H			        ; espaço reservado para a pilha do processo "check_ast"
SP_inicial_check_ast:			; este é o endereço com que o SP deste processo deve ser inicializado

	STACK TAMANHO_PILHA * N_AST			; espaço reservado para a pilha do processo "boneco"
SP_inicial_boneco:			            ; este é o endereço com que o SP deste processo deve ser inicializado
							
tecla_carregada:
	LOCK 0				; LOCK para o teclado comunicar aos restantes processos que tecla detetou

linha_sonda:				; linha em que cada boneco está (inicializada com a linha inicial)
	WORD LINHA_SONDA_0
	WORD LINHA_SONDA_1
	WORD LINHA_SONDA_2

coluna_sonda:				; linha em que cada boneco está (inicializada com a coluna inicial)
	WORD COLUNA_SONDA_0
	WORD COLUNA_SONDA_1
	WORD COLUNA_SONDA_2
                                                        
sentido_movimento:			; sentido movimento inicial de cada sonda (horizontal)
	WORD -1                 ; sonda do meio
	WORD -1                 ; sonda da esquerda
	WORD -1                 ; sonda da direita

coluna_movimento:			; sentido movimento inicial de cada sonda (vertical)
	WORD 0                  ; sonda do meio
	WORD -1                 ; sonda da esquerda
	WORD 1                  ; sonda da direita

posicao_sonda:              ; auxiliar para ver se ja se pode disparar outra sonda com a mesma tecla
    WORD 0
    WORD 0
    WORD 0

colisao_sonda:              ; guarda se uma sonda colidiu (muda o valor para 1)
    WORD 0
    WORD 0
    WORD 0

linha_ast:				; linha em que cada boneco está inicializado
	WORD LINHA_AST_0
	WORD LINHA_AST_1
	WORD LINHA_AST_2
    WORD LINHA_AST_3
    WORD LINHA_AST_4

coluna_ast:				; coluna em que cada boneco está inicializado
	WORD COLUNA_AST_0
	WORD COLUNA_AST_1
	WORD COLUNA_AST_2
    WORD COLUNA_AST_3
    WORD COLUNA_AST_4
                                                        
sentido_movimento_ast:			; sentido movimento inicial de cada boneco (horizontal, 1 para baixo, -1 para cima)
	WORD 1
	WORD 1
	WORD 1
    WORD 1
    WORD 1

coluna_movimento_ast:			; sentido movimento inicial de cada boneco ( vertical, +1 para a direita, -1 para a esquerda)
	WORD 1
	WORD 0
	WORD -1
    WORD 1
    WORD -1

numero_ast:                     ; variaveis auxiliar que guardam que asteroides estao ativos
    WORD 0
    WORD 0
    WORD 0
    WORD 0
    WORD 0

atual_linha_ast:                ; guarda a linha atual de cada asteroide
    WORD LINHA_AST_0
	WORD LINHA_AST_1
	WORD LINHA_AST_2
    WORD LINHA_AST_3
    WORD LINHA_AST_4

atual_coluna_ast:               ; guarda a coluna atual de cada asteroide
    WORD COLUNA_AST_0
	WORD COLUNA_AST_1
	WORD COLUNA_AST_2
    WORD COLUNA_AST_3
    WORD COLUNA_AST_4

atual_linha_sonda:              ; guarda a linha atual de cada sonda
    WORD 40
    WORD 40
    WORD 40

atual_coluna_sonda:             ; guarda a coluna atual de cada sonda
    WORD -1
    WORD -1
    WORD -1

ast_mineravel:                  ; ajuda a gerar um ast mineravel ( 1 em 4)
    WORD 4

energia_display:                ; guarda o valor da energia do display
    WORD INICIO

playing_state:
    WORD 0

pause_state:
	WORD 0					;estado de pausa

evento_int_0:
	LOCK 0				; LOCK para a rotina de interrupção comunicar ao processo boneco que a interrupção ocorreu

evento_int_1:
	LOCK 0				; LOCK para a rotina de interrupção comunicar ao processo sonda que a interrupção ocorreu

evento_int_2:
	LOCK 0				; LOCK para a rotina de interrupção comunicar ao processo energia que a interrupção ocorreu

evento_int_3:
	LOCK 0				; LOCK para a rotina de interrupção comunicar ao processo nave que a interrupção ocorreu							


; Tabela das rotinas de interrupção
tab:
	WORD rot_int_0			; rotina de atendimento da interrupção 0 (asteroide)
    WORD rot_int_1           ; rotina de atendimento da interrupção 1 (sonda)
    WORD rot_int_2           ; rotina de atendimento da interrupção 2 (energia do display)
    WORD rot_int_3           ; rotina de atendimento da interrupção 3 (nave)

; #######################################################################
; * ZONA DE DADOS NAVE
; #######################################################################
	PLACE		0800H				

DEF_NAVE:		; tabela que define a nave (cor, largura, pixels)
	WORD		LARGURA_NAVE
	WORD		0, 0, RED, RED, RED, RED, RED, RED, RED, RED, RED, RED, RED , 0, 0
	WORD		0,RED, GREEN, GREEN, GREEN, GREEN, GREEN, GREEN, GREEN, GREEN, GREEN, GREEN, GREEN, RED, 0
	WORD		RED, GREEN, GREEN, GREEN, BLUE, COR_AST, BLUE, COR_AST, BLUE, COR_AST, BLUE, GREEN, GREEN, GREEN, RED 
	WORD		RED, GREEN, GREEN, GREEN, COR_AST, BLUE, COR_AST, BLUE, COR_AST, BLUE, COR_AST, GREEN, GREEN, GREEN, RED
	WORD		RED, GREEN, GREEN, GREEN, GREEN, GREEN, GREEN, GREEN, GREEN, GREEN, GREEN, GREEN, GREEN, GREEN, RED

DEF_NAVE2:		; tabela que define a nave (cor, largura, pixels)
	WORD		LARGURA_NAVE
	WORD		0, 0, RED, RED, RED, RED, RED, RED, RED, RED, RED, RED, RED , 0, 0
	WORD		0,RED, GREEN, GREEN, GREEN, GREEN, GREEN, GREEN, GREEN, GREEN, GREEN, GREEN, GREEN, RED, 0
	WORD		RED, GREEN, GREEN, GREEN, COR_AST, BLUE, COR_AST, BLUE, COR_AST, BLUE, COR_AST, GREEN, GREEN, GREEN, RED 
	WORD		RED, GREEN, GREEN, GREEN, BLUE, COR_AST, BLUE, COR_AST, BLUE, COR_AST, BLUE, GREEN, GREEN, GREEN, RED
	WORD		RED, GREEN, GREEN, GREEN, GREEN, GREEN, GREEN, GREEN, GREEN, GREEN, GREEN, GREEN, GREEN, GREEN, RED
; #######################################################################
; * ZONA DE DADOS SONDA
; #######################################################################
	PLACE		1000H				

DEF_SONDA:		; tabela que define a sonda (cor, largura, pixels)
	WORD		LARGURA_SONDA
	WORD	    COR_SONDA

; #######################################################################
; * ZONA DE DADOS ASTEROIDE
; #######################################################################
	PLACE		1300H				

DEF_AST:		; tabela que define o AST (cor, largura, pixels)
	WORD		LARGURA_AST
    WORD	    COR_AST, 0, COR_AST, COR_AST, COR_AST, 0, COR_AST
    WORD	    COR_AST, COR_AST, COR_AST, COR_AST, COR_AST, COR_AST, COR_AST
    WORD	    0, COR_AST, COR_AST, COR_AST, COR_AST, COR_AST, 0
    WORD	    0, 0, COR_AST, COR_AST, COR_AST, 0, 0
    WORD	    COR_AST, COR_AST, COR_AST, COR_AST, COR_AST, COR_AST, COR_AST

DEF_AST2:		; tabela que define o AST mineravel(cor, largura, pixels)
	WORD		LARGURA_AST
    WORD	    COR_AST_MIN, 0, COR_AST_MIN, COR_AST_MIN, COR_AST_MIN, 0, COR_AST_MIN
    WORD	    COR_AST_MIN, COR_AST_MIN, COR_AST_MIN, COR_AST_MIN, COR_AST_MIN, COR_AST_MIN, COR_AST_MIN
    WORD	    0, COR_AST_MIN, COR_AST_MIN, COR_AST_MIN, COR_AST_MIN, COR_AST_MIN, 0
    WORD	    0, 0, COR_AST_MIN, COR_AST_MIN, COR_AST_MIN, 0, 0
    WORD	    COR_AST_MIN, COR_AST_MIN, COR_AST_MIN, COR_AST_MIN, COR_AST_MIN, COR_AST_MIN, COR_AST_MIN


; *********************************************************************************
; * Código 
;
; *********************************************************************************

PLACE   0				; o código tem de começar em 0000H

inicio:
     MOV  SP, SP_inicial	
     MOV  BTE, tab			; inicializa BTE (registo de Base da Tabela de Exceções)
     MOV  [APAGA_AVISO], R1	; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
     MOV  [APAGA_ECRÃ], R1	; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
     MOV  R1, 0			; cenário de fundo número 0
     MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo
     MOV  R4, DISPLAYS       ; endereço do periférico dos displays
     MOV R3, energia_display
     MOV R10, EN_INICIAL
     MOV [R3], R10
     MOV R10, INICIO         ; guarda o valor do display
     MOV [R4], R10           ; inicializa o display a 100
     MOV R5, posicao_sonda

     EI0                     ; permite interrupções 0
     EI1
     EI2                      ; permite interrupções 2
     EI3
     EI					; permite interrupções (geral)
						; a partir daqui, qualquer interrupção que ocorra usa
						; a pilha do processo que estiver a correr nessa altura
	
	; cria processos. O CALL não invoca a rotina, apenas cria um processo executável
    CALL    check_ast
    CALL	teclado			    ; cria o processo teclado
    CALL    nave                ; cria o processo nave 
    CALL    energia             ; cria o processo energia

; o resto do programa principal é também um processo (neste caso, trata dos displays)

verificar_comando:                  ; verifica se a tecla premida corresponde a uma ação
    MOV R7,  [tecla_carregada]	    ; bloqueia neste LOCK até uma tecla ser carregada
    CMP R7, BOTAO_START
    JZ comecar_jogo
    MOV R1, [playing_state]
    CMP R1, 0
    JZ verificar_comando

    CMP R7, BOTAO_PAUSE
    JZ pausar
    CMP R7, BOTAO_OVER
    JZ gameover
    CMP R7, BOTAO_SONDA
    JZ dispara_sonda
    CMP R7, BOTAO_SONDA_E
    JZ dispara_sonda_e
    CMP R7, BOTAO_SONDA_D
    JZ dispara_sonda_d
    JMP verificar_comando

dispara_sonda:                  ; dispara sonda do meio
    MOV R9, pause_state
    MOV R1, [R9]				; verifica o estado de jogo
	CMP R1, 0
    JZ shoot
	JMP verificar_comando
shoot:
    MOV R2, [R5]                
    CMP R2, 0                   ; verifica se pode lançar a sonda
    JNZ verificar_comando
    CALL diminui_5_display      ; diminui 5 no display
    MOV R11, 0                  ; guarda a instancia da sonda (meio)
    CALL sonda                  ; cria o processo sonda
    CALL SND_AST                ; reproduz o som
    JMP verificar_comando


dispara_sonda_e:                ; dispara sonda da esquerdsa
    MOV R9, pause_state
    MOV R1, [R9]			    ; verifica o estado de jogo	
	CMP R1, 0
    JZ shoot_e
	JMP verificar_comando
shoot_e:
    MOV R2, [R5 + 2]            ; verifica se pode lançar a sonda
    CMP R2, 0
    JNZ verificar_comando
    CALL diminui_5_display      ; diminui 5 no display
    MOV R11, 1                  ; guarda a instancia da sonda (esquerda)
    CALL sonda                  ; cria o processo sonda
    CALL SND_AST                ; reproduz o som
    JMP verificar_comando


dispara_sonda_d:                ; dispara sonda da direita
    MOV R9, pause_state
    MOV R1, [R9]				; verifica o estado de jogo
	CMP R1, 0
    JZ shoot_d
	JMP verificar_comando
shoot_d:
    MOV R2, [R5+ 4]
    CMP R2, 0                   ; verifica se pode lançar a sonda
    JNZ verificar_comando
    CALL diminui_5_display      ; diminui 5 no display
    MOV R11, 2                  ; guarda a instancia da sonda (direita)
    CALL sonda                  ; cria o processo sonda
    CALL SND_AST                ; reproduz o som
    JMP verificar_comando

pausar:
    CALL pause                  ; muda o estado de jogo para pausa
    JMP verificar_comando

gameover:
    CALL rotina_gameover        ; muda o estado de jogo para game over
    JMP verificar_comando

comecar_jogo:
    CALL rotina_start           ; muda o estado de jogo para o jogo começar
    JMP verificar_comando


;**********************************************************************
; Processo
;
; TECLADO - Processo que deteta quando se carrega numa tecla
;		  do teclado e escreve o valor da coluna num LOCK.
;
; **********************************************************************

PROCESS SP_inicial_teclado	; indicação de que a rotina que se segue é um processo,
				; com indicação do valor para inicializar o SP

teclado:		
; inicializações
    MOV  R2, TEC_LIN        ; endereço do periférico das linhas
    MOV  R3, TEC_COL        ; endereço do periférico das colunas
    MOV  R4, DISPLAYS       ; endereço do periférico dos displays
    MOV  R5, MASCARA        ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
    MOV  R7, 0              ; guarda o valor da tecla premida
    MOV  R8, 0              ; guarda o valor atual da linha do teclado 

ciclo:

    MOV  R1, 1         ; inicia a variável de linha com 1
    MOV  R8, R1        ; guardar a linha que está ser verificada

espera_tecla:          ; neste ciclo espera-se até uma tecla ser premida

    YIELD

    MOVB [R2], R1      ; escrever no periférico de saída (linhas)
    MOVB R0, [R3]      ; ler do periférico de entrada (colunas)
    AND  R0, R5        ; elimina bits para além dos bits 0-3
    CMP  R0, 0         ; há tecla premida?
    JZ   upd_linha     ; se nao há tecla premida, vai para o upd_linha

converte_display_decimal:
    CALL binary_to_decimal          ; mudar o valor da linha para decimal
    SHL R1, 2                       ; multiplicar por 4
    MOV R7, R1                      ; guardar em R7
    MOV R1, R0                      ; agora guardar o valor das colunas para chamar a rotina
    CALL binary_to_decimal          ; mudar o valor da coluna para decimal
    ADD R7, R1                      ; ter em R7 o valor da tecla premida (decimal)   

    MOV [tecla_carregada], R7

ha_tecla:               ; neste ciclo espera-se até NENHUMA tecla estar premida

    YIELD

    MOV R1, R8          ; R1 contém agora o valor da linha a ser verificada no teclado
    MOVB [R2], R1       ; escrever no periférico de saída (linhas)
    MOVB R0, [R3]       ; ler do periférico de entrada (colunas)
    AND  R0, R5         ; elimina bits para além dos bits 0-3
    CMP  R0, 0          ; há tecla premida?
    JNZ  ha_tecla       ; se ainda houver uma tecla premida, espera até não haver
    JMP  ciclo          ; repete ciclo

upd_linha:              ; Incrementa a linha a ser verificada
    ; não há tecla premida nesta linha
    MOV R7, FIM_TECLADO
    AND R8, R7          ; verifica se todas as linhas foram testadas
    CMP R8, 0
    JNZ   ciclo         ; dar reset ao ciclo que verifica se alguma tecla foi premida

    SHL  R1, 1          ; incrementa a linha para testar a próxima
    MOV R8, R1          ; atualizamos a variavel que guarda a linha a ser testada          
    JMP  espera_tecla   ; repete o ciclo

; **********************************************************************
; Processo
;
; CHECK_AST - Processo que verifica se é possivel desenhar um ast e que 
;		      escolhe qual o asteroide a ser desenhado
;
; **********************************************************************
PROCESS SP_inicial_check_ast

check_ast:
    MOV R1, numero_ast          ; endereço que contem os asteroides ativos
    MOV	R3, N_AST		        ; número de bonecos a usar (até 4)
    MOV R4 ,1                   ; quando um ast é desenhado atualiza com 1 o endereço

    YIELD                       ;verifica se o jogo esta em pausa
	MOV R9, pause_state
    MOV R1, [R9]				
	CMP R1, 0
    JZ no_pause_chk_ast
	JMP check_ast
no_pause_chk_ast:
    
    loop_bonecos:
        YIELD

        CALL quatro_ast          ;verifica quantos asts estão ativos   

        not_playing_spawner:     ;verifica se o jogo esta ativo
        YIELD               
        MOV R9, playing_state
        MOV R1, [R9]
        CMP R1, 0
        JZ not_playing_spawner

        CMP R5 , 4               ; compara com o maximo numero de asteroides possiveis em tela
        JZ loop_bonecos
        MOV R1, numero_ast    
	    SUB	R3, 1               ; próximo boneco
        SHL R3, 1
        MOV R5, [R1 + R3]       ; R5 obtem 0 ou 1 dependendo se essa instancia ja esta desenhada ou nao
        SHR R3, 1		        ; guarda o valor original da instancia	    
        CMP R5, 0               ; verifica se essa instancia ja esta desenhada
        JNZ extra_check
	    CALL	boneco			; cria uma nova instância do processo boneco (o valor de R3 distingue-as)
        SHL R3 ,1   
        MOV [R1 + R3], R4       ; atualiza o endereço colocando o valor 1
        SHR R3, 1	            ; guarda o valor original da instancia
		CMP R3, 0               ; já criou as instâncias todas?
        JZ  check_ast				                			    
        JMP	loop_bonecos

    extra_check:
        CMP R3, 0               ; já criou as instâncias todas?
        JZ check_ast
        JMP loop_bonecos		


; **********************************************************************
; Processo
;
; AST -  Processo que desenha um AST e o move, com
;		 temporização marcada pela interrupção 0
;
; **********************************************************************

PROCESS SP_inicial_boneco	; indicação de que a rotina que se segue é um processo,
						; com indicação do valor para inicializar o SP

boneco:                       ; inputs para a função desenho          
    MOV R6, LIMITE_AST        ; máxima linha que os asteroides podem chegar
    MOV R1, numero_ast
    MOV R4, TAMANHO_PILHA
    MUL R4, R3
    SUB SP, R4                ; atualizar o SP para cada processo dependendo da instancia

    MOV R10, R3               ; guardar o valor da instancia
    SHL R10, 1
    
    ; desenha o boneco na sua posição inicial
    MOV R1, linha_ast
    MOV R7, [R1+ R10]           ; linha inicial do asteroide

    MOV R1, coluna_ast
    MOV R8, [R1+R10]            ; coluna inicial do asteroide

    MOV R1, sentido_movimento_ast
    MOV R4, [R1 + R10]          ; valor que vai mover na horizontal

    MOV R1, coluna_movimento_ast
    MOV R5, [R1 + R10]          ; valor que vai mover na vertical

    ;escolhe mineravel ou nao
    MOV R9, TAMANHO_AST
    MOV R1, ast_mineravel
    MOV R2, [R1]
    CMP R2, 1                   ; quando está a 1 é porque ja houve 3 asteroides normais
    JZ ast_e_mineravel
    MOV R3, DEF_AST
    DEC R2
    MOV [R1], R2
    JMP desenha_ast
    ast_e_mineravel:
    MOV R3, DEF_AST2            ; ast mineravel
    MOV R2, 4
    MOV [R1], R2

desenha_ast:                   ; desenha o ast a partir da tabela  

    not_playing_bonecos:        ;verifica se o jogo esta ativo
        YIELD
       MOV R9, playing_state
        MOV R2, [R9]
       CMP R2, 0
    JZ not_playing_bonecos
    

    MOV R9, TAMANHO_AST

    CALL desenha_objeto         ; desenha o ast 
    CALL colisao_ast_sonda      ; verifica colisao com sonda
    CMP R2, 1                   ; se for 1 houve colisao
    JZ mais_5_display           ; verifica se destruiu ast mineravel
    CALL colisao_ast_nave       ; se houver o jogo acaba

    MOV	R0, [evento_int_0]	; lê o LOCK e bloqueia até a interrupção escrever nele
				                ; Quando bloqueia, passa o controlo para outro processo
    
    pause_ast:                  ;verifica se o jogo esta em pausa
    YIELD
	MOV R9, pause_state
    MOV R2, [R9]				
	CMP R2, 0
    JZ no_pause_ast
	JMP pause_ast

no_pause_ast:

    MOV R9, TAMANHO_AST 

    CALL	apaga_boneco		; apaga o boneco na sua posição corrente
    ADD R7, R4                  ; atualiza a linha
    MOV R2, atual_linha_ast
    MOV [R2 + R10], R7          ; guarda a nova linha
    ADD R8, R5                  ; atualiza a coluna
    MOV R2, atual_coluna_ast
    MOV [R2 + R10], R8          ; guarda a nova coluna
    MOV R1, numero_ast
    CMP R7, R6                  ; verifica se o asteroide ja chegou ao limite da tela
    JNZ desenha_ast             ; se nao o loop continua
    JMP fim_ast
    mais_5_display:             ; verifica se o ast destruido era mineravel
    
    MOV R1, DEF_AST2
    CMP R3, R1
    JNZ som_ast_normal                     ;se nao for 0 é porque não era mineravel
    CALL SND_JACKPOT
    MOV R3, energia_display
    MOV R6, VALOR_AST_MINERAVEL     ; + 25                      
    MOV R1, [R3]                    ; valor atual do display
    ADD R1, R6                      ; adiciona 25 ao display
    MOV [R3], R1                    ; guarda o novo valor
    CALL display_hexa_to_decimal    ; transforma em decimal e coloca no display
    JMP fim_ast
    som_ast_normal:
    CALL SND_HIT
    fim_ast:
    MOV R1, numero_ast
    MOV R6, 0                       ; atualiza o endereco que guarda os asteroides ativos
    MOV [R1 + R10], R6
    MOV R2, atual_linha_ast     
    MOV [R2 + R10], R6              ; da reset na linha do ast
    MOV R2, atual_coluna_ast
    MOV [R2 + R10], R6              ; da reset na coluna do ast
    

;**********************************************************************
; Processo
;
; ENERGIA - Processo que diminui a energia do display periodicamente
;		  
; **********************************************************************

PROCESS SP_inicial_energia      ; indicação de que a rotina que se segue é um processo,
						        ; com indicação do valor para inicializar o SP
energia:

diminui:                        ;verifica se o jogo esta em pausa
    YIELD
	MOV R9, pause_state
    MOV R3, [R9]				
	CMP R3, 0
    JZ no_pause_energia
	JMP diminui
no_pause_energia:

not_playing_energia:                ;verifica se o jogo esta ativo
    YIELD
    MOV R9, playing_state
    MOV R3, [R9]
    CMP R3, 0
    JZ not_playing_energia

     MOV	R3, [evento_int_2]	    ; lê o LOCK e bloqueia até a interrupção escrever nele
	    			                ; Quando bloqueia, passa o controlo para outro processo
     MOV R4, energia_display        ; endereco que guarda o valor da energia
     MOV R1, [R4]
     SUB R1, 3                      ; subtrai 3 ao valor atual
     MOV [R4], R1                   ; guarda de novo 
     MOV R5, 0
     CMP R5, R1
     JGE perdeu_por_energia         ; ve se o valor é 0 ou menor (perdeu)
     CALL display_hexa_to_decimal   ; transforma o valor em decimal e coloca no display
     JMP diminui                    ; continua o ciclo

     perdeu_por_energia:
     MOV R1, playing_state
     MOV R2, 0
     MOV [R1], R2
     MOV R2, 4
     MOV [SELECIONA_CENARIO_FUNDO], R2
     MOV [APAGA_ECRÃ], R2
     MOV [DISPLAYS], R5             ; mantem 0 no display
     JMP perdeu_por_energia
    

;**********************************************************************
; Processo
;
; SONDA - Processo que move a sonda verticalmente ou diagonalmente
;		  
; **********************************************************************

PROCESS SP_inicial_sonda

sonda:                              ; inputs para a função desenho          
    MOV R6, MAX_MOVIMENTOS          ; maximo nº de movimentos da sonda
    MOV R1, posicao_sonda
    MOV R2, 1
    MOV R4, TAMANHO_PILHA
    MUL R4, R11
    SUB SP, R4                      ; atualizar o SP para cada processo dependendo da instancia

    MOV R10, R11                    ; guardar o valor da instancia
    SHL R10, 1
    MOV [R1 + R10], R2              ; atualiza a variavel que guarda que sondas estao ativas
    MOV R2, atual_linha_sonda
    
    ; desenha o boneco na sua posição inicial
    MOV R1, linha_sonda
    MOV R7, [R1+ R10]               ; valor da linha inicial da sonda            
    MOV [R2 + R10], R7              ; guarda o valor da linha atual da sonda

    MOV R1, coluna_sonda    
    MOV R2, atual_coluna_sonda
    MOV R8, [R1+R10]                ; valor da coluna inicial da sonda    
    MOV [R2 + R10], R8              ; guarda o valor da coluna atual da sonda

    MOV R1, sentido_movimento
    MOV R4, [R1 + R10]              ; guarda o valor que a sonda vai se mover na horizontal

    MOV R1, coluna_movimento
    MOV R5, [R1 + R10]              ; guarda o valor que a sonda vai se mover na vertical

    MOV R3, DEF_SONDA               ; tabela da sonda
    MOV R9, LARGURA_SONDA           ; largura da sonda

desenha_sonda:                ; desenha a sonda a partir da tabela      

    not_playing_sonda:          ;verifica se o jogo esta ativo
    YIELD
    MOV R9, playing_state
    MOV R3, [R9]
    CMP R3, 0
    JZ not_playing_sonda
    
    MOV R3, DEF_SONDA               ; tabela da sonda
    MOV R9, LARGURA_SONDA           ; largura da sonda

    CALL desenha_objeto
    MOV R1, colisao_sonda
    MOV R2, [R1 + R10]          ; se R2 for 1 a sonda colidiu com algo logo o seu processo acabou 
    CMP R2, 1
    JZ fim_sonda


    MOV	R0, [evento_int_1]	; lê o LOCK e bloqueia até a interrupção escrever nele
				                ; Quando bloqueia, passa o controlo para outro processo
    
    pause_sonda:                ;verifica se o jogo esta em pausa
    YIELD
	MOV R9, pause_state
    MOV R3, [R9]				
	CMP R3, 0
    JZ no_pause_sonda
	JMP pause_sonda
    no_pause_sonda:

    CALL	apaga_sonda		; apaga o boneco na sua posição corrente
    ADD R7, R4
    MOV R2, atual_linha_sonda
    MOV [R2 + R10], R7
    ADD R8, R5
    MOV R2, atual_coluna_sonda
    MOV [R2 + R10], R8
    MOV R9, LARGURA_SONDA
    MOV R3 , DEF_SONDA
    MOV R1, posicao_sonda
    SUB R6, 1
    CMP R6, 0 
    JNZ desenha_sonda
    fim_sonda:
    CALL apaga_sonda                ; apagar a sonda
    MOV R1, posicao_sonda
    MOV R6 , 0                      
    MOV [R1 + R10], R6              ; atualiza a variavel que guarda que sondas estao ativas
    MOV R1, colisao_sonda
    MOV [R1 + R10], R6              ; atualiza a variavel que guarda se as sondas colidiram
    MOV R2, atual_coluna_sonda
    MOV [R2 + R10], R6              ; da reset no endereço que guarda o valor atual da coluna da sonda ( valor irrelevante)
    MOV R6, RESET                   ; valor ficticio para a linha atual da sonda quando ela é apagada
    MOV R2, atual_linha_sonda
    MOV [R2 + R10], R6              ; da reset no valor que guarda a linha atual da sonda ( valor irrelevante)


;**********************************************************************
; Processo
;
; NAVE - Processo que varia as cores do painel de instrumentos da nave
;
; **********************************************************************
PROCESS SP_inicial_nave
nave:
    MOV R7, LINHA_NAVE		    ; linha da nave
    MOV R8, COLUNA_NAVE		    ; coluna da nave
    MOV R3, DEF_NAVE            ; endereço da nave
    MOV R9, TAMANHO_NAVE        ; tamanho da nave
    MOV R10, 1                  ; indica a tabela da nave a escolher

desenha_nave:       		    ; desenha a nave a partir da tabela

    not_playing_nave:           ;verifica se o jogo esta ativo
    YIELD
    MOV R4, playing_state
    MOV R5, [R4]				
	CMP R5, 0
    JZ not_playing_nave

    YIELD
	MOV R4, pause_state         ;verifica se o jogo esta em pausa
    MOV R5, [R4]				
	CMP R5, 0
    JZ no_pause_nave
	JMP desenha_nave
    no_pause_nave:

	CALL desenha_objeto
    MOV	R0, [evento_int_3]	    ; lê o LOCK e bloqueia até a interrupção escrever nele
				                ; Quando bloqueia, passa o controlo para outro processo
    MOV R9, TAMANHO_NAVE
    CMP R10, 0
    JNZ troca_tabela            ; troca a tabela para a nave ir piscando
    MOV R10, 1
    MOV R3, DEF_NAVE
    JMP desenha_nave
    troca_tabela:
        DEC R10
        MOV R3, DEF_NAVE2           ; muda a tabela
        JMP desenha_nave
    

; *********************************************************************************
; * ROTINAS
; *********************************************************************************

; Rotina: binary_to_decimal
; Converte o valor binário para decimal
; Input: R1 - Valor Binário
; Output: R1 - Valor Decimal
binary_to_decimal:

    PUSH R2

    MOV R2, R1                      ; Guarda o valor binário em R2 para contar os shifts
    MOV R1, 0                       ; Inicia o valor decimal a 0

    count_shifts:
        SHR R2, 1    
        INC R1                      ; incrementa o valor decimal

        CMP R2, 0                   ; verifica se o valor binário é 0
        JNZ count_shifts            ; se não for repete o processo

    DEC R1                          ; decrementa o valor por 1 para ter o correto

    POP R2

    RET          

; Rotina: apaga_sonda
; Move a sonda uma linha para cima ( apagando-a e desenhando a mesma na sua nova posição)
apaga_sonda:
    PUSH R0
    MOV R0, 0

    apaga:
         MOV  [DEFINE_LINHA],  R7	     ; seleciona a linha
	     MOV  [DEFINE_COLUNA], R8	     ; seleciona a coluna
	     MOV  [DEFINE_PIXEL],  R0      ; altera a cor do pixel na linha e coluna selecionadas

    POP R0
    RET                             ; Return from the function

; Rotina: apaga_boneco
; Apaga o asteroide e desenha-o de novo na diagonal abaixo
apaga_boneco:

    PUSH R1
    PUSH R2
    PUSH R4
    PUSH R5
    PUSH R9

    MOV R1, R7
    MOV R2, R8
    MOV R4, LARGURA_AST
    MOV R5, 0                       ; cor do pixel ( vai ser apagado)

    apaga_ast:
        MOV  [DEFINE_LINHA], R1	    ; seleciona a linha
	    MOV  [DEFINE_COLUNA], R2	; seleciona a coluna
	    MOV  [DEFINE_PIXEL], R5 	; altera a cor do pixel na linha e coluna selecionadas

        ADD R2, 1                   ; próxima coluna
        SUB R4, 1                   ; menos 1 coluna para tratar
        JNZ apaga_ast               ; até ao fim da largura
        ADD R1, 1                   ; próxima linha
        MOV R2, R8                  ; reset no valor da coluna
        MOV R4, LARGURA_AST         ; reset no valor da largura
        SUB R9, 1                   ; menos 1 linha para tratar
        JNZ apaga_ast               ; percorrer todas as linhas

    POP R9    
    POP R5
    POP R4
    POP R2
    POP R1

    RET

; Rotina: desenha_objeto
; Inputs : R7-linha , R8-coluna, R3-endereço do objeto (DEF_AST por ex.), R9-tamanho
; Desenha um objeto requisitado
desenha_objeto:

    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R9
    
    MOV R1, R7                      ; valor da linha
    MOV R2, R8                      ; valor da coluna
    MOV R5, [R3]                    ; obtem largura do objeto
    MOV R6, R5                      ; guarda largura
    ADD R3, 2                       ; obtem endereço da cor do proximo pixel
    
    desenha_pixels:
        MOV R4, [R3]                ; obtem cor do proximo pixel
        MOV  [DEFINE_LINHA], R1	    ; seleciona a linha
	    MOV  [DEFINE_COLUNA], R2	; seleciona a coluna
	    MOV  [DEFINE_PIXEL], R4	    ; altera a cor do pixel na linha e coluna selecionadas
	    ADD	R3, 2			        ; endereço da cor do próximo pixel
        ADD R2, 1                   ; proxima coluna
        SUB R5, 1                   ; menos 1 coluna
        JNZ desenha_pixels          ; percorrer a largura toda
        INC R1                      ; proxima linha
        MOV R2, R8                  ; reset na coluna
        MOV R5, R6                  ; reset na largura
        SUB R9, 1                   ; menos 1 linha
        JNZ desenha_pixels          ; percorrer todas as linhas
    
    POP R9
    POP R6
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    
    RET

; Rotina: SND_AST
; Reproduz o som da descida do asteroide
SND_AST:
    PUSH R1                                 
    MOV R1, 0                       ; som a selecionar
    MOV [SELECT_SND], R1            ; seleciona o segundo som da lista, correspondente ao do asteroide
    MOV [PLAY_SND] , R1             ; reproduz o som selecionado
    POP R1                                  
    RET


; Rotina: SND_HIT
; Reproduz o som de destruciao de um asteroide normal
SND_HIT:
    PUSH R1                                 
    MOV R1, 1                       ; som a selecionar
    MOV [SELECT_SND], R1            ; seleciona o segundo som da lista, correspondente ao do asteroide
    MOV [PLAY_SND] , R1             ; reproduz o som selecionado
    POP R1                                  
    RET

; Rotina: SND_JACKPOT 
; Reproduz o som de destruicao de um asteroide mineravel
SND_JACKPOT:
    PUSH R1                                 
    MOV R1, 2                       ; som a selecionar
    MOV [SELECT_SND], R1            ; seleciona o segundo som da lista, correspondente ao do asteroide
    MOV [PLAY_SND] , R1             ; reproduz o som selecionado
    POP R1                                  
    RET


; Rotina: diminui_5_display
; Diminui o display apos disparar sonda
; Argumentos : R3- endereço que guarda o valor da energia
diminui_5_display:

    MOV R10, [R3]                   ; obtem o valor do display
    SUB R10 , 5                     ; diminui cinco
    MOV [R3], R10                   ; guarda o novo valor
    CALL display_hexa_to_decimal    ; tranforma o valor em decimal e coloca-o no display
    RET

; Rotina: quatro_ast
; Ve quantos asteroides estao ativos naquele momento
quatro_ast:
    PUSH R4
    PUSH R3

    MOV R1, numero_ast
    MOV R5, [R1]
    MOV R3, N_AST
    ciclo_a:
        ADD R1, 2               ; aumenta 2 para ir para o proximo endereço
        MOV R4, [R1]            ; obtem o valor desse endereço
        ADD R5, R4              ; soma os 2 valores
        SUB R3, 1               ; diminui o numero 
        CMP R3, 1
        JNZ ciclo_a             ; repete o ciclo ate verificarem todos os endereços (5)
    
    POP R3
    POP R4
    RET

; Rotina: colisao_ast_sonda
; Verifica se ocorreu colisão entre o ast e sonda
; Output: R2 = 1 se houve colisao ou R2 = 0 se nao houve
colisao_ast_sonda:
    PUSH R0
    PUSH R1
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8
    PUSH R9
    PUSH R11

    MOV R1, atual_linha_ast
    MOV R7, [R1 + R10]                  ; obtem o valor da linha atual do ast
    MOV R0 ,R7                          ; guarda em R0
    MOV R1, atual_coluna_ast
    MOV R8, [R1 + R10]                  ; obtem o valor da coluna atual do ast
    MOV R11 , R8                        ; guarda em R11
    MOV R1 , TAMANHO_AST
    MOV R2, LARGURA_AST
    MOV R4 ,atual_linha_sonda
    MOV R5, atual_coluna_sonda
    MOV R3, [R4]                ;obtem a linha atual da sonda        
    MOV R6, [R5]                ;obtem a coluna atual sonda
    MOV R9, 0

    deteta_colisao:
        coluna_esquerda:
        SUB R11, 1                      ; Decrementa R11 (atual_coluna_ast) em 1
        CMP R6, R11                     ; Compara R6 (atual_coluna_sonda) com R11 (coluna_ast)
        JNZ coluna_direita              ; se não for igual verifica se houve colisao na coluna direita do ast
        loop_linhas:
            CMP R0, R3                  ; Compara R0 (atual_linha_ast) com R3 (atual_linha_sonda)
            JZ tem_colisao              ; Salta para tem_colisao se forem iguais
            ADD R0, 1                   ; verifica na proxima linha do ast
            SUB R1 , 1                  ; contador das linhas verificadas
            JNZ loop_linhas             ; quando chegar ao 0 todas as linhas foram verificadas
        coluna_direita:
        MOV R1 , TAMANHO_AST            ; reset na variavel do tamanho
        ADD R11, 1                  
        ADD R11, LARGURA_AST            ; verificar a coluna direita do ast agora
        CMP R11, R6                     ; comparar com a coluna da sonda
        JNZ linha_de_baixo              ; se nao forem iguais verificamos se a colisao foi na linha de baixo do ast
        MOV R0 ,R7                      ; reset na variavel R0
        loop_linhas_2:                  ; a sonda esta na mesma coluna que o asteroide vamos ver se esta numa das suas linhas
            CMP R0, R3                  ; compara a linha do ast com a da sonda
            JZ tem_colisao              ; verifica a colisao
            ADD R0, 1                   ; prox linha
            SUB R1, 1                   ; percorre todas as linhas do ast
            JNZ loop_linhas_2
        linha_de_baixo:
        MOV R0 , R7                     ; reset
        MOV R11 , R8                    ; reset
        ADD R0 ,TAMANHO_AST             ; linha abaixo da ultima linha do ast
        CMP R0, R3                      ; compara com a linha da sonda
        JGE loop_colunas                ; condição para ocorrer colisao
        JMP nao_tem_colisao
        loop_colunas:                   ; verificamos em qual das colunas a sonda esta
            CMP R11 , R6                ; verifica coluna
            JZ tem_colisao              
            ADD R11, 1                  ; prox coluna
            SUB R2,1                    ; contador
            JNZ loop_colunas            ; repete o ciclo ate verificarmos todas as colunas do ast
            JMP nao_tem_colisao
    
    tem_colisao:
        MOV R2, 1               ; RESULTADO R2 = 1 houve colisao
        MOV R6, R9              ; guarda a instancia da sonda em R6
        MOV R9, TAMANHO_AST
        CALL apaga_boneco       ; apaga o ast
        MOV R1, colisao_sonda
        MOV [R1 + R6], R2       ; muda o valor deste endereço que indica que esta sonda colidiu     
        JMP fim_rotina

    nao_tem_colisao:                    ;verifica as 3 sondas
        CMP R9, 4                   ; contador das instâncias
        JZ fim_colisao
        ADD R9, 2                   ; +2 porque sao WORDS para mudar de endereço (prox sonda)
        MOV R3, [R4 + R9]                ; linha sonda
        MOV R6, [R5 + R9]                ; coluna sondas
        MOV R0 , R7                 ; reset na linha do ast
        MOV R11, R8                 ; reset na coluna do ast
        JMP deteta_colisao          ; repete o ciclo ate verificar as 3 sondas

    fim_colisao:
        MOV R2, 0                   ; se nao houver colisao o R2 é 0

    fim_rotina:
    POP R11 
    POP R9
    POP R8
    POP R7
    POP R6
    POP R5
    POP R4
    POP R3
    POP R1
    POP R0
    RET

; Rotina: colisao_ast_nave
; Verifica se ocorreu colisão entre o ast e a nave 
colisao_ast_nave:
    PUSH R0
    PUSH R1
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8
    PUSH R9
    PUSH R11

    MOV R1, atual_linha_ast
    MOV R7, [R1 + R10]                      ; obtem o valor da linha atual do ast   
    MOV R0 ,R7                              ; guarda em R0
    MOV R1, atual_coluna_ast
    MOV R8, [R1 + R10]                      ; obtem o valor da coluna atual do ast
    MOV R11 , R8                            ; guarda em R11
    MOV R1 , TAMANHO_AST
    MOV R2, LARGURA_AST
    MOV R4, LINHA_NAVE
    MOV R5 , COLUNA_NAVE
    MOV R3, TAMANHO_NAVE
    MOV R6, LARGURA_NAVE

    deteta_colisao_nave:
        linha_cima_nave:                    ; ver se o asteroide esta abaixo da linha superior à nave                      ; linha superior à linha da nave (hitbox)
            ADD R0 , R1                     ; linha em baixo da do asteroide (hitbox)
            CMP R0, R4
            JGE verificar_colunas_nave      ; condição para haver colisao com a nave         
            JMP nao_tem_colisao_nave
            verificar_colunas_nave:          
            ADD R8, R2                      ; ver se o asteroide esta à direita da 1coluna da nave    
            DEC R5                          ; coluna à esquerda da nave
            ADD R6, 1                       ; coluna à direita do asteroide
            loop_verifica:
            CMP R8, R5                      ; Compara R8 com R5 (verifica se o asteroide está à esquerda da nave)
            JZ tem_colisao_nave             ; Salta para tem_colisao_nave se forem iguais
            CMP R11 , R5                    ; Compara R11 com R5 (verifica se o asteroide está à direita da nave)
            JZ tem_colisao_nave
            INC R5                          ; verifica a prox coluna da nave
            SUB R6,1                        ; diminui 1 no contador
            JNZ  loop_verifica              ; loop que verifica todas as colunas da nave
            JMP nao_tem_colisao_nave        ; se chegar aqui é porque nao ocorreu colisao
    
    tem_colisao_nave:
    MOV R1, playing_state
    MOV R2, 0
    MOV [R1], R2
    MOV R2, 3                               
    MOV [APAGA_ECRÃ], R2                    ; muda o ecrã
    MOV [SELECIONA_CENARIO_FUNDO], R2
    JMP fim_rotina_col_nave


    nao_tem_colisao_nave:
    MOV R2, 0                   ; resultado vai a 0

    fim_rotina_col_nave:
    POP R11 
    POP R9
    POP R8
    POP R7
    POP R6
    POP R5
    POP R4
    POP R3
    POP R1
    POP R0
    RET

; Rotina: display_hexa_to_decimal
; Transforma um número hexadecimal em decimal e atualiza o display
display_hexa_to_decimal:
	PUSH	R0
	PUSH    R1
	PUSH	R2
	PUSH	R4
	PUSH	R5
    PUSH    R6

    MOV R1 , energia_display
	MOV R0, [R1]    ; R0 contém o valor atual do display em hexadecimal
	MOV R1, 0		; inicializa as unidades e as dezenas a 0
	MOV R2, 0
	MOV R4, 10		; valor auxiliar para a divisao inteira / multiplicação
	MOV R6, 0		; registo que irá guardar o valor final do display

; unidades:
	MOV R5, R0		; guarda o valor original 
	MOD R5, R4		; calcula o resto da divisão do valor original por 10
	MOV R1, R5		; guarda o resto no registo das unidades

; dezenas:
	SUB R0, R5		; valor original - resto da divisão 
	DIV R0, R4		; valor atual a dividir por 10
	MOV R5, R0		; guarda o valor atual 
	MOD R5, R4		; resto da divisão do valor atual por 10
	MOV R2, R5		; guarda o resto no registo das dezenas

; centenas:
	SUB R0, R5		; valor atual - resto da divisão 
	DIV R0, R4		; valor atual a dividir por 10
	MOV	R5, R0		; guarda o valor atual 
	MOD	R5, R4		; resto da divisão do valor atual por 10

	SHL R2, 4		; move o valor das das dezenas 
	SHL R5, 8		; move o valor das centenas ( para ser mais facil somar)
	ADD R6, R1		; soma as unidades 
	ADD R6, R2		; soma as dezenas
	ADD R6, R5		; soma as centenas 

fim_atualiza_display:
	MOV [DISPLAYS], R6 ; guarda o novo valor do display
    
    POP     R6
	POP		R5
	POP		R4
	POP		R2
    POP 	R1
	POP		R0
	RET


; Rotina: rotina_start
; Comeca o jogo
rotina_start:
    PUSH R1
    PUSH R2
    MOV R1, 1
    MOV [SELECIONA_CENARIO_FUNDO], R1
    MOV R1, playing_state                  ;altera o estado do jogo para ativado
    MOV R2, [R1]                           ;altera o estado do jogo para ativado
    MOV R2, 1                              ;altera o estado do jogo para ativado
    MOV [R1], R2                           ;altera o estado do jogo para ativado
    POP R2
    POP R1
    RET


; Rotina: rotina_start
; Termina o jogo
rotina_gameover:
    PUSH R1
    PUSH R2
    MOV R1, 2
    MOV [APAGA_ECRÃ], R1
    MOV [SELECIONA_CENARIO_FUNDO], R1
    MOV R1, playing_state                   ;altera o estado do jogo para desativado
    MOV R2, [R1]                            ;altera o estado do jogo para desativado
    MOV R2, 0                               ;altera o estado do jogo para desativado
    MOV [R1], R2                            ;altera o estado do jogo para desativado
    POP R2
    POP R1
    RET


;Rotina: pause
;Pausa/Continua o jogo
pause:
    PUSH R9
    PUSH R8
    MOV R9, pause_state
    MOV R8, [R9]                            ;estado de pausa
	NOT R8                                  ;estado de pausa
    MOV [R9], R8                            ;estado de pausa
    POP R8        
    POP R9
	RET


; **********************************************************************
; ROT_INT_0 - 	Rotina de atendimento da interrupção 0
;			Faz simplesmente uma escrita no LOCK que o processo boneco lê.
;			Como basta indicar que a interrupção ocorreu (não há mais
;			informação a transmitir), basta a escrita em si, pelo que
;			o registo usado, bem como o seu valor, é irrelevante
; **********************************************************************
rot_int_0:
	MOV	[evento_int_0], R0	; desbloqueia processo boneco (qualquer registo serve)
	RFE


; **********************************************************************
; rot_int_1 - 	Rotina de atendimento da interrupção 1
;			Faz simplesmente uma escrita no LOCK que o processo sonda lê.
;			Como basta indicar que a interrupção ocorreu (não há mais
;			informação a transmitir), basta a escrita em si, pelo que
;			o registo usado, bem como o seu valor, é irrelevante
; **********************************************************************
rot_int_1:
	MOV	[evento_int_1], R0	; desbloqueia processo sonda (qualquer registo serve) 
	RFE


; **********************************************************************
; rot_int_2 - 	Rotina de atendimento da interrupção 2
;			Faz simplesmente uma escrita no LOCK que o processo energia lê.
;			Como basta indicar que a interrupção ocorreu (não há mais
;			informação a transmitir), basta a escrita em si, pelo que
;			o registo usado, bem como o seu valor, é irrelevante
; **********************************************************************
rot_int_2:
	MOV	[evento_int_2], R0	; desbloqueia processo energia (qualquer registo serve) 
	RFE

; **********************************************************************
; rot_int_3 - 	Rotina de atendimento da interrupção 3
;			Faz simplesmente uma escrita no LOCK que o processo nave lê.
;			Como basta indicar que a interrupção ocorreu (não há mais
;			informação a transmitir), basta a escrita em si, pelo que
;			o registo usado, bem como o seu valor, é irrelevante
; **********************************************************************
rot_int_3:
	MOV	[evento_int_3], R0	; desbloqueia processo nave (qualquer registo serve) 
	RFE