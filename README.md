# Mini Shopify Theme CLI

Una capa pequeña de funciones para **zsh** sobre Shopify CLI que elimina repetición al trabajar con themes.

En vez de escribir `--store` y `--theme` en cada comando:

```bash
shopset hushpuppiescl 154133397678
spull
spush
sdev
smeta
slist
```

## Lo principal

- Contexto store/theme por sesión con `shopset`.
- La tienda se puede escribir solo con el prefijo (`hushpuppiescl`); `shopset` completa el `.myshopify.com`.
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

`install.sh` copia los archivos a `~/.mini-shopify-theme-cli/`, y `~/.zshrc` carga esa copia. Los cambios que hagas en el repo no se aplican hasta que vuelvas a ejecutar `./install.sh`.

### Modo desarrollo (`--link`)

Si vas a modificar el CLI, instala con enlaces en vez de copias:

```bash
./install.sh --link
./install-agents.sh
source ~/.zshrc
```

Así `~/.mini-shopify-theme-cli/` queda enlazado al repo y tus cambios se aplican con `source ~/.zshrc`, sin reinstalar. A cambio:

- Cada terminal nueva carga lo que haya en el repo en ese momento, también si cambias de rama o dejas una edición a medias.
- Si mueves o borras el repo, vuelve a ejecutar `./install.sh --link` desde la nueva ubicación.

Para volver al modo copia, ejecuta `./install.sh` sin opciones.

## Uso

```bash
shopset hushpuppiescl 154133397678
shopget
```

La tienda puede ser el prefijo (`hushpuppiescl`), el dominio (`hushpuppiescl.myshopify.com`) o la URL (`https://hushpuppiescl.myshopify.com/admin`). `shopset` siempre la guarda como `hushpuppiescl.myshopify.com`.

El dominio propio de la tienda (por ejemplo `tienda.cl`) no sirve: Shopify CLI necesita el dominio `.myshopify.com`, que aparece en el admin en **Settings > Domains**. El prefijo no siempre coincide con el nombre de la marca.

### Elegir theme

Si no sabes el ID del theme, selecciona solo la tienda, lista los themes y elige:

```bash
shopset hushpuppiescl
slist
shopset hushpuppiescl 154133397678
```

`shopset` sin theme borra el `SHOP_THEME` anterior, para no quedar apuntando a un theme de otra tienda. Mientras no haya theme, `spull`, `spush` y los demás comandos que lo necesitan se niegan a ejecutarse.

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
| `shopset STORE [THEME]` | Selecciona tienda y theme (sin theme: solo tienda) |
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

El script instala la skill de usuario de Codex en `~/.agents/skills/mini-shopify-theme-cli` y agrega una importación global a `~/.claude/CLAUDE.md` para Claude Code. El archivo canónico es `skill/SKILL.md`. Si instalaste con `--link`, la skill también queda enlazada al repo.

Los agentes suelen ejecutar cada comando en un shell nuevo, así que el contexto de `shopset` no se mantiene entre un comando y otro. La skill les indica:

- Encadenar `shopset` con el comando (`shopset hushpuppiescl 154133397678 && spull`).
- Anotar el nuevo ID después de `sdup`.
- No ejecutar `spublish` por su cuenta.

## Actualizar

Instalación normal (copia):

```bash
git pull
./install.sh
./install-agents.sh
source ~/.zshrc
```

Con `--link` basta con:

```bash
git pull
source ~/.zshrc
```

## Desinstalar

```bash
./uninstall.sh
```

Funciona en los dos modos; con `--link` borra los enlaces, no el repo.

## Tests

```bash
zsh tests/smoke.zsh
bash tests/install.sh
```

`tests/install.sh` prueba los instaladores con un `HOME` temporal; no toca tu instalación.

## Licencia

MIT.
