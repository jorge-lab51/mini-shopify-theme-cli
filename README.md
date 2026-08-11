# Mini Shopify Theme CLI

Una capa pequeña de funciones para **zsh** sobre Shopify CLI que elimina repetición al trabajar con themes.

En vez de escribir `--store` y `--theme` en cada comando:

```bash
shopset hushpuppiescl.myshopify.com 154133397678
spull
spush
sdev
smeta
slist
```

## Lo principal

- Contexto store/theme por sesión con `shopset`.
- `shopget` para comprobar dónde estás apuntando.
- `spull` y `spush` aceptan una sintaxis compacta con múltiples archivos después de `--only`.
- `sdup` duplica el theme y cambia automáticamente `SHOP_THEME` al ID del duplicado.
- No requiere `.shopify-theme` por proyecto.
- Incluye una skill/instrucciones para agentes.

## Requisitos

- zsh.
- Shopify CLI instalado y autenticado.
- Node.js (usado por `sdup` para leer JSON).

## Instalación

```bash
git clone <URL-DEL-REPOSITORIO>
cd mini-shopify-theme-cli
chmod +x install.sh install-agents.sh uninstall.sh
./install.sh
source ~/.zshrc
shelp
```

## Uso

```bash
shopset hushpuppiescl.myshopify.com 154133397678
shopget
```

### Pull parcial

```bash
spull --only \
  layout/theme.liquid \
  sections/cart-drawer.liquid
```

### Push parcial

```bash
spush --only \
  layout/theme.liquid \
  sections/cart-drawer.liquid \
  snippets/share-cart.liquid \
  assets/share-cart-import.js \
  config/settings_schema.json \
  assets/theme.css
```

### Duplicar y cambiar automáticamente al nuevo theme

```bash
sdup "IP 1234 | Tallas y Share Cart"
shopget
```

Luego `spull`, `spush` y `sopen` apuntan al duplicado.

## Comandos

| Comando | Uso |
|---|---|
| `shopset STORE THEME` | Selecciona tienda y theme |
| `shopget` | Muestra contexto actual |
| `slist` | Lista themes |
| `spull` | Pull |
| `spush` | Push |
| `smeta` | Pull de metafields |
| `sdev` | Theme dev |
| `sopen` | Abre/previsualiza theme |
| `sdup ["nombre"]` | Duplica y cambia al nuevo ID |
| `srename "nombre"` | Renombra |
| `spublish` | Publica con confirmación |
| `scheck` | Theme Check |
| `sinfo` | Theme info |
| `spackage` | Genera ZIP |
| `shelp` | Ayuda |

Los argumentos extra se reenvían a Shopify CLI, por ejemplo `spush --strict` o `slist --role unpublished`.

## Agentes

```bash
./install-agents.sh
```

El script instala la skill de usuario de Codex en `~/.agents/skills/mini-shopify-theme-cli` y agrega una importación global a `~/.claude/CLAUDE.md` para Claude Code. El archivo canónico es `skill/SKILL.md`.

## Actualizar

```bash
git pull
./install.sh
./install-agents.sh
source ~/.zshrc
```

## Desinstalar

```bash
./uninstall.sh
```

## Licencia

MIT.
