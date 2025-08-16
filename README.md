# Accountable-Bussiness-App

Este proyecto es parte de mi proceso de aprendizaje en el desarrollo de software.

## Descripción

Es una aplicación de escritorio desarrollada en Python con la librería PyQt6 para la interfaz gráfica. Se conecta a una base de datos PostgreSQL para gestionar información contable de negocios. Las funcionalidades incluyen:

*   Inicio de sesión de usuario.
*   Gestión de entidades (empresas).
*   Manejo de subdiarios contables (Caja, Bancos, Ventas, Compras, etc.).
*   Importación y exportación de datos.
*   Generación de reportes (preliquidaciones, detracciones).
*   Generación de libros electrónicos (PLE) y PDB para la SUNAT (Superintendencia Nacional de Aduanas y de Administración Tributaria de Perú).

## Ejecución

Para ejecutar la aplicación, se debe correr el archivo `guiprograma.py`. Se necesita tener Python instalado con las librerías `PyQt6`, `sqlalchemy`, `pandas` y `openpyxl`. También es necesaria una conexión a la base de datos PostgreSQL con la estructura definida en `oficina_tables.sql` y los procedimientos de `stored_procedures.sql`.

```bash
python guiprograma.py
```

---
*Esta reseña fue generada con la ayuda de Gemini.*