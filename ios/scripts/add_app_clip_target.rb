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
# The App Clip is embedded into the Runner app ("Embed App Clips" copy-files
# phase + target dependency), so `flutter build ipa` produces an IPA that
# contains it. Distribution therefore needs an App Clip provisioning profile
# in the TestFlight CI — see docs/APP_CLIP.md and
# ios/scripts/ci_appclip_signing.rb.

require 'xcodeproj'

IOS_DIR = File.expand_path('..', __dir__)
PROJECT_PATH = File.join(IOS_DIR, 'Runner.xcodeproj')
TARGET_NAME = 'UyDoshAppClip'
BUNDLE_ID = 'com.uydosh.app.Clip'
DEPLOYMENT_TARGET = '17.0'
DEVELOPMENT_TEAM = 'D5THR62Q33'
APP_CLIP_PRODUCT_TYPE = 'com.apple.product-type.application.on-demand-install-capable'
TEST_INVOCATION_URL = 'https://scan.uydosh.com/s/demo1234'

SOURCE_DIRS = %w[Shared UyDoshAppClip].freeze
RESOURCE_FILES = %w[
  UyDoshAppClip/Localizable.xcstrings
  UyDoshAppClip/InfoPlist.xcstrings
].freeze

project = Xcodeproj::Project.open(PROJECT_PATH)
runner_target = project.targets.find { |t| t.name == 'Runner' }
raise 'Runner target not found' unless runner_target

# --- Remove a previously generated target/groups so the script is re-runnable.

# Runner's embed phase and dependency reference the old target/product;
# drop them first so they can be recreated against the fresh target.
runner_target.copy_files_build_phases
  .select { |phase| phase.name == 'Embed App Clips' }
  .each(&:remove_from_project)
runner_target.dependencies
  .select { |dep| dep.target.nil? || dep.target.name == TARGET_NAME }
  .each(&:remove_from_project)

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
    if File.directory?(path_abs) && entry.end_with?('.xcassets')
      # Asset catalogs are opaque folder references compiled as resources.
      file_ref = parent_group.new_reference(entry)
      target.resources_build_phase.add_file_reference(file_ref)
    elsif File.directory?(path_abs)
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

# Flutter's Generated.xcconfig provides FLUTTER_BUILD_NAME / FLUTTER_BUILD_NUMBER
# (from pubspec.yaml or --build-name/--build-number), keeping the clip's
# version in lockstep with the parent app — an App Store requirement.
generated_xcconfig = project.files.find { |f| f.path == 'Flutter/Generated.xcconfig' }

target.build_configurations.each do |config|
  config.base_configuration_reference = generated_xcconfig if generated_xcconfig
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
  # Must match the parent app's CFBundleShortVersionString / CFBundleVersion;
  # both come from Generated.xcconfig (see base_configuration_reference above).
  settings['MARKETING_VERSION'] = '$(FLUTTER_BUILD_NAME)'
  settings['CURRENT_PROJECT_VERSION'] = '$(FLUTTER_BUILD_NUMBER)'
  settings['ASSETCATALOG_COMPILER_APPICON_NAME'] = 'AppIcon'
  # Embedded clip: without SKIP_INSTALL the archive would contain two
  # top-level apps and export as a generic Xcode archive.
  settings['SKIP_INSTALL'] = 'YES'
  settings['LD_RUNPATH_SEARCH_PATHS'] = ['$(inherited)', '@executable_path/Frameworks']
  settings['ENABLE_PREVIEWS'] = 'YES'
  settings['SWIFT_EMIT_LOC_STRINGS'] = 'YES'
  settings['DEBUG_INFORMATION_FORMAT'] = config.name == 'Debug' ? 'dwarf' : 'dwarf-with-dsym'
  if config.name == 'Debug'
    settings['SWIFT_ACTIVE_COMPILATION_CONDITIONS'] = 'DEBUG $(inherited)'
    settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone'
  end
end

# --- Embed into Runner ("Embed App Clips" copy-files phase + dependency).

runner_target.add_dependency(target)

embed_phase = runner_target.new_copy_files_build_phase('Embed App Clips')
embed_phase.symbol_dst_subfolder_spec = :products_directory
embed_phase.dst_path = '$(CONTENTS_FOLDER_PATH)/AppClips'
build_file = embed_phase.add_file_reference(target.product_reference)
build_file.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }

# new_copy_files_build_phase appends the phase last — after script phases
# like "Thin Binary" and "[CP] Embed Pods Frameworks", which creates a build
# dependency cycle. Move it up next to "Embed Frameworks", matching Xcode's
# own placement.
phases = runner_target.build_phases
phases.delete(embed_phase)
anchor = phases.find { |p| p.display_name == 'Embed Frameworks' } ||
         phases.find { |p| p.is_a?(Xcodeproj::Project::Object::PBXResourcesBuildPhase) }
phases.insert(phases.index(anchor) + 1, embed_phase)

project.save
puts "Added target #{TARGET_NAME} to #{PROJECT_PATH} (embedded in Runner)"

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
