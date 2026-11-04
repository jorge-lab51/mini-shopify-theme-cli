# Mini Shopify Theme CLI

_shopify_check_cli() {
  if ! command -v shopify >/dev/null 2>&1; then
    echo "❌ Shopify CLI no está disponible en PATH."
    return 1
  fi
}

_shopify_check() {
  _shopify_check_cli || return
  if [[ -z "${SHOP_STORE:-}" ]]; then
    echo "❌ Primero ejecuta: shopset <tienda> <theme-id>"
    return 1
  fi
  if [[ -z "${SHOP_THEME:-}" ]]; then
    echo "❌ No hay theme seleccionado para $SHOP_STORE."
    echo "   Usa slist y luego: shopset ${SHOP_STORE%.myshopify.com} <theme-id>"
    return 1
  fi
}

_shopify_check_store() {
  _shopify_check_cli || return
  if [[ -z "${SHOP_STORE:-}" ]]; then
    echo "❌ Primero ejecuta: shopset <tienda> [theme-id]"
    return 1
  fi
}

# Normaliza la tienda a <handle>.myshopify.com y deja el resultado en REPLY.
# Acepta: mitienda, mitienda.myshopify.com, https://mitienda.myshopify.com[/admin][/]
_shopify_normalize_store() {
  local store="${(L)1}"
  local handle

  # Quita espacios al inicio y al final.
  store="${store#"${store%%[![:space:]]*}"}"
  store="${store%"${store##*[![:space:]]}"}"

  store="${store#http://}"
  store="${store#https://}"
  store="${store%/}"
  store="${store%/admin}"

  [[ "$store" == *.* ]] || store="$store.myshopify.com"

  handle="${store%.myshopify.com}"
  if [[ "$store" != *.myshopify.com || -z "$handle" || "$handle" == *[^a-z0-9-]* || "$handle" == -* || "$handle" == *- ]]; then
    echo "❌ Tienda no válida: $1"
    echo "   Usa el prefijo (mitienda) o el dominio myshopify.com (mitienda.myshopify.com)."
    echo "   El dominio propio de la tienda no sirve; el .myshopify.com aparece en Settings > Domains."
    return 1
  fi

  REPLY="$store"
}

_shopify_theme_args() {
  local only_mode=false
  SHOPIFY_THEME_ARGS=()

  for arg in "$@"; do
    if [[ "$arg" == "--only" || "$arg" == "-o" ]]; then
      only_mode=true
    elif [[ "$arg" == --* || "$arg" == -?* ]]; then
      only_mode=false
      SHOPIFY_THEME_ARGS+=("$arg")
    elif [[ "$only_mode" == true ]]; then
      SHOPIFY_THEME_ARGS+=("--only" "$arg")
    else
      SHOPIFY_THEME_ARGS+=("$arg")
    fi
  done
}

shopset() {
  if [[ -z "${1:-}" ]]; then
    echo "Uso: shopset <tienda> [theme-id]"
    echo "  <tienda>: mitienda o mitienda.myshopify.com"
    echo "  Sin theme-id selecciona solo la tienda (luego usa slist para elegir)."
    return 1
  fi

  local REPLY
  _shopify_normalize_store "$1" || return

  export SHOP_STORE="$REPLY"
  if [[ -n "${2:-}" ]]; then
    export SHOP_THEME="$2"
  else
    # Evita quedar apuntando a un theme de la tienda anterior.
    unset SHOP_THEME
  fi

  echo "✓ Shopify configurado:"
  echo "  Store: $SHOP_STORE"
  echo "  Theme: ${SHOP_THEME:-"(sin theme)"}"

  if [[ -z "${SHOP_THEME:-}" ]]; then
    echo
    echo "  Elige un theme: slist  →  shopset ${SHOP_STORE%.myshopify.com} <theme-id>"
  fi
}

shopget() {
  if [[ -z "${SHOP_STORE:-}" ]]; then
    echo "❌ No hay ninguna tienda configurada."
    return 1
  fi

  echo "Shopify:"
  echo "  Store: $SHOP_STORE"
  echo "  Theme: ${SHOP_THEME:-"(sin theme)"}"
}

slist() {
  _shopify_check_store || return
  shopify theme list -s "$SHOP_STORE" "$@"
}

spull() {
  _shopify_check || return
  _shopify_theme_args "$@"

  shopify theme pull \
    -s "$SHOP_STORE" \
    -t "$SHOP_THEME" \
    "${SHOPIFY_THEME_ARGS[@]}"
}

spush() {
  _shopify_check || return
  _shopify_theme_args "$@"

  shopify theme push \
    -s "$SHOP_STORE" \
    -t "$SHOP_THEME" \
    "${SHOPIFY_THEME_ARGS[@]}"
}

smeta() {
  _shopify_check_store || return

  shopify theme metafields pull \
    -s "$SHOP_STORE" \
    "$@"
}

sdev() {
  _shopify_check_store || return

  shopify theme dev \
    -s "$SHOP_STORE" \
    "$@"
}

sopen() {
  _shopify_check || return

  shopify theme open \
    -s "$SHOP_STORE" \
    -t "$SHOP_THEME" \
    "$@"
}

sdup() {
  _shopify_check || return

  if ! command -v node >/dev/null 2>&1; then
    echo "❌ Node.js es necesario para procesar la respuesta JSON de Shopify CLI."
    return 1
  fi

  local name=""
  local result new_id new_name
  local -a extra_args=()

  if [[ $# -gt 0 && "$1" != -* ]]; then
    name="$1"
    shift
  fi

  extra_args=("$@")

  if [[ -n "$name" ]]; then
    result=$(shopify theme duplicate \
      -s "$SHOP_STORE" \
      -t "$SHOP_THEME" \
      --name "$name" \
      --force \
      --json \
      "${extra_args[@]}") || {
        echo "❌ No se pudo duplicar el theme."
        [[ -n "$result" ]] && echo "$result"
        return 1
      }
  else
    result=$(shopify theme duplicate \
      -s "$SHOP_STORE" \
      -t "$SHOP_THEME" \
      --force \
      --json \
      "${extra_args[@]}") || {
        echo "❌ No se pudo duplicar el theme."
        [[ -n "$result" ]] && echo "$result"
        return 1
      }
  fi

  new_id=$(printf '%s' "$result" | node -e '
    let i = "";
    process.stdin.on("data", c => i += c);
    process.stdin.on("end", () => {
      try {
        const d = JSON.parse(i);
        if (d.theme?.id != null) {
          process.stdout.write(String(d.theme.id));
        }
      } catch (_) {}
    });
  ')

  new_name=$(printf '%s' "$result" | node -e '
    let i = "";
    process.stdin.on("data", c => i += c);
    process.stdin.on("end", () => {
      try {
        const d = JSON.parse(i);
        if (d.theme?.name != null) {
          process.stdout.write(String(d.theme.name));
        }
      } catch (_) {}
    });
  ')

  if [[ -z "$new_id" ]]; then
    echo "❌ Shopify CLI no devolvió un theme.id válido."
    echo "$result"
    return 1
  fi

  export SHOP_THEME="$new_id"

  echo "✓ Theme duplicado"
  echo "  Store: $SHOP_STORE"
  [[ -n "$new_name" ]] && echo "  Theme: $new_name"
  echo "  ID:    $SHOP_THEME"
  echo
  echo "✓ SHOP_THEME actualizado al nuevo theme."
}

srename() {
  _shopify_check || return

  if [[ -z "${1:-}" ]]; then
    echo 'Uso: srename "Nuevo nombre del theme"'
    return 1
  fi

  local name="$1"
  shift

  shopify theme rename \
    -s "$SHOP_STORE" \
    -t "$SHOP_THEME" \
    --name "$name" \
    "$@"
}

spublish() {
  _shopify_check || return

  echo "⚠️  Vas a publicar este theme:"
  echo "   Store: $SHOP_STORE"
  echo "   Theme: $SHOP_THEME"
  echo

  local reply
  read "reply?¿Continuar? [y/N] "

  if [[ "$reply" != "y" && "$reply" != "Y" ]]; then
    echo "Cancelado."
    return 1
  fi

  shopify theme publish \
    -s "$SHOP_STORE" \
    -t "$SHOP_THEME" \
    "$@"
}

scheck() {
  _shopify_check_cli || return
  shopify theme check "$@"
}

sinfo() {
  _shopify_check_cli || return
  shopify theme info "$@"
}

spackage() {
  _shopify_check_cli || return
  shopify theme package "$@"
}

shelp() {
  cat <<'EOF'
Mini Shopify Theme CLI

Contexto:
  shopset <store> [theme-id]   Selecciona tienda y theme para la sesión
                               <store>: mitienda o mitienda.myshopify.com
                               Sin theme-id: solo tienda (elige con slist)
  shopget                      Muestra el contexto actual

Trabajo diario:
  slist [args]                 Lista themes de SHOP_STORE
  spull [args]                 Pull de SHOP_THEME
  spush [args]                 Push a SHOP_THEME
  smeta [args]                 Pull de metafields de SHOP_STORE
  sdev [args]                  Ejecuta theme dev en SHOP_STORE
  sopen [args]                 Abre/previsualiza SHOP_THEME

Gestión:
  sdup ["nombre"] [args]       Duplica SHOP_THEME y cambia SHOP_THEME al nuevo ID
  srename "nombre" [args]      Renombra SHOP_THEME
  spublish [args]              Publica SHOP_THEME con confirmación

Local:
  scheck [args]                Ejecuta theme check
  sinfo [args]                 Ejecuta theme info
  spackage [args]              Empaqueta el theme

Atajo --only:
  spull --only layout/theme.liquid sections/header.liquid
EOF
}
