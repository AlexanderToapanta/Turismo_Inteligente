#!/usr/bin/env python3
"""
Script para generar iconos de la app para Android e iOS desde una imagen fuente.
"""
from PIL import Image
import os
import shutil

SOURCE_IMAGE = "assets/icon/app_icon.png"

# Tamaños para Android mipmap
ANDROID_SIZES = {
    "mipmap-mdpi":    48,
    "mipmap-hdpi":    72,
    "mipmap-xhdpi":   96,
    "mipmap-xxhdpi":  144,
    "mipmap-xxxhdpi": 192,
}

# Tamaños para iOS (nombre_archivo: tamaño_px)
IOS_SIZES = {
    "Icon-App-20x20@1x.png":      20,
    "Icon-App-20x20@2x.png":      40,
    "Icon-App-20x20@3x.png":      60,
    "Icon-App-29x29@1x.png":      29,
    "Icon-App-29x29@2x.png":      58,
    "Icon-App-29x29@3x.png":      87,
    "Icon-App-40x40@1x.png":      40,
    "Icon-App-40x40@2x.png":      80,
    "Icon-App-40x40@3x.png":      120,
    "Icon-App-60x60@2x.png":      120,
    "Icon-App-60x60@3x.png":      180,
    "Icon-App-76x76@1x.png":      76,
    "Icon-App-76x76@2x.png":      152,
    "Icon-App-83.5x83.5@2x.png":  167,
    "Icon-App-1024x1024@1x.png":  1024,
}

def generate_icon(src_image, size, dest_path):
    """Redimensiona la imagen al tamaño indicado y guarda en dest_path."""
    img = src_image.copy()
    img = img.resize((size, size), Image.LANCZOS)
    img.save(dest_path, "PNG")
    print(f"  ✓ {dest_path} ({size}x{size})")

def main():
    if not os.path.exists(SOURCE_IMAGE):
        print(f"ERROR: No se encontró la imagen fuente: {SOURCE_IMAGE}")
        return

    print(f"Cargando imagen fuente: {SOURCE_IMAGE}")
    src = Image.open(SOURCE_IMAGE).convert("RGBA")
    print(f"Tamaño original: {src.size}")

    # Generar iconos Android
    print("\n--- Generando iconos Android ---")
    android_res = "android/app/src/main/res"
    for folder, size in ANDROID_SIZES.items():
        dest_dir = os.path.join(android_res, folder)
        os.makedirs(dest_dir, exist_ok=True)
        dest_path = os.path.join(dest_dir, "ic_launcher.png")
        generate_icon(src, size, dest_path)

    # Generar iconos iOS
    print("\n--- Generando iconos iOS ---")
    ios_dir = "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    os.makedirs(ios_dir, exist_ok=True)
    for filename, size in IOS_SIZES.items():
        dest_path = os.path.join(ios_dir, filename)
        generate_icon(src, size, dest_path)

    print("\n✅ ¡Todos los iconos generados exitosamente!")

if __name__ == "__main__":
    main()
