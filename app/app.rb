# encoding: utf-8
require 'sinatra'
require 'will_paginate'
require 'will_paginate/active_record'
#setting
set :config_dir, settings.root + '/../config'
set :views, settings.root + '/views'

#init
require settings.root + '/init'



