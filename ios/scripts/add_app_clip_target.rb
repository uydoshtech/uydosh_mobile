#!/usr/bin/env ruby
# Adds (or regenerates) the UyDoshAppClip target in Runner.xcodeproj.
#
# The App Clip is a pure Swift/SwiftUI target — no Flutter, no CocoaPods —
# so it is managed by this script instead of hand-editing project.pbxproj.
# Safe to re-run: it removes the previous target/groups and re-adds them,
# picking up any new files under ios/Shared and ios/UyDoshAppClip.
#
# Usage:
#   ruby ios/scripts/add_app_clip_target.rb
#
# NOTE: The App Clip is intentionally NOT embedded into the Runner app yet.
# Embedding would require an App Clip provisioning profile in the TestFlight
# CI (release-testflight.yml). Embedding happens in Phase 5 — see
# docs/APP_CLIP.md.

require 'xcodeproj'

IOS_DIR = File.expand_path('..', __dir__)
PROJECT_PATH = File.join(IOS_DIR, 'Runner.xcodeproj')
TARGET_NAME = 'UyDoshAppClip'
BUNDLE_ID = 'com.uydosh.app.Clip'
DEPLOYMENT_TARGET = '17.0'
DEVELOPMENT_TEAM = 'D5THR62Q33'
APP_CLIP_PRODUCT_TYPE = 'com.apple.product-type.application.on-demand-install-capable'
TEST_INVOCATION_URL = 'https://scan.uydosh.uz/s/demo1234'

SOURCE_DIRS = %w[Shared UyDoshAppClip].freeze
RESOURCE_FILES = %w[
  UyDoshAppClip/Localizable.xcstrings
  UyDoshAppClip/InfoPlist.xcstrings
].freeze

project = Xcodeproj::Project.open(PROJECT_PATH)

# --- Remove a previously generated target/groups so the script is re-runnable.

if (existing = project.targets.find { |t| t.name == TARGET_NAME })
  puts "Removing existing target #{TARGET_NAME} for regeneration"
  product_ref = existing.product_reference
  existing.remove_from_project
  product_ref&.remove_from_project
end

SOURCE_DIRS.each do |dir|
  group = project.main_group.children.find { |c| c.display_name == dir }
  group&.remove_from_project
end

# --- Create the App Clip target.

target = project.new_target(:application, TARGET_NAME, :ios, DEPLOYMENT_TARGET)
target.product_type = APP_CLIP_PRODUCT_TYPE

# --- Groups and files (mirrors the on-disk layout under ios/).

def add_dir_recursively(parent_group, dir_abs, project, target)
  Dir.children(dir_abs).sort.each do |entry|
    next if entry.start_with?('.')
    path_abs = File.join(dir_abs, entry)
    if File.directory?(path_abs)
      group = parent_group.new_group(entry, entry)
      add_dir_recursively(group, path_abs, project, target)
    elsif entry.end_with?('.swift')
      file_ref = parent_group.new_reference(entry)
      target.source_build_phase.add_file_reference(file_ref)
    elsif entry.end_with?('.xcstrings')
      file_ref = parent_group.new_reference(entry)
      target.resources_build_phase.add_file_reference(file_ref)
    elsif entry.end_with?('.plist', '.entitlements')
      parent_group.new_reference(entry)
    end
  end
end

SOURCE_DIRS.each do |dir|
  group = project.main_group.new_group(dir, dir)
  add_dir_recursively(group, File.join(IOS_DIR, dir), project, target)
end

# --- Build settings.

target.build_configurations.each do |config|
  settings = config.build_settings
  settings['PRODUCT_BUNDLE_IDENTIFIER'] = BUNDLE_ID
  settings['PRODUCT_NAME'] = '$(TARGET_NAME)'
  settings['INFOPLIST_FILE'] = 'UyDoshAppClip/Info.plist'
  settings['GENERATE_INFOPLIST_FILE'] = 'NO'
  settings['CODE_SIGN_ENTITLEMENTS'] = 'UyDoshAppClip/UyDoshAppClip.entitlements'
  settings['CODE_SIGN_STYLE'] = 'Automatic'
  settings['DEVELOPMENT_TEAM'] = DEVELOPMENT_TEAM
  settings['IPHONEOS_DEPLOYMENT_TARGET'] = DEPLOYMENT_TARGET
  settings['SWIFT_VERSION'] = '5.0'
  settings['TARGETED_DEVICE_FAMILY'] = '1,2'
  # Version placeholders. At distribution time (Phase 5) these MUST match the
  # parent app's CFBundleShortVersionString / CFBundleVersion, which come from
  # pubspec.yaml via FLUTTER_BUILD_NAME / FLUTTER_BUILD_NUMBER.
  settings['MARKETING_VERSION'] = '1.0.0'
  settings['CURRENT_PROJECT_VERSION'] = '1'
  settings['LD_RUNPATH_SEARCH_PATHS'] = ['$(inherited)', '@executable_path/Frameworks']
  settings['ENABLE_PREVIEWS'] = 'YES'
  settings['SWIFT_EMIT_LOC_STRINGS'] = 'YES'
  settings['DEBUG_INFORMATION_FORMAT'] = config.name == 'Debug' ? 'dwarf' : 'dwarf-with-dsym'
  if config.name == 'Debug'
    settings['SWIFT_ACTIVE_COMPILATION_CONDITIONS'] = 'DEBUG $(inherited)'
    settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone'
  end
end

project.save
puts "Added target #{TARGET_NAME} to #{PROJECT_PATH}"

# --- Shared scheme with the test invocation URL and mock-backend variables.

scheme = Xcodeproj::XCScheme.new
scheme.add_build_target(target)
scheme.set_launch_target(target)

env = Xcodeproj::XCScheme::EnvironmentVariables.new
# _XCAppClipURL simulates the App Clip invocation URL when launched from Xcode.
env.assign_variable(key: '_XCAppClipURL', value: TEST_INVOCATION_URL, enabled: true)
# Mock backend scenario: valid | expired | invalid | error. Disable (or remove)
# to hit the live API.
env.assign_variable(key: 'SCAN_CLIP_MOCK', value: 'valid', enabled: true)
# The simulator has no LiDAR; force the device-support check to pass there.
env.assign_variable(key: 'SCAN_CLIP_FORCE_SUPPORTED', value: '1', enabled: true)
# Number of times the mocked upload should fail before succeeding — enable to
# exercise the upload-retry path. Only read when SCAN_CLIP_MOCK is active.
env.assign_variable(key: 'SCAN_CLIP_MOCK_UPLOAD_FAILURES', value: '1', enabled: false)
scheme.launch_action.environment_variables = env

scheme.save_as(PROJECT_PATH, TARGET_NAME, true)
puts "Saved shared scheme #{TARGET_NAME}"
