# ConectaTech: Modelo Relacional Avanzado para Gestión de Congresos

Este repositorio contiene la arquitectura completa de datos para el dominio de gestión del congreso de programación **ConectaTech**, implementado sobre **PostgreSQL 18** dentro de contenedores orquestados con **Docker Compose**.

## 1. Requisitos Previos
* Docker Engine 24.0+ y Docker Compose v2.20+
* Cliente `psql` (opcional, si se prefiere interactuar localmente)

## 2. Puesta en Marcha Rápida (Desde Cero)

### Paso 1: Configuración de Variables de Entorno
Copie el archivo de ejemplo:
```bash
cp .env.example .env
