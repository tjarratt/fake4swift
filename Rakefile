PROJECT_NAME = "XcodeBetterRefactorTools"
PLUGIN_NAME = "XcodeBetterRefactorTools"
CONFIGURATION = "Release"
PLUGINS_DIR = "~/Library/Application\\ Support/Developer/Shared/Xcode/Plug-ins"
PLUGIN_INSTALL_DIR = "/Library/Application\\ Support/BetterRefactorTools"

task :default => :install

def build_dir
  File.join(File.dirname(__FILE__), "build").tap do |path|
    Dir.mkdir(path) unless File.exists?(path)
  end
end

def scripts_dir
  File.join(File.dirname(__FILE__), "installers", "scripts")
end

def release_dir
  File.join(File.dirname(__FILE__), "build", "tmp-release", "artifacts")
end

def output_file(target)
  File.join(build_dir, "#{target}.output")
end

def system_or_exit(cmd, stdout = nil)
  cmd.gsub!("\n", "")
  cmd += " > #{stdout}" if stdout
  puts "Executing #{cmd}"
  system(cmd) or raise "******** Build failed ********"
end

desc "Build & install"
task :install => :clean do
  system_or_exit <<-BASH, output_file("install-plugin")
    xcodebuild
      -project #{PROJECT_NAME}.xcodeproj
      -scheme #{PLUGIN_NAME}
      -configuration #{CONFIGURATION}
      build install
  BASH

  system_or_exit <<-BASH, output_file("install-cli")
    xcodebuild
      -project #{PROJECT_NAME}.xcodeproj
      -scheme fake4swift
      -configuration #{CONFIGURATION}
      build install
  BASH
end

desc "Cut a new Release"
task :release => :install do

  # plugin
  system_or_exit <<-BASH, output_file("cut-plugin-release")
    mkdir -p #{release_dir} &&
    mkdir -p build/tmp-release/scripts && 
    cp #{scripts_dir}/postinstall build/tmp-release/scripts &&
    ditto #{PLUGINS_DIR}/#{PLUGIN_NAME}.xcplugin #{release_dir}/#{PLUGIN_INSTALL_DIR}/#{PROJECT_NAME}.xcplugin &&
    ditto /usr/local/bin/fake4swift #{release_dir}/usr/local/bin/fake4swift &&
    ditto /usr/local/bin/BetterRefactorToolsKit.framework #{release_dir}/usr/local/bin/BetterRefactorToolsKit.framework && 
    ditto /usr/local/bin/Blindside.framework #{release_dir}/usr/local/bin/Blindside.framework && 
    ditto /usr/local/bin/Mustache.framework #{release_dir}/usr/local/bin/Mustache.framework && 
    ditto /usr/local/bin/SourceKittenFramework.framework #{release_dir}/usr/local/bin/SourceKittenFramework.framework && 
    ditto /usr/local/bin/SwiftXPC.framework #{release_dir}/usr/local/bin/SwiftXPC.framework &&
    pkgbuild --analyze
             --root #{release_dir}
             --identifier com.tomato.better-refactor-tools
             --version 1.0
             --ownership recommended
	     --scripts build/tmp-release/scripts
             --install-location / build/tmp-release/better-refactor-tools.plist &&
    pkgbuild --root #{release_dir}
             --identifier com.tomato.better-refactor-tools
             --scripts build/tmp-release/scripts
             --component-plist build/tmp-release/better-refactor-tools.plist
             --install-location / build/tmp-release/better-refactor-tools.pkg &&
    echo "created release at build/tmp-release/better-refactor-tools.pkg"
  BASH
end

desc "Uninstall"
task :uninstall do
  system_or_exit "rm -rf #{PLUGINS_DIR}/#{PLUGIN_NAME}.xcplugin"
  system_or_exit "rm -rf /usr/local/bin/fake4swift /usr/local/bin/BetterRefactorToolsKit.framework"

  ["Blindside", "BetterRefactorToolsKit", "Mustache", "SourceKittenFramework", "SwiftXPC"].each do |dependency|
    system_or_exit "rm -rf /usr/local/bin/#{dependency}.framework"
  end
end

desc "Clean"
task :clean do
  system_or_exit "rm -rf #{build_dir}/*", output_file("clean")
end
