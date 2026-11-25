# Entorno SQL reproducible con Podman

Entorno local de PostgreSQL y Adminer dentro de un mismo Pod de Podman, pensado para practicar SQL y análisis de datos sin instalar nada directamente en Windows.

## Qué incluye

- Pod `pod-analisis-datos` con los puertos 8080 (Adminer) y 5432 (PostgreSQL)
- PostgreSQL 16 con volumen persistente `pgdata`
- Adminer como interfaz web ligera, conectada por `localhost` dentro del Pod
- Script de inicialización que exige contraseña también en conexiones locales

## Requisitos

- Windows 10 u 11 con Podman Desktop instalado y su máquina en ejecución
- PowerShell

## Puesta en marcha

1. Copia `.env.example` como `.env` y cambia la contraseña

```powershell
Copy-Item .env.example .env
```

2. Crea el volumen y el Pod

```powershell
podman volume create pgdata
podman pod create --name pod-analisis-datos -p 8080:8080 -p 5432:5432
```

3. Levanta PostgreSQL

```powershell
podman run -d --pod pod-analisis-datos --name postgres `
  --env-file .env `
  -v pgdata:/var/lib/postgresql/data `
  -v "${PWD}\init:/docker-entrypoint-initdb.d:Z" `
  docker.io/library/postgres:16
```

4. Levanta Adminer

```powershell
podman run -d --pod pod-analisis-datos --name adminer docker.io/library/adminer
```

5. Abre http://localhost:8080 y entra con:

| Campo | Valor |
|---|---|
| Motor | PostgreSQL |
| Servidor | localhost |
| Usuario | el de tu `.env` |
| Contraseña | la de tu `.env` |
| Base de datos | la de tu `.env` |

## Apagar, reiniciar y borrar

```powershell
podman pod stop pod-analisis-datos      # apagar
podman pod start pod-analisis-datos     # volver a encender
podman pod rm -f pod-analisis-datos     # borrar el Pod (los datos siguen en el volumen)
podman volume rm pgdata                 # borrar también los datos
```

## Decisiones técnicas

**Podman en lugar de Docker:** no necesita un demonio corriendo en segundo plano.

**Volumen nombrado:** PostgreSQL suele fallar por permisos al usar carpetas montadas desde Windows, y un volumen de Podman evita ese problema.

**Credenciales en `.env`:** el archivo real no se sube al repositorio, solo `.env.example` con valores de ejemplo.

**Script `init/seguridad.sh`:** la imagen oficial deja las conexiones desde `127.0.0.1` en modo `trust`, y como Adminer comparte `localhost` con la base, aceptaba cualquier contraseña. El script cambia ese modo a `scram-sha-256` al crear la base por primera vez.

## Estructura

```
entorno-sql-podman/
├── README.md
├── .env.example
├── .gitignore
└── init/
    └── seguridad.sh
```

## Próximos pasos

- Cargar un dataset público y responder preguntas de negocio con SQL
- Documentar las consultas en una carpeta `sql/`