# Feasibilidad para agregar un filtro por nombre en la pestaña de alumnos

## Estado actual
- La vista `StudentsView` carga la lista completa de estudiantes desde la API al iniciar y la almacena en `_students` para renderizarla en un `ListView.builder`.
- El servicio `ApiService.getWithAuth` ya soporta pasar parámetros de consulta opcionales, lo que permitiría solicitar filtrados al backend si existiera un endpoint compatible.

## Estrategia recomendada
1. **Filtrado local inmediato:**
   - Añadir un `TextEditingController` y un campo de búsqueda (por ejemplo, dentro de `CustomAppHeader` o arriba de la lista).
   - Mantener una lista `_filteredStudents` que se actualice con `setState` al cambiar el texto, filtrando `_students` por nombre o apellido.
   - Esta solución es rápida de implementar y no requiere cambios en el backend.
2. **Filtrado desde el backend (opcional):**
   - Si el número de estudiantes es alto, se puede aprovechar `ApiService.getWithAuth` para enviar un parámetro `queryParams` con el nombre y delegar el filtrado al servidor.
   - Requiere confirmar que el endpoint `/api/v1/students/institution` acepte parámetros de búsqueda.

## Complejidad estimada
- **Frontend solamente:** Baja (≈1 vista + estado adicional). No se anticipan dependencias nuevas.
- **Frontend + soporte backend:** Media, dependiendo del soporte existente en la API.

## Consideraciones adicionales
- Actualizar la UI para mostrar cuando no haya resultados tras aplicar el filtro.
- Evaluar si se desea combinar el filtro por nombre con los filtros por grado/género previstos en el botón de "filtros".
