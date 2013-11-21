# encoding: utf-8
# 通过rake -T查看任务，前提是需要有desc描述

#命令空间 Example
namespace :grab do

  #抓取网页（需传入参数：tag=>网站标识，type=>还未定义）
  desc '抓取网页'
  task :spider, [:mark,:type] do |t,args|
	require 'anemone'
	require './lib/anemone/core.rb'
	require './lib/anemone/page.rb'
	args.with_defaults(:mark => 'def', :type => 1)
	puts '======start======='
	web = Site.find_by(mark: args[:mark])

	if web.present?
	  puts '要抓取的网站存在...'
	  #初始化参数
	  i,m,n,o,p,q,r = 0,0,0,0,0,0,0
	  site_id = web.id
	  site_url = web.url
	  mark = web.mark
	  keyword = web.keyword
	  type = args[:type]
	  match_tags = web.match_tags
	  conf = web.conf || ''
	  #停顿时间
	  pause = web.sleep || 3

	  #抓取选项
	  opt = {
		discard_page_bodies: true,
		#threads: 4,
		obey_robots_txt: false,
		user_agent: "Web Share",
		crawl_subdomains: true,
		large_scale_crawl: true
		#read_timeout: 30,
		#depth_limit: 1000
		#delay: pause
	  }

	  Anemone.crawl(site_url, opt) do |d|
		if web.ignore_tags.present?
		  puts "need filter url tags: #{web.ignore_tags}"
		  d.skip_links_like /#{web.ignore_tags.gsub(',','|')}/ 
		end
		s = web.match_tags.gsub(',','|')
		if s.present?
		  key = /#{s}/
		  puts "rule url tags: #{key}"
		else
		  key = //
		end
		puts 'begin grab...'
		d.on_pages_like(key) do |page|
		  if page and page.url.present?
			  next if page.body == nil
			  page_url = page.url.to_s
			  puts "url: #{page_url}"
			  #抓取信息start
			  if page.doc
				doc = page.doc
				#是否是要抓的页面?
				if doc.css(keyword).present?
				  if WebPage.exist_url?(page_url)
				    i+=1
				    puts "link already exists! +#{i}"
				  else
				    m+=1
				    puts "new link: +#{m}"
				    #初始化参数
				    page_title = ''
				    page_cover_img = ''
				    page_desc = ''
				    page_tags = ''
				    page_content = ''
					page_images = ''


					#因为不同网站有不同规则,so从数据库动态读取配置
					if conf.present?
					  eval(conf)
					end

=begin
				  #标题
				  if doc.css("h1#PreHeaderContainer").present?
					page_title = doc.css("h1#PreHeaderContainer").first.content
				  end
				  #封面图url
				  if doc.css("div.SingleBigImage img").present?
					page_cover_img = doc.css("div.SingleBigImage img").first['src']
				  end
				  #描述
				  if doc.css("div.SingleArticleMainDescriptionNew").present?
					page_desc = doc.css("div.SingleArticleMainDescriptionNew").first.to_html
				  end
=end

					#抓取信息end
					# 保存到数据库
					hash = {
						site_id: site_id,
						url: page_url,
						mark: mark,
						kind: type,
						state: 3,
						title: page_title,
						description: page_desc,
						cover_img: page_cover_img,
						image_group: page_images,
						tags: page_tags,
						#content: page_content,
						category: match_tags
					}
					web_page = WebPage.new(hash)

					if web_page.save
					#if 1==1
					  q+=1
					  puts "grab_success! #{q}"
					else
					  r+=1
					  puts "save failed! #{r}"
					end

				  end # if WebPage.exist_url?
				else
				  p+=1
				  puts "invalid link: #{p}"
				end # if doc.css.present?
				
			end #if page.doc
			#停顿时间
			sleep pause

		  end #if page?
		end # if page loop
	  end # Anemone.crawl.each 

	end # if web.present?

  end

  #处理图片 （把抓取回来的图片及描述信息转换为本社区符合规格的格式,需传入参数：mark=>网站标识，type=>还未定义）
  desc "处理图片"
  task :handle_img, [:mark,:type] do |t,args|
	require 'nokogiri'	
	require 'faraday'
	#require 'open-uri'
	args.with_defaults(:mark => 'def', :type => 1)
	puts '======start======='

	site = Site.find_by(mark: args[:mark])
	if site.present?

		items = WebPage.where(site_id: site.id, state: 2)
		i=0
		items.each do |item|
		  if item.present? and item.description.present?
			doc = Nokogiri::HTML(item.description)
			if doc.present?

				i+=1
				puts 'aaaaaaaaaaa'
				doc.css('p').each do |d|
				  puts d.to_html
				end
				puts "num: #{i}"
			end
			options = {
				:title=>'',
				:imgs=>'',
				:desc=>''
			}


			#item.update_attributes(options)
		  end #if item.present?
		end#loop_end
	end#if web.present?
	puts "============end================="
  end


  ##下载图片保存到本地
  desc "down_img"
  task :down_img, [:tag,:type] do |t,args|
	args.with_defaults(:tag => 'def', :type => 1)
	require 'open-uri'
	require 'mini_magick'
	puts '======start======='
	items = WebRecord.where(:tab=>args[:tag],:state=>WebRecord::STATE[:no])

	items.each_with_index do |item,index|
		if item.present? and item.imgs.present?
			#response = Faraday.get(item.imgs)
			ext = item.imgs.split('.').last
			file_name = "#{Time.now.to_i.to_s}#{rand(10000)}.#{ext}"
			path = "/extend/images/sheji_new/#{file_name}"
			#File.new(path,'w')
			

			image_io= open(item.imgs)

			image_mini = MiniMagick::Image.read(image_io)
			#	image_mini.combine_options do |img|
			#		img.quality '100'
			#	end
			image_mini.write(path)
			#return false if index>2

		end
	end

  end

  ##测试
  desc 'test'
  task :test do
	require 'nokogiri'	
	require 'faraday'
	puts 'begin'
	#path = settings.root
	path = '/extend/bathroom.htm'
	html = open(path)
	doc = Nokogiri::HTML(html)
	doc.css('html').each do |item|
        m = /dsz\.contents\.push[^;]*/
		arr =  item.content.scan(m)
		if arr .present?
			arr.each do |a|
				url = a.split(',')
				if url.is_a?(Array) and url.size>3
					puts url[2]
				end
			end
		end

	end
		


	#puts doc.at_css('html').content.scan(m)
	#puts doc.css('script')[34].content


  end


  ##更新数据
  desc "update_data"
  task :update_data, [:tag,:type] do |t,args|

	puts '======start======='
	items = WebRecord.where(:tab=>args[:tag],:state=>WebRecord::STATE[:no])

	items.each_with_index do |item,index|
		if item.present?
			item.destroy	

		end
	end

  end


end

