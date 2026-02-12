#!/usr/bin/env ruby
# frozen_string_literal: true
# encoding: UTF-8

ENV['LANG'] = 'en_US.UTF-8'
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require 'xcodeproj'
require 'fileutils'

project_path = 'BreakReminder.xcodeproj'
FileUtils.rm_rf(project_path)
project = Xcodeproj::Project.new(project_path)

project.build_configurations.each do |config|
  config.build_settings['SWIFT_VERSION'] = '5.8'
  config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '13.0'
  config.build_settings['CLANG_ENABLE_MODULES'] = 'YES'
end

app_target = project.new_target(:application, 'BreakReminder', :osx, '13.0')
test_target = project.new_target(:unit_test_bundle, 'BreakReminderTests', :osx, '13.0')
test_target.add_dependency(app_target)

[app_target, test_target].each do |target|
  target.build_configurations.each do |config|
    config.build_settings['SWIFT_VERSION'] = '5.8'
    config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '13.0'
    config.build_settings['CLANG_ENABLE_MODULES'] = 'YES'
    config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
    config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
  end
end

app_target.build_configurations.each do |config|
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.example.breakreminder'
  config.build_settings['GENERATE_INFOPLIST_FILE'] = 'YES'
  config.build_settings['INFOPLIST_KEY_CFBundleDisplayName'] = 'BreakReminder'
  config.build_settings['INFOPLIST_KEY_LSApplicationCategoryType'] = 'public.app-category.productivity'
  config.build_settings['INFOPLIST_KEY_SUFeedURL'] = 'https://<your-user>.github.io/break-reminder-macos/appcast.xml'
  config.build_settings['INFOPLIST_KEY_SUPublicEDKey'] = 'REPLACE_WITH_SPARKLE_PUBLIC_KEY'
  config.build_settings['PRODUCT_NAME'] = 'BreakReminder'
  config.build_settings['ENABLE_HARDENED_RUNTIME'] = 'NO'
end

test_target.build_configurations.each do |config|
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.example.breakreminder.tests'
  config.build_settings['GENERATE_INFOPLIST_FILE'] = 'YES'
  config.build_settings['PRODUCT_NAME'] = 'BreakReminderTests'
end

main_group = project.main_group
app_group = main_group.new_group('BreakReminderApp', 'BreakReminderApp')
menu_group = app_group.new_group('MenuBar', 'MenuBar')
timer_group = app_group.new_group('Timer', 'Timer')
notifications_group = app_group.new_group('Notifications', 'Notifications')
overlay_group = app_group.new_group('Overlay', 'Overlay')
audio_group = app_group.new_group('Audio', 'Audio')
settings_group = app_group.new_group('Settings', 'Settings')
updates_group = app_group.new_group('Updates', 'Updates')
resources_group = app_group.new_group('Resources', 'Resources')

app_sources = {
  app_group => ['AppEntry.swift'],
  menu_group => ['MenuBarController.swift'],
  timer_group => ['ReminderTypes.swift', 'ReminderStateMachine.swift', 'ReminderEngine.swift'],
  notifications_group => ['NotificationService.swift'],
  overlay_group => ['BreakOverlayPanelController.swift'],
  audio_group => ['SoundPlayer.swift'],
  settings_group => ['SettingsStore.swift', 'SettingsView.swift'],
  updates_group => ['UpdaterController.swift', 'UpdateVersionComparator.swift']
}

app_sources.each do |group, files|
  files.each do |file|
    file_ref = group.new_file(file)
    app_target.source_build_phase.add_file_reference(file_ref)
  end
end

sound_group = resources_group.new_group('Sounds', 'Sounds')
localizable_group = resources_group.new_group('Localizable', 'Localizable')

sound_ref = sound_group.new_file('reminder.aiff')
localizable_ref = localizable_group.new_file('zh-Hans.strings')
app_target.resources_build_phase.add_file_reference(sound_ref)
app_target.resources_build_phase.add_file_reference(localizable_ref)

tests_group = main_group.new_group('BreakReminderAppTests', 'BreakReminderAppTests')
%w[
  StateMachineTests.swift
  ReminderEngineTests.swift
  SettingsStoreTests.swift
  UpdateVersionComparatorTests.swift
].each do |test_file|
  file_ref = tests_group.new_file(test_file)
  test_target.source_build_phase.add_file_reference(file_ref)
end

frameworks = {
  'Cocoa.framework' => app_target,
  'UserNotifications.framework' => app_target,
  'XCTest.framework' => test_target
}

frameworks.each do |name, target|
  ref = project.frameworks_group.new_file("System/Library/Frameworks/#{name}")
  target.frameworks_build_phase.add_file_reference(ref)
end

project.save
puts "Generated #{project_path}"
