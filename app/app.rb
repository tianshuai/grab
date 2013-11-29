# encoding: utf-8
require "bundler"
Bundler.require

#setting
set :config_dir, settings.root + '/../config'
set :views, settings.root + '/views'

#init
require settings.root + '/init'
