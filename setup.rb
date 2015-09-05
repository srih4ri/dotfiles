#!/usr/bin/env ruby
require 'fileutils'

dot_files_map = {
  'config.fish' => '~/.config/fish/config.fish',
  '.spacemacs' => '~/.spacemacs',
  'scripts/deploy.sh' => '~/scripts/deploy.sh',
  '.irbrc' => '~/.irbrc',
  'rc.xml' => '~/.config/openbox/rc.xml',
  '.gitconfig' => '~/.gitconfig'
}

def create_folder_and_copy(source,dest)
  FileUtils.mkdir_p(File.expand_path(File.dirname(dest)))
  puts `cp -rv #{source} #{dest}`
end

case ARGV[0]
when 'install'
  puts 'Installing files from this folder'
  dot_files_map.each do |source, dest|
    create_folder_and_copy(source,dest)
  end
when 'update'
  puts 'Updating this folder'
  dot_files_map.each do |dest, source|
    create_folder_and_copy(source,dest)
  end
end
