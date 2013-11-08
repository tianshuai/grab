# encoding: utf-8
# 通过rake -T查看任务，前提是需要有desc描述

#命令空间 Example
namespace :grab do

  #测试
  desc 'add_db-------test'
  task :web_info_add do
	puts '=====start====='
	(1..10).each do |a|
		WebInfo.create({tab: "a#{a}",title: "test#{a}",url: "www.#{a}.com"})
	end
	puts WebInfo.all.size
  end

  #抓取网页（需传入参数：tag=>网站标识，type=>还未定义）
  desc '抓取网页'
  task :spider, [:mark,:type] do |t,args|
	require 'anemone'
	require 'digest/md5'
	args.with_defaults(:mark => 'def', :type => 1)
	puts '======start======='
	web = Site.find_by(mark: args[:mark])

	if web.present?
	  puts '要抓取的网站存在...'
	  #初始化参数
	  i,m,n,o,p,q=0,0,0,0,0,0
	  site_id = web.id
	  mark = web.mark
	  keyword = web.keyword
	  type = args[:type]
	  match_tags = web.match_tags
	  conf = web.conf || ''
	  pause = web.sleep || 3
	  

	  Anemone.crawl(web.url) do |d|
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
			page_url = page.url.to_s
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
			  state = 0
			  #抓取信息start
			  if page.doc
				#start--------------------------
				doc = page.doc
				#是否是要抓的页面?
				if doc.css(keyword).present?
				  state = 2

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

				else
				  p+=1
				  puts "invalid link: #{p}"
				  state = 1
				end # if doc.css.present?

			  end #if page.doc
			  
			  #抓取信息end
			  # 保存到数据库
			  hash = {
				site_id: site_id,
				url: page_url,
				mark: mark,
				kind: type,
				state: state,
				title: page_title,
				description: page_desc,
				cover_img: page_cover_img,
				tags: page_tags,
				content: page_content,
				category: match_tags
			  }
			  #web_page = WebPage.new(hash)

			  #if web_page.save
			#	q+=1
			#	puts "grab_success! #{q}"
			 # end
			  #end----------------------
			end # if WebPage.exist_url?
			#一秒的停顿时间
			sleep pause

		  end #if page?
		end # if page loop
	  end # Anemone.crawl.each 

	end # if web.present?

  end

  #分析页面 （需传入参数：tag=>网站标识，type=>还未定义）
  desc "fetch_info"
  task :fetch_info, [:tag,:type] do |t,args|
	require 'nokogiri'	
	require 'faraday'
	#require 'open-uri'
	args.with_defaults(:tag => 'def', :type => 1)
	puts '======start======='

	web = WebInfo.where(:tab=>args[:tag])
	if web.present?
		web = web.first
		title_f = web.config['title']
		desc_f = web.config['desc']
		img_f = web.config['img']

		items = WebRecord.where(:tab=>args[:tag],:state=>WebRecord::STATE[:no])
		if items.present?
			i=0
			items.each do |item|
				response = Faraday.get(item.url)

				case response.status
				when 200
				  html = response.body
				  puts '200'
				when 301..302
					puts '302'
				  html = Faraday.get(response[:location]).body
				end

				doc = Nokogiri::HTML(html)
				if doc.present?
					title = doc.css(title_f)
					if title.present?
						title = title.first.content
					else
						title = ''
					end
					imgs = []
					doc.css(img_f).each do |img|
						imgs << img if img.present?
					end

					desc = doc.css(desc_f)
					if desc.present?
						desc = desc.first.content 
					else
						desc = ''
					end
					i+=1
					#puts doc
					puts "num: #{i}"
				end
				options = {
					:title=>title,
					:imgs=>imgs,
					:desc=>desc
				}
				puts "url: #{item.url}"
				puts "title: #{options[:title]}"
				puts "img: #{options[:imgs]}" 

				item.update_attributes(options)
					
			end#loop_end
		end#if items_end
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

