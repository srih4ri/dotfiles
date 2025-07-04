#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'

dot_files_map = {
  'config/fish/config.fish' => '~/.config/fish/config.fish',

  'config/ruby/irbrc' => '~/.irbrc',

  'config/git/gitconfig' => '~/.gitconfig',

  'config/emacs/doom/custom.el' => '~/.config/doom/custom.el',
  'config/emacs/doom/config.el' => '~/.config/doom/config.el',
  'config/emacs/doom/init.el' => '~/.config/doom/init.el',
  'config/emacs/doom/packages.el' => '~/.config/doom/packages.el',

  'config/tmux/tmux.conf' => '~/.tmux.conf'
}

def create_folder_and_copy(source, dest)
  FileUtils.mkdir_p(File.expand_path(File.dirname(dest)))
  puts `cp -v #{source} #{dest}`
end

case ARGV[0]
when 'install'
  puts 'Installing files from this folder'
  dot_files_map.each do |source, dest|
    create_folder_and_copy(source, dest)
  end
when 'update'
  puts 'Updating this folder'
  dot_files_map.each do |dest, source|
    create_folder_and_copy(source, dest)
  end
when 'diff'
  dot_files_map.each do |source, dest|
    `diff #{source} #{dest}`
  end
end
