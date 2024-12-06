.data
    @ TP ORGA COM 4 GRUPO 10 UNGS : INTEGRANTES HITTA GONZALO , LOPEZ CIRO MARTIN , GODOY MARTIN.
    archivo: .asciz "palabras.txt"
    listaDePalabras: .space 245
    palabraEnJuego: .space 5
    numeroAleatorio: .word 0
    cantLetrasPalabra: .byte 0
    palabraUsuario: .space 10
    puntuacion: .asciz "  "
    volver_a_Jugar: .byte 1
    ranking_file: .asciz "ranking.txt"
   @colores
    color_rojo:   .asciz "\033[31m"
    color_verde:  .asciz "\033[32m"
    color_amarillo:  .asciz "\033[33m"
    color_reset: .asciz "\033[0m"                  @4 caracteres largo
    @mensajes
    mensaje_puntuacion: .asciz "   Puntos obtenidos en esta partida"
    mensaje_ingreso: .asciz "Ingrese una palabra de "
    mensaje_ingreso2: .asciz "  letras: "
    mensaje_Perdiste: .asciz "PERDISTE!"
    mensaje_volver_a_jugar: .asciz "\nsi quiere volver a jugar apretar 's', sino 'n' :"
    mensaje_ganaste: .asciz "GANASTE!"
    mensaje_Nick:   .asciz  " introduzca su NICK:  "
   @temp
    buffer: .space 100                         @ Buffer temporal para almacenar colores y caracteres
    bufferNombre: .space 10                     @para el nick
    bufferRankings: .space 50                  @para traer los rankings
    @const
    intentos: .byte 5
    @informartResultado: .asciz "Usted gano, el resultado es: "
     saltoLinia: .asciz "\n"    @ Definir carácter de nueva línea


.text
.global main

leer_palabras:
    @leer Archivo
    mov r7, #5       @ abrir archivo
    ldr r0, =archivo
    mov r1, #0       @ leer archivo
    mov r2, #0       @ permisos de lectura
    swi 0

    @ compruebo si se abre archivo
    cmp r0, #0
    blt error
    mov r6, r0       @ guardo el descriptor de archivo en r6


    mov r7, #3       @ leo el archivo
    mov r0, r6       @ descriptor del archivo
    ldr r1, =listaDePalabras @ direccion de la lista donde almacenar el contenido
    mov r2, #110     @ leer hasta 500 bytes
    swi 0

    cmp r0, #0       @ verificar si se leyó algo
    beq error
    bx lr

leer_palabra:   @
    push {r0, r1, r2, r7, lr}        

    @ Mostrar mensaje de ingreso
    bl imprimir_mensaje
    bl imprimir_mensaje2

    @ Leer entrada del usuario
    mov r7, #3                       @ leer
    mov r0, #0                       @ file descriptor (stdin)
    ldr r1, =palabraUsuario          @ buffer para almacenar la palabra
    mov r2, #20                      @ número máximo de bytes a leer
    swi 0

    @ Agregar terminador nulo al final de la palabra
    ldr r1, =palabraUsuario
    add r1, r1, r0                   @ mover el puntero al final de la palabra leída
    mov r2, #0                       @ terminador nulo
    strb r2, [r1]

    pop {r0, r1, r2, r7, lr}         
    bx lr

imprimir_mensaje:
    push {r0, r1, r2, r7, lr}        

    mov r0, #1                       @ descriptor 1 para salida implicito
    ldr r1, =mensaje_ingreso         @ puntero al mensaje
    mov r7, #4                       @ syscall salida por pantalla
    mov r2, #24                      @ largo del mensaje
    swi 0

    pop {r0, r1, r2, r7, lr}         
    bx lr

imprimir_mensaje2:
    push {r0, r1, r2, r7, lr}        

    mov r0, #1                       @ descriptor 1 para salida implicito
    ldr r1, =mensaje_ingreso2        @ puntero al mensaje
    ldr r2, =cantLetrasPalabra
    ldrb r3, [r2]
    add r3, r3, #48
    strb r3, [r1]
    mov r7, #4                       @ syscall salida por pantalla
    mov r2, #11                      @ largo del mensaje
    swi 0

    pop {r0, r1, r2, r7, lr}         
    bx lr
sortear_palabra:
     push {lr}

    @ Usar el reloj para obtener una semilla
    mov r7, #78             @ syscall al la funcion para tomar la hora actual del sistema para numero random
    mov r0, #0              @ quita la zona horaria
    mov r1, #0              @ settea a null
    swi 0                   @ Llamada al sistema


    @ mezclado para obtener un numero que nos sirva en el contexto del programa y que sea mas caotico.
    mov r1, r0             @ Copiar valor mezclado
    mov r2, #12            @ LIMITE DEL NUMERO ALEATORIO (0-10)
    add r1, r1, r8         @ Agregar intentos restantes como factor (residuo desde el main)
    add r1, r1, r3         @ Agregar otro contador como factor

    @ Calcular módulo
    udiv r3, r1, r2        @ División
    mul r4, r3, r2         @ Multiplicación
    sub r5, r1, r4         @ Obtener residuo

    @ Almacenar resultado
    ldr r6, =numeroAleatorio
    str r5, [r6]           @ Guardar número aleatorio

    pop {lr}
    bx lr


almacenarPalabra:
    mov r8, #0                  @ Inicializo el contador de letras de la palabra
    mov r3, #0                  @ Inicializo el contador de saltos de línea
    ldr r0, =listaDePalabras    @ Dirección de la lista de palabras

almacenar_loop:
    ldrb r1, [r0], #1           @ Cargar el siguiente byte de la lista y avanzar r0
    cmp r1, #0                  @ Comparar con el fin de la cadena
    beq fin_almacenar
    cmp r1, #10                 @ Comparar con el salto de línea
    beq incrementarLinea
    b almacenar_loop

incrementarLinea:
    add r3, r3, #1              @ Sumar el contador de líneas
    cmp r3, r5                  @ Si el contador de líneas es igual al número aleatorio...
    beq almacenarDireccion      @ Entonces saltamos a almacenar la palabra
    b almacenar_loop

almacenarDireccion:
    mov r4, r0                  @ Guardamos la dirección de la palabra en r4
    ldr r5, =palabraEnJuego     @ Dirección de destino: palabraEnJuego

    ldrb r1, [r4]               @ Cargamos el primer byte de la palabra

truncarLoop:
    cmp r1, #10                 @ Si encontramos un salto de línea
    beq truncar                 @ Entonces truncamos
    strb r1, [r5], #1           @ Almacenamos el byte en 'palabraEnJuego' y avanzamos r5
    add r4, r4, #1              @ Avanzamos en la dirección de la palabra original
    ldrb r1, [r4]               @ Cargamos el siguiente byte de la palabra

    add r8, r8, #1              @ Aumento el contador de letras

    b truncarLoop

truncar:
    mov r1, #0                  @ Ponemos un 0 al final de la palabra
    strb r1, [r5]               @ Escribimos el 0 en el final de 'palabraEnJuego'
    ldr r7, =cantLetrasPalabra
    strb r8, [r7]               @ Almacenamos la cantidad de letras en cantLetrasPalabra

    b fin_almacenar

fin_almacenar:
    bx lr                       @ Retornamos de la función

verificar_letras:
    push {lr}
    ldr r0, =palabraUsuario      @ puntero palabraUsuario
    ldr r1, =palabraEnJuego      @ puntero palabraEnJuego
    ldr r2, =cantLetrasPalabra   
    ldrb r2, [r2]                 @ Cantidad de letras
    mov r3, #0                   @ Indice palabraUsuario
    
    mov r10, r2                  @ cantidad de caracteres 

verificar_loop:
    cmp r3, r2                   @ Verificar fin
    bge fin_verificar

    ldrb r4, [r0, r3]           @ Cargar caracter palabraUsuario
    ldrb r5, [r1, r3]           @ Cargar caracter palabraEnJuego en misma posición
    
    @ Primero verificar si es verde (misma posición)
    cmp r4, r5                   
    beq es_verde                 @ Si son iguales en misma posición -> verde
    
    @ Si no es verde, buscar si existe en otra posición
    mov r6, #0                   @ Indice para recorrer palabraEnJuego
    mov r7, #0                   @ Flag encontrado

buscar_caracter:
    cmp r6, r2                   
    bge verificar_no_encontrado  @ Si no se encontró -> rojo
    
    cmp r6, r3                   @ Saltar la posición actual
    beq siguiente_busqueda
    
    ldrb r5, [r1, r6]           @ Cargar caracter palabraEnJuego
    cmp r4, r5                   @ Comparar caracteres
    beq es_amarillo             @ Si coincide en otra posición -> amarillo
    
siguiente_busqueda:    
    add r6, r6, #1              @ Siguiente caracter
    b buscar_caracter

es_verde:
    sub r10, r10, #1            @ Descontar un carcter para ver si gano
    ldr r6, =color_verde        @ puntero al codigo del color verde  
    bl imprimir_color           @ seteo la consola con el color verde
    mov r7, r4                 
    bl imprimir_caracter        @ imprimo el caracter en verde
    bl resetear_color
    b siguiente_caracter        @ siguiente caracter

es_amarillo:
    mov r7, #1                   @ Marcar como encontrado
    ldr r6, =color_amarillo           
    bl imprimir_color
    mov r7, r4                   
    bl imprimir_caracter
    bl resetear_color
    b siguiente_caracter

verificar_no_encontrado:
    cmp r7, #0                   @ Verificar si no se encontró
    bne siguiente_caracter
    
    ldr r6, =color_rojo         
    bl imprimir_color
    mov r7, r4                   
    bl imprimir_caracter
    bl resetear_color
siguiente_caracter:
    add r3, r3, #1              @ Siguiente caracter palabraUsuario
    b verificar_loop

fin_verificar:
    pop {lr}
    bx lr


imprimir_color:
    push {r0-r4, lr}            @ guardo regitros que estoy usando arriva

    mov r7, #4                  @ escribir
    mov r0, #1                  @ stdout
    mov r1, r6                  @ r6 tiene el puntero al color.
    mov r2, #5                  @ largo del codigo de color.
    swi 0

    pop {r0-r4, lr}            @ pop me gusta mas el rock.
    bx lr

imprimir_caracter:             @es un hot fix ya que no podiamos imprimir correctamente, este metodo anda.
    push {r0-r4, lr}           @ limpio

    mov r7, #4                 @ syscall escribir
    mov r0, #1                 @ file desc stdout
    push {r4}                  @ guardo el caracter a imprimir en stack
    mov r1, sp                 @ uso el stack como puntero temporar para imprimir carater. asi no imprimo director de registros.
    mov r2, #1                 @ largo 1 byte
    swi 0
    add sp, sp, #4            @ restauro el stack 4 son los que nos movimos ahora volvemos

    pop {r0-r4, lr}           @ restauro.
    bx lr

saltoDeLinea:
    push {r0-r2,r7, lr}          
    mov r0, #1                    @ stdout
    ldr r1, =saltoLinia           @ guardado "/n"
    mov r2, #1                    @ cuenta como 1byte
    mov r7, #4                    @ write
    swi 0
    pop {r0-r2,r7, lr}          
    bx lr

imprimir_Perdiste:
    push {r0, r1, r2, r7, lr}        

    mov r0, #1                       @ descriptor 1 para salida implicito
    ldr r1, =mensaje_Perdiste         @ puntero al mensaje
    mov r7, #4                       @ syscall salida por pantalla
    mov r2, #10                      @ largo del mensaje
    swi 0

    pop {r0, r1, r2, r7, lr}         
    bx lr


calcular_puntos:
    push {r0-r7, lr}

    @ Cargar cantidad de letras de la palabra y los intentos restantes
    
    ldr r0, =cantLetrasPalabra      @ pointer cantLetrasPalabra
    ldrb r1, [r0]                    @ Cargar cantidad de letras en r1
    ldr r0, =intentos               @ pointerino intentos
    ldrb r2, [r0]                   @ Cargar intentos restantes en r2
    mul r3, r1, r2                  @ Puntaje = cantLetras * intentos

    @ Convertir puntaje a ASCII y sobrescribir en el mensaje
    ldr r0, =mensaje_puntuacion             @ mensaje puntuacion
    ldr r12,=puntuacion                     @ puntos en memoria
    cmp r3, #9                              @ ¿Es un solo dígito?
    ble un_digito                           @ Si es <= 9, manejar como un dígito

dos_digitos:
    mov r4, #0              @ Inicializar cociente
div_loop:
    cmp r3, #10             @ ¿r3 < 10?
    blt division_done       @ Si es menor, salir del bucle
    sub r3, r3, #10         @ Resta 10 del dividendo
    add r4, r4, #1          @ Incrementa el cociente
    b div_loop              @ Repite el bucle

division_done:
    
    add r4, r4, #48         @ Convertir cociente a ASCII
    strb r4,[r12]
    strb r4, [r0]           @ Sobrescribir primer carácter del mensaje

    
    add r3, r3, #48         @ Convertir el resto a ASCII
    strb r3,[r12,#1]           @guardo en puntuacion el segundo dijito
    strb r3, [r0, #1]       @ Sobrescribir segundo carácter del mensaje

    b imprimir                      

un_digito:
    add r3, r3, #48                 @ Convertir a ASCII
    strb r3,[r12]                   @guardo valor en puntuacion.
    strb r3, [r0]                   @ agrego un digito a la cadena al principio.

imprimir:
    mov r0, #1                      @ stdout
    ldr r1, =mensaje_puntuacion             @ resultado
    mov r2, #36                     @ 33 largo contando 0
    mov r7, #4                      @  syscall write
    swi 0                           

    pop {r0-r7, lr}                 
    bx lr                           

fin_del_juego:  @se encarga de manejar a los jugadores que pierden
    bl imprimir_Perdiste
    bl calcular_puntos
    bl opcion_volver_a_jugar

reset_buffers:
    push {r0-r2, lr}
    @ Limpiar palabraUsuario
    ldr r0, =palabraUsuario
    mov r1, #0
    mov r2, #10                  @ Tamaño del buffer
limpiar_buffer_loop:
    strb r1, [r0], #1
    subs r2, r2, #1
    bne limpiar_buffer_loop
    pop {r0-r2, lr}
    bx lr


opcion_volver_a_jugar:
    push {r0-r4,lr}

preguntar:
    @ Mensaje al jugador
    mov r0, #1                       @ Descriptor 1 para salida estándar
    ldr r1, =mensaje_volver_a_jugar  @ Puntero al mensaje
    mov r7, #4                       @ Syscall: escribir en pantalla
    mov r2, #50                      @ Largo del mensaje
    swi 0

    @ Pedir valor al jugador
    mov r7, #3                       @ Syscall: leer entrada
    mov r0, #0                       @ File descriptor (stdin)
    ldr r1, =volver_a_Jugar          @ Buffer para almacenar la decisión
    mov r2, #1                       @ Leer 1 byte
    swi 0

    @ Evaluar la entrada del jugador
    ldr r0, =volver_a_Jugar
    ldrb r1, [r0]
    cmp r1, #'n'                     @ Comparar con 'n' (No)
    beq finalizar                    @ Si es 'n', finalizar el juego
    cmp r1, #'s'                     @ Comparar con 's' (Sí)
    
    @reset game
        bl reset_buffers                 @ Limpiar buffers
    ldr r0,=cantLetrasPalabra
    mov r2,#0
    strb r2,[r0]                      @reset cant letras
    


    ldr r0,=mensaje_puntuacion
    strb r2,[r0]                       @reset puntuacion
    
    reset_palabra_en_juego:
    ldr r0, =palabraEnJuego      @ Cargamos la dirección de palabraEnJuego
    mov r1, #0                  @ Valor que queremos escribir (0)
    mov r2, #10                 @ Longitud de la palabra (por ejemplo 10)
    reset_loop:
    strb r1, [r0], #1           @ Escribimos 0 y avanzamos a la siguiente posición
    subs r2, r2, #1             @ Decrementamos el contador
    cmp r2, #0                  @ Si hemos llegado al final de la palabra
    bne reset_loop              @ Si no, repetimos

b jugar                             @ Si es 's', reiniciar el juego

                                    @ Si la entrada es inválida, repetir la pregunta
@b preguntar                         @ Repetir en caso de entrada inválida

ganaste:
    push {r0-r4,lr}
    @mensaje al jugador.
    mov r0, #1                       @ descriptor 1 para salida implicito
    ldr r1, =mensaje_ganaste         @ puntero al mensaje
    mov r7, #4                       @ syscall salida por pantalla
    mov r2, #9                      @ largo del mensaje
    swi 0

    pop {r0-r4,lr}         
    b ganador_Post_Game
    
    
    
    

cerrarArchivo:
    push {r0-r7,lr}
    mov r0, r6             @ descriptor de archivo
    mov r7, #6             @ syscall para cerrar archivo
    swi 0
    pop {r0-r7,lr}
    bx lr

error:
    push {lr}
    mov r0, #1             @ codigo de error
    mov r7, #1             @ salgo
    swi 0
    pop {lr}
    bx lr

resetear_color:
    push {r0,r1,r2,r7,lr}
    mov r0,#1
    ldr r1,=color_reset
    mov r7,#4
    mov r2,#5
    swi 0
    pop {r0,r1,r2,r7,lr}
    bx lr

@cosas para el ranking
pedir_nombre:
    push {r0, r1, r2, r7, lr}        @ Guardar registros y lr

    mov r0, #1                       @ descriptor 1 para salida implícita
    ldr r1, =mensaje_Nick            @ puntero al mensaje
    mov r7, #4                       @ syscall salida por pantalla
    mov r2, #21                      @ largo del mensaje
    swi 0

    mov r7, #3                       @ syscall: read
    mov r0, #0                       @ file descriptor: stdin
    ldr r1, =bufferNombre             @ buffer para almacenar el nombre
    mov r2, #34                      @ número máximo de bytes a leer
    swi 0

    pop {r0, r1, r2, r7, lr}         @ Restaurar registros y lr
    bx lr

grabar_ranking:
    push {r0, r1, r2, r7, lr}        @ Guardar registros y lr

    mov r7, #5                       @ abrir archivo
    ldr r0, =ranking_file
    mov r1, #1089                       @ escribir archivo 
    mov r2, #0644                    @ permisos de escritura
    swi 0

    cmp r0, #0                       @ verificar si se abrió el archivo
    blt error
    mov r6, r0                       @ guardar el descriptor de archivo en r6

  @ Escribir nombre
    mov r7, #4                       
    mov r0, r6                       
    ldr r1, =bufferNombre            
    mov r2, #10                      
    swi 0


   @ Escribir puntuación
    mov r7, #4                       
    mov r0, r6                       
    ldr r1, =saltoLinia             
    mov r2, #1                      @ 2 bytes para la puntuación
    swi 0

    @ Escribir salto de línea
    mov r7, #4
    mov r0, r6
    ldr r1, =puntuacion
    mov r2, #2
    swi 0

    @ Escribir salto de línea
    mov r7, #4
    mov r0, r6
    ldr r1, =saltoLinia
    mov r2, #1
    swi 0


    @ Cerrar archivo
    mov r7, #6                       
    mov r0, r6                       
    swi 0

    pop {r0, r1, r2, r7, lr}         @ Restaurar registros y lr
    bx lr

mostrar_ranking:
    push {r0, r1, r2, r7, lr}        @ Guardar registros y lr

    mov r7, #5                       @ abrir archivo
    ldr r0, =ranking_file
    mov r1, #0                       @ leer archivo
    mov r2, #0                       @ permisos de lectura
    swi 0

    cmp r0, #0                       @ verificar si se abrió el archivo
    blt error
    mov r6, r0                       @ guardar el descriptor de archivo en r6

    mov r7, #3                       @ leer el archivo
    mov r0, r6                       @ descriptor del archivo
    ldr r1, =bufferRankings          @ dirección del buffer
    mov r2, #50                    @ leer hasta 50 bytes
    swi 0

    cmp r0, #0                       @ verificar si se leyó algo
    beq error

    mov r7, #4                       @ escribir en pantalla
    mov r0, #1                       @ descriptor de salida
    ldr r1, =bufferRankings          @ dirección del buffer
    mov r2, #45                       @ bytes leídos
    swi 0

    mov r7, #6                       @ cerrar archivo
    mov r0, r6                       @ descriptor del archivo
    swi 0

    pop {r0, r1, r2, r7, lr}         
    bx lr


@COMIENZO DE NUESTRO MAIN (PUNTO DE ENTRADA DEL PROGRAMA)
main:
    @inicializacion del juego.
    bl leer_palabras
jugar:                          @zona de "Game Play"
    bl resetear_color
    bl sortear_palabra
    bl almacenarPalabra
    bl cerrarArchivo
    ldr r9, =intentos           @ Cargar dirección de intentos
    mov r8, #5                  @ Valor inicial de intentos
    strb r8, [r9]               @ Guardar valor inicial

main_loop:                      @partida limitada por intentos. "TICK"
    bl leer_palabra             @tomo palabra por teclado
    bl verificar_letras         @ compara las palabras e imprime el resultado por pantalla.
    bl saltoDeLinea             @ aliniacion de lineas dsp de resultado.
    cmp r10, #0                 @ Verificar si ganó
    beq ganaste

    ldr r9, =intentos           @ Cargar dirección de intentos
    ldrb r8, [r9]               @ Cargar valor actual
    sub r8, r8, #1              @ Decrementar intentos
    strb r8, [r9]               @ Guardar nuevo valor
    
    cmp r8, #0                  @ Verificar si quedan intentos
    ble fin_del_juego           @ Si no quedan intentos, finalizar
    b main_loop                 @ Siguiente intento
    @zona de los ganadores Post Game
    ganador_Post_Game:
        bl saltoDeLinea             @ aliniasion de lineas dsp de resultado.
        bl calcular_puntos          @ calcula los puntos, los convierte en ascii e imprime
        bl pedir_nombre             @ nick del jugador
        bl grabar_ranking        @ guardo en archivo de texto el nomre
        bl mostrar_ranking
        bl opcion_volver_a_jugar
finalizar:
    mov r7, #1
    swi 0
