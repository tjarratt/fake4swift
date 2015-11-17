PROJECT_NAME = "XcodeBetterRefactorTools"
CONFIGURATION = "Release"
PLUGINS_DIR = "~/Library/Application\\ Support/Developer/Shared/Xcode/Plug-ins"

task :default => :install

def build_dir
  File.join(File.dirname(__FILE__), "build").tap do |path|
    Dir.mkdir(path) unless File.exists?(path)
  end
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
  system_or_exit <<-BASH, output_file("install")
    xcodebuild
      -project #{PROJECT_NAME}.xcodeproj
      -scheme #{PROJECT_NAME}
      -configuration #{CONFIGURATION}
      build install
  BASH
end

desc "Cut a new Release"
task :release => :install do
  system_or_exit <<-BASH, output_file("cut-release")
    rm -rf build/tmp-release/*
    mkdir -p build/tmp-release/artifacts &&
    ditto #{PLUGINS_DIR}/#{PROJECT_NAME}.xcplugin build/tmp-release/artifacts/#{PROJECT_NAME}.xcplugin &&
    pkgbuild --analyze
             --root build/tmp-release/artifacts
             --identifier com.tomato.better-refactor-tools
             --version 1.0
             --ownership recommended
             --install-location #{PLUGINS_DIR} build/tmp-release/better-refactor-tools.plist &&
    pkgbuild --root build/tmp-release/artifacts
             --component-plist build/tmp-release/better-refactor-tools.plist
             --install-location #{PLUGINS_DIR} build/tmp-release/better-refactor-tools.pkg &&
    echo "created release at build/tmp-release/better-refactor-tools.pkg"
  BASH
end

desc "Uninstall"
task :uninstall do
  system_or_exit "rm -rf #{PLUGINS_DIR}/#{PROJECT_NAME}.xcplugin"
end

desc "Clean"
task :clean do
  system_or_exit "rm -rf #{build_dir}/*", output_file("clean")
end
