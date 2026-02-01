#!/usr/bin/env python3
"""
App Icon Setup Script for Flutter
Automatically copies and renames generated icons to the correct iOS and Android locations.
"""

import os
import shutil
import json

def setup_ios_icons():
    """Set up iOS app icons."""
    print("📱 Setting up iOS app icons...")
    
    # iOS icon mapping (generated_name -> iOS_name)
    ios_icon_mapping = {
        "AppStore.png": ["Icon-App-1024x1024@1x.png"],
        "iPhone_180.png": ["Icon-App-60x60@3x.png"],
        "iPhone_120.png": ["Icon-App-60x60@2x.png", "Icon-App-40x40@3x.png"],
        "iPhone_87.png": ["Icon-App-29x29@3x.png"],
        "iPhone_80.png": ["Icon-App-40x40@2x.png"],
        "iPhone_60.png": ["Icon-App-20x20@3x.png"],
        "iPhone_58.png": ["Icon-App-29x29@2x.png"],
        "iPhone_40.png": ["Icon-App-20x20@2x.png", "Icon-App-40x40@1x.png"],
        "iPhone_29.png": ["Icon-App-29x29@1x.png"],
        "iPhone_20.png": ["Icon-App-20x20@1x.png"],
        "iPad_167.png": ["Icon-App-83.5x83.5@2x.png"],
        "iPad_152.png": ["Icon-App-76x76@2x.png"],
        "iPad_76.png": ["Icon-App-76x76@1x.png"]
    }
    
    ios_source_dir = "generated_icons/ios"
    ios_target_dir = "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    
    if not os.path.exists(ios_source_dir):
        print(f"❌ iOS source directory not found: {ios_source_dir}")
        return False
    
    # Backup existing icons
    backup_dir = "ios/Runner/Assets.xcassets/AppIcon.appiconset/backup_old_icons"
    if not os.path.exists(backup_dir):
        os.makedirs(backup_dir)
    
    # Copy existing icons to backup
    for file in os.listdir(ios_target_dir):
        if file.endswith('.png') and file != 'Icon-App-1024x1024@1x.png':
            src = os.path.join(ios_target_dir, file)
            dst = os.path.join(backup_dir, file)
            shutil.copy2(src, dst)
            print(f"  📋 Backed up: {file}")
    
    # Copy and rename new icons
    for source_name, target_names in ios_icon_mapping.items():
        source_path = os.path.join(ios_source_dir, source_name)
        if not os.path.exists(source_path):
            print(f"  ❌ Source not found: {source_name}")
            continue

        for target_name in target_names:
            target_path = os.path.join(ios_target_dir, target_name)
            shutil.copy2(source_path, target_path)
            print(f"  ✅ {source_name} -> {target_name}")
    
    print("✅ iOS app icons setup completed!")
    return True

def setup_android_icons():
    """Set up Android app icons."""
    print("\n🤖 Setting up Android app icons...")
    
    # Android icon mapping (generated_name -> mipmap_location)
    android_icon_mapping = {
        "App_48.png": "android/app/src/main/res/mipmap-mdpi/ic_launcher.png",
        "App_72.png": "android/app/src/main/res/mipmap-hdpi/ic_launcher.png",
        "App_96.png": "android/app/src/main/res/mipmap-xhdpi/ic_launcher.png",
        "App_144.png": "android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png",
        "App_192.png": "android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png"
    }
    
    android_source_dir = "generated_icons/android"
    
    if not os.path.exists(android_source_dir):
        print(f"❌ Android source directory not found: {android_source_dir}")
        return False
    
    # Create mipmap directories if they don't exist
    mipmap_dirs = [
        "android/app/src/main/res/mipmap-mdpi",
        "android/app/src/main/res/mipmap-hdpi",
        "android/app/src/main/res/mipmap-xhdpi",
        "android/app/src/main/res/mipmap-xxhdpi",
        "android/app/src/main/res/mipmap-xxxhdpi"
    ]
    
    for mipmap_dir in mipmap_dirs:
        if not os.path.exists(mipmap_dir):
            os.makedirs(mipmap_dir)
    
    # Backup existing icons
    backup_dir = "android/app/src/main/res/backup_old_icons"
    if not os.path.exists(backup_dir):
        os.makedirs(backup_dir)
    
    # Copy existing icons to backup
    for mipmap_dir in mipmap_dirs:
        if os.path.exists(mipmap_dir):
            for file in os.listdir(mipmap_dir):
                if file.endswith('.png'):
                    src = os.path.join(mipmap_dir, file)
                    dst = os.path.join(backup_dir, f"{os.path.basename(mipmap_dir)}_{file}")
                    shutil.copy2(src, dst)
                    print(f"  📋 Backed up: {mipmap_dir}/{file}")
    
    # Copy and rename new icons
    for source_name, target_path in android_icon_mapping.items():
        source_path = os.path.join(android_source_dir, source_name)
        
        if os.path.exists(source_path):
            # Ensure target directory exists
            target_dir = os.path.dirname(target_path)
            if not os.path.exists(target_dir):
                os.makedirs(target_dir)
            
            shutil.copy2(source_path, target_path)
            print(f"  ✅ {source_name} -> {target_path}")
        else:
            print(f"  ❌ Source not found: {source_name}")
    
    # Copy Play Store icon
    play_store_src = os.path.join(android_source_dir, "PlayStore.png")
    play_store_dst = "android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_round.png"
    if os.path.exists(play_store_src):
        shutil.copy2(play_store_src, play_store_dst)
        print(f"  ✅ PlayStore.png -> ic_launcher_round.png")
    
    print("✅ Android app icons setup completed!")
    return True

def main():
    """Main function to set up app icons."""
    print("🎨 Flutter App Icon Setup")
    print("=" * 50)
    
    # Check if generated icons exist
    if not os.path.exists("generated_icons"):
        print("❌ Generated icons directory not found!")
        print("Please run 'python3 generate_icons.py assets/icon/logo_image.png' first")
        return
    
    # Set up iOS icons
    ios_success = setup_ios_icons()
    
    # Set up Android icons
    android_success = setup_android_icons()
    
    print("\n🎉 App icon setup completed!")
    print("\n📋 Next steps:")
    print("1. Clean and rebuild your project: 'flutter clean && flutter pub get'")
    print("2. Test the app on both iOS and Android to see the new icons")
    
    if ios_success and android_success:
        print("\n✅ All platforms configured successfully!")
    else:
        print("\n⚠️  Some platforms had issues. Check the output above.")

if __name__ == "__main__":
    main()
