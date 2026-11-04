# Workflows

## Trabajo normal

```bash
shopset mitienda 123456789
shopget
spull
sdev
```

## Elegir theme

```bash
shopset mitienda
slist
shopset mitienda 123456789
```

## Cambio de pocos archivos

```bash
spull --only \
  sections/header.liquid \
  assets/theme.css

scheck

spush --only \
  sections/header.liquid \
  assets/theme.css
```

## Cambio estructural sobre un duplicado

```bash
shopset mitienda 123456789
shopget
sdup "IP 4321 | Nueva funcionalidad"
shopget
spull
```

A partir de `sdup`, `SHOP_THEME` apunta al duplicado.

## Metafields

```bash
smeta
```

## Publicar

```bash
shopget
spublish
```

## Desde un agente

Cada comando del agente suele correr en un shell nuevo, así que el contexto va en el mismo comando:

```bash
shopset mitienda 123456789 && spull --only sections/header.liquid
```

## Modificar el CLI

```bash
./install.sh --link
source ~/.zshrc
# editar src/mini-shopify-theme-cli.zsh
source ~/.zshrc
zsh tests/smoke.zsh
```
