# ============================================================
# PROYECTO: CinnamorolAR — Flutter AR App + FastAPI MCP Backend
# ENTREGA: Lunes
# HERRAMIENTAS: Google Antigravity 2.0 · Git LFS · MCP · ARCore
# ============================================================

## DESCRIPCIÓN GENERAL
Aplicación Flutter para Android que usa ARCore para detectar superficies
planas (horizontales y verticales) con la cámara trasera. Al detectar una
superficie, proyecta una rejilla elegante sobre ella con el texto
"Superficie detectada". Al tocar la rejilla, coloca el personaje
Cinnamoroll (modelo .glb) anclado a esa superficie con precisión y
estabilidad. Un backend FastAPI expone herramientas MCP que la app consume.
Todo el backend corre en Docker. Los assets 3D se versionan con Git LFS.

## STACK TECNOLÓGICO

### Flutter / Android
- Flutter 3.x, Dart ^3.0, null safety
- ar_flutter_plugin_engine (ARCore en Android)
- flutter_riverpod ^2.x — state management
- go_router — navegación
- permission_handler — permiso CAMERA en runtime
- dio — cliente HTTP para MCP y descarga de assets
- path_provider — caché local del .glb
- package:logger — logging estructurado (PROHIBIDO print())
- flutter_lints — análisis estático obligatorio

### Backend
- Python 3.11
- FastAPI
- mcp[server] (Python MCP SDK)
- SQLite con aiosqlite
- Docker + docker-compose
- Uvicorn como servidor ASGI

### Assets
- Git LFS para cinnamoroll.glb y texturas
- .gitattributes ya configurado en el repo

## ESTRUCTURA DE CARPETAS OBLIGATORIA

### Flutter
lib/
  core/
    ar/
      ar_session_service.dart
      plane_detection_service.dart
      plane_overlay_controller.dart
      anchor_manager.dart
    mcp/
      mcp_client.dart
      mcp_models.dart
    network/
      asset_downloader.dart
    constants.dart
    errors/
      app_exceptions.dart
  features/
    ar_viewer/
      data/
        character_repository.dart
      domain/
        place_character_usecase.dart
        detect_plane_usecase.dart
      presentation/
        ar_viewer_screen.dart
        ar_viewer_state.dart
        widgets/
          plane_grid_overlay.dart
          character_node_widget.dart
          status_hud_widget.dart
  shared/
    theme/
      app_theme.dart
    widgets/
      error_screen.dart
      loading_screen.dart

assets/
  models/
    cinnamoroll.glb  ← YA EXISTE en el repo via Git LFS
  textures/

test/
  unit/
    ar/
    mcp/
  widget/
  integration/

### Backend
backend/
  app/
    main.py
    mcp_server.py
    database.py
    models.py
    routers/
      health.py
      assets.py
  assets/
    cinnamoroll.glb
  docker-compose.yml
  Dockerfile
  requirements.txt
  .env.example

## REQUERIMIENTOS FUNCIONALES — FRONTEND

### RF-F1 Permisos
Al primer inicio solicitar permiso CAMERA con permission_handler.
Si se niega, mostrar ErrorScreen con instrucciones. No crashear.

### RF-F2 Verificación de backend
Al iniciar llamar GET /health. Si no responde mostrar banner
"Modo offline" y continuar con datos hardcodeados de Cinnamoroll.

### RF-F3 Detección HORIZONTAL_AND_VERTICAL
Rejilla azul para horizontal, rejilla verde para vertical.

### RF-F4 Overlay de rejilla ESTABLE — CRÍTICO
a) Anclar overlay al Trackable del plano (NO a la cámara)
b) setSmoothed(true) en AnchorNode para interpolar transformaciones
c) Actualizar dimensiones SOLO cuando el plano cambia más de 2cm
d) Líneas finas (1-2px), semitransparentes (opacity 0.6)
e) Fade-in suave 300ms al detectar el plano
f) Texto "Superficie detectada" con sombra sutil para legibilidad

### RF-F5 Esquinas y bordes
Usar boundary points de ARCore para marcar esquinas con círculos
de 4dp del mismo color que la rejilla, opacity 0.85.

### RF-F6 Colocación de Cinnamoroll
1. Hit-test ARCore → posición 3D exacta
2. Llamar MCP get_character_info(plane_type) → escala recomendada
3. Fallback si MCP falla: escala 0.1 horizontal, 0.08 vertical
4. Renderizar cinnamoroll.glb anclado con setSmoothed(true)
5. Cinnamoroll mira hacia la cámara al colocarse (billboard Y-axis)
6. Llamar MCP log_session() en background

### RF-F7 Un personaje activo a la vez
Al colocar nuevo personaje, liberar anchor y nodo anterior.

### RF-F8 Caché del modelo
Primera vez: descargar de GET /assets/cinnamoroll.glb con indicador
de progreso. Siguientes veces: usar caché local.

### RF-F9 HUD de estado
- "Moviendo el teléfono para detectar superficies..."
- "Superficie detectada — toca para colocar a Cinnamoroll"
- "Cinnamoroll colocado ✓" (desaparece a los 2 segundos)

### RF-F10 Ciclo de vida
paused → pausar ARCore, resumed → reanudar, dispose → liberar todo.

## REQUERIMIENTOS FUNCIONALES — BACKEND

### RF-B1 GET /health → {"status": "ok", "version": "1.0.0"}

### RF-B2 GET /assets/cinnamoroll.glb
Servir archivo binario, Content-Type: model/gltf-binary

### RF-B3 MCP Tool: get_character_info
Input: plane_type ("horizontal_up" | "horizontal_down" | "vertical")
Output: { name, description, scale, rotation_offset, model_url }
Escalas: horizontal_up=0.10, horizontal_down=0.08, vertical=0.09

### RF-B4 MCP Tool: log_ar_session
Input: { plane_type, placed_successfully, timestamp }
Guardar en SQLite tabla ar_sessions.
Output: { "logged": true, "session_id": int }

### RF-B5 SQLite
CREATE TABLE ar_sessions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  plane_type TEXT NOT NULL,
  placed_successfully INTEGER NOT NULL,
  timestamp TEXT NOT NULL,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

### RF-B6 CORS: allow_origins=["*"]

## REQUERIMIENTOS NO FUNCIONALES

- Overlay de rejilla NO debe temblar bajo ninguna circunstancia
- Cinnamoroll una vez colocado NO debe moverse ni flotar
- flutter analyze: CERO errores y CERO warnings
- Sin print(), solo package:logger
- Sin hardcoding: todo en constants.dart o .env
- docker-compose up levanta todo en un comando
- Puerto configurable via BACKEND_PORT (default 8000)
- IP del backend en Flutter va en .env

## DISEÑO VISUAL DE LA REJILLA

HORIZONTAL (piso/mesa):
- Cuadrícula cada 10cm en el mundo real
- Color líneas: rgba(100, 180, 255, 0.6) azul claro
- Borde exterior: rgba(100, 180, 255, 0.9)
- Esquinas: círculos 4dp, mismo azul, opacity 0.85
- Texto "Superficie detectada": blanco, 14sp, sombra negra 1px
- Fade-in 300ms

VERTICAL (pared):
- Igual pero color: rgba(100, 255, 180, 0.6) verde menta

PRINCIPIO: rejilla discreta, Cinnamoroll es el protagonista.
Al colocar Cinnamoroll la rejilla desaparece con fade-out 500ms.

## PROCESO QA OBLIGATORIO — EJECUTAR EN ORDEN

1. SCAFFOLD: crear estructura completa de carpetas y archivos
2. BACKEND: FastAPI + MCP + SQLite + Docker
   → Verificar: docker-compose up sin errores, /health responde
3. AR CORE: session → detection → overlay anti-jitter
   → Verificar: flutter analyze pasa
4. OVERLAY: implementar RF-F4 completamente
5. FEATURES: use cases → repository → presentation
6. INTEGRACIÓN MCP: conectar Flutter con backend
7. TESTS: unit → widget → integration
8. BUILD: flutter build apk --debug sin errores
9. README.md con instrucciones completas

BLOQUEANTES — detener y reportar si ocurre:
- flutter analyze con errores
- docker-compose up falla
- flutter build apk falla
- ARCore no inicializa

## ENTREGABLES FINALES
- APK debug funcional en Android ARCore compatible
- Overlay de rejilla estable sin temblor
- Cinnamoroll colocado y anclado correctamente
- Backend en Docker con docker-compose up
- MCP tools funcionando
- SQLite guardando sesiones
- flutter test 100%
- flutter analyze sin errores
- README.md completo