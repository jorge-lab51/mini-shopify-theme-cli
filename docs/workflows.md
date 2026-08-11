# Workflows

## Trabajo normal

```bash
shopset store.myshopify.com 123456789
shopget
spull
sdev
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
shopset store.myshopify.com 123456789
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
