# Juego de Wordle en Ensamblador (Assembly ARMv6 - Raspberry Pi)
![image](https://github.com/user-attachments/assets/17eb37a3-263b-46a0-9569-76992785a0f8)
##VIDEO
[![Video del Proyecto](https://img.youtube.com/vi/bTxkskolrQo/maxresdefault.jpg)](https://www.youtube.com/watch?v=bTxkskolrQo)
- 
- Este proyecto es un **juego de Wordle para consola**, desarrollado en lenguaje ensamblador ARMv6 para la **Raspberry Pi v1.2**. Representa la aplicación de técnicas de programación de bajo nivel aprendidas en la materia *Organización del Computador*.

---

## 📜 Descripción General

El objetivo del juego es adivinar una palabra oculta en un número limitado de intentos. Cada intento se compara con la palabra objetivo, proporcionando retroalimentación mediante códigos de colores:  
- **🟩 Verde:** Letra correcta en la posición correcta.  
- **🟨 Amarillo:** Letra correcta en una posición incorrecta.  
- **🟥 Rojo:** Letra incorrecta.

---

## 🎯 Metas del Proyecto

1. Desarrollar el programa en lenguaje ensamblador, cumpliendo las especificaciones solicitadas.
2. Crear un informe que incluya el pseudocódigo del programa y las experiencias/dificultades encontradas durante el desarrollo.

---

## 🛠️ Especificaciones del Juego

- Las palabras se cargan desde un archivo de texto.
- El juego tiene un número limitado de intentos.
- El jugador puede ingresar una palabra por intento.
- Comparaciones entre palabras con retroalimentación en colores (verde, amarillo, rojo).
- Se calcula una puntuación basada en los intentos y se ofrece al jugador la opción de guardarla con su apodo.
- Opción de volver a jugar o salir del programa.

---

## 📖 Estructura del Programa

### 1. Sección `.data`
Alberga los datos del programa:
- **Etiquetas principales:** Palabras, puntuación, mensajes, buffers, intentos y códigos de color para la consola.

### 2. Sección `.text`
Incluye las principales funciones y subrutinas:
- **Leer_palabras:** Carga palabras desde un archivo.
- **Sortear_palabra:** Selecciona una palabra al azar.
- **Verificar_letras:** Compara palabras y asigna colores según coincidencias.
- **Calcular_puntos:** Calcula la puntuación de la partida.
- **Grabar_ranking:** Guarda el puntaje y apodo en un archivo.
- **Mostrar_ranking:** Muestra los puntajes guardados.
- **Main y Jugar:** Lógica principal del juego.

---

## 💡 Experiencias y Dificultades

- **Primer proyecto grande en ensamblador:** La organización y el flujo del programa fueron desafiantes.  
- **Manejo de archivos:** Las operaciones con archivos externos resultaron complejas.  
- **Aleatoriedad:** Se optó por una fórmula matemática al no lograr implementar correctamente un generador basado en el reloj del sistema.  
- **Tiempo limitado:** Algunos errores y detalles no pudieron pulirse por completo.

---

## 📚 Herramientas y Referencias

### Herramientas
- **Editores:** VS Code, Notepad++, Nano.  
- **Conexión:** PuTTY, WinSCP.  
- **Comunicación:** Telegram, Discord.  

### Referencias
- [wiki.educabit.ar](http://wiki.educabit.ar)  
- [ARM Developer Documentation](https://developer.arm.com)  
- [StackOverflow](https://stackoverflow.com)  

---

## 📝 Cómo Ejecutar el Programa

1. Asegúrate de tener configurado un entorno ARMv6 en una Raspberry Pi v1.2.
2. Clona este repositorio en tu dispositivo.
3. Compila el código ensamblador utilizando las herramientas adecuadas.
4. Ejecuta el programa en consola.

---

## 👥 Autores

- **Hitta Gonzalo Francisco**  
- **López Ciro Martín**  
- **Martín Godoy**  

---

Si tienes preguntas o comentarios, no dudes en abrir un *issue*. ¡Gracias por revisar nuestro proyecto! 🚀
---
## Instrucciones para usar:
1. Copia este contenido y pégalo en un archivo llamado README.md.
2. Sube el archivo a tu repositorio de GitHub.
3. Revisa el formato en la vista previa de GitHub; debería verse bien con encabezados, listas, emojis y enlaces funcionales.
---
