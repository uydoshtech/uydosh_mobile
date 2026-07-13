#!/usr/bin/env ruby
# Switches the UyDoshAppClip target to manual Distribution signing for CI.
#
# The clip target uses Automatic signing for local development, but the
# TestFlight workflow (release-testflight.yml) signs manually with
# pre-installed profiles. Runner's manual-signing overrides are appended to
# ios/Flutter/Release.xcconfig, which the clip does not include, so this
# script writes the equivalent settings directly into the project.
#
# Usage:
#   APPCLIP_PROFILE_NAME="UyDosh AppClip AppStore" bundle exec ruby ios/scripts/ci_appclip_signing.rb

require 'xcodeproj'

profile_name = ENV['APPCLIP_PROFILE_NAME']
abort 'APPCLIP_PROFILE_NAME env var is required' if profile_name.nil? || profile_name.strip.empty?

IOS_DIR = File.expand_path('..', __dir__)
PROJECT_PATH = File.join(IOS_DIR, 'Runner.xcodeproj')
TARGET_NAME = 'UyDoshAppClip'

project = Xcodeproj::Project.open(PROJECT_PATH)
target = project.targets.find { |t| t.name == TARGET_NAME }
abort "Target #{TARGET_NAME} not found in #{PROJECT_PATH}" unless target

target.build_configurations.each do |config|
  settings = config.build_settings
  settings['CODE_SIGN_STYLE'] = 'Manual'
  settings['CODE_SIGN_IDENTITY'] = 'Apple Distribution'
  settings['CODE_SIGN_IDENTITY[sdk=iphoneos*]'] = 'Apple Distribution'
  settings['PROVISIONING_PROFILE_SPECIFIER'] = profile_name
  settings['DEVELOPMENT_TEAM'] = ENV.fetch('DEVELOPMENT_TEAM', 'D5THR62Q33')
end

project.save
puts "Configured #{TARGET_NAME} for manual signing with profile: #{profile_name}"
