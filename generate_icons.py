#!/usr/bin/env python3
"""
Icon Generator Script for iOS and Android
Generates all required icon sizes from a source logo image.
"""

import os
from PIL import Image, ImageDraw
import argparse

def create_icon_sizes(source_image_path, output_dir="generated_icons"):
    """
    Generate all required icon sizes for iOS and Android from a source image.
    
    Args:
        source_image_path (str): Path to the source logo image
        output_dir (str): Directory to save generated icons
    """
    
    # Create output directory if it doesn't exist
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    # Create platform-specific subdirectories
    ios_dir = os.path.join(output_dir, "ios")
    android_dir = os.path.join(output_dir, "android")
    
    for dir_path in [ios_dir, android_dir]:
        if not os.path.exists(dir_path):
            os.makedirs(dir_path)
    
    try:
        # Open the source image
        with Image.open(source_image_path) as source_img:
            print(f"Source image loaded: {source_img.size[0]}x{source_img.size[1]} pixels")
            
            # Ensure the image is in RGBA mode (supports transparency)
            if source_img.mode != 'RGBA':
                source_img = source_img.convert('RGBA')
            
            # iOS Icon Sizes
            ios_sizes = {
                "AppStore": 1024,
                "iPhone_180": 180,
                "iPhone_120": 120,
                "iPhone_87": 87,
                "iPhone_58": 58,
                "iPhone_80": 80,
                "iPhone_60": 60,
                "iPhone_40": 40,
                "iPhone_29": 29,
                "iPhone_20": 20,
                "iPad_167": 167,
                "iPad_152": 152,
                "iPad_76": 76
            }
            
            # Android Icon Sizes
            android_sizes = {
                "PlayStore": 512,
                "App_192": 192,
                "App_144": 144,
                "App_96": 96,
                "App_72": 72,
                "App_48": 48,
                "Adaptive_108": 108
            }
            
            print("\nGenerating iOS icons...")
            for name, size in ios_sizes.items():
                icon_path = os.path.join(ios_dir, f"{name}.png")
                generate_icon(source_img, size, icon_path, name)
            
            print("\nGenerating Android icons...")
            for name, size in android_sizes.items():
                icon_path = os.path.join(android_dir, f"{name}.png")
                generate_icon(source_img, size, icon_path, name)
            
            # Generate Android adaptive icon components
            print("\nGenerating Android adaptive icon components...")
            generate_android_adaptive_icons(source_img, android_dir)
            
            print(f"\n✅ All icons generated successfully in '{output_dir}' directory!")
            print(f"📱 iOS icons: {ios_dir}")
            print(f"🤖 Android icons: {android_dir}")
            
    except Exception as e:
        print(f"❌ Error generating icons: {e}")
        return False
    
    return True

def generate_icon(source_img, size, output_path, name):
    """
    Generate a single icon at the specified size.
    
    Args:
        source_img (PIL.Image): Source image
        size (int): Target size in pixels
        output_path (str): Output file path
        name (str): Icon name for logging
    """
    try:
        # Resize the image using high-quality resampling
        resized_img = source_img.resize((size, size), Image.Resampling.LANCZOS)
        
        # Save the icon
        resized_img.save(output_path, "PNG", optimize=True)
        print(f"  ✅ {name}: {size}x{size} px -> {output_path}")
        
    except Exception as e:
        print(f"  ❌ {name}: Error generating {size}x{size} px - {e}")

def generate_android_adaptive_icons(source_img, android_dir):
    """
    Generate Android adaptive icon components (foreground and background).
    
    Args:
        source_img (PIL.Image): Source image
        android_dir (str): Android icons directory
    """
    try:
        # Create a 108x108 background (solid purple color from your logo)
        # Extract the purple color from the source image
        purple_color = extract_dominant_color(source_img)
        
        # Create background
        background = Image.new('RGBA', (108, 108), purple_color)
        background_path = os.path.join(android_dir, "adaptive_background.png")
        background.save(background_path, "PNG", optimize=True)
        
        # Create foreground (the logo on transparent background)
        # Resize source to fit in 72x72 safe area (108 * 0.67)
        foreground_size = int(108 * 0.67)
        foreground = source_img.resize((foreground_size, foreground_size), Image.Resampling.LANCZOS)
        
        # Create a 108x108 transparent canvas
        foreground_canvas = Image.new('RGBA', (108, 108), (0, 0, 0, 0))
        
        # Center the foreground image
        x_offset = (108 - foreground_size) // 2
        y_offset = (108 - foreground_size) // 2
        foreground_canvas.paste(foreground, (x_offset, y_offset), foreground)
        
        foreground_path = os.path.join(android_dir, "adaptive_foreground.png")
        foreground_canvas.save(foreground_path, "PNG", optimize=True)
        
        print(f"  ✅ Android Adaptive Icons: 108x108 px -> {android_dir}")
        
    except Exception as e:
        print(f"  ❌ Android Adaptive Icons: Error generating - {e}")

def extract_dominant_color(image):
    """
    Extract the dominant color from the image (purple background).
    
    Args:
        image (PIL.Image): Source image
    
    Returns:
        tuple: RGBA color tuple
    """
    # Convert to RGB for color analysis
    rgb_img = image.convert('RGB')
    
    # Get the color at the center of the image (should be purple background)
    center_x, center_y = rgb_img.size[0] // 2, rgb_img.size[1] // 2
    purple_color = rgb_img.getpixel((center_x, center_y))
    
    # Convert to RGBA
    return purple_color + (255,)

def main():
    """Main function to run the icon generator."""
    parser = argparse.ArgumentParser(description="Generate iOS and Android app icons")
    parser.add_argument("source_image", help="Path to the source logo image")
    parser.add_argument("--output", "-o", default="generated_icons", 
                       help="Output directory for generated icons (default: generated_icons)")
    
    args = parser.parse_args()
    
    if not os.path.exists(args.source_image):
        print(f"❌ Source image not found: {args.source_image}")
        return
    
    print("🎨 Icon Generator for iOS and Android")
    print("=" * 50)
    
    success = create_icon_sizes(args.source_image, args.output)
    
    if success:
        print("\n🎉 Icon generation completed successfully!")
        print("\n📋 Next steps:")
        print("1. Copy iOS icons to your iOS project's Assets.xcassets/AppIcon.appiconset/")
        print("2. Copy Android icons to your Android project's res/mipmap-* directories")
        print("3. Update your Flutter project's pubspec.yaml with the new icon paths")
    else:
        print("\n❌ Icon generation failed. Please check the error messages above.")

if __name__ == "__main__":
    main()
