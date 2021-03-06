# encoding: utf-8
# 通过rake -T查看任务，前提是需要有desc描述

#命令空间 Example
namespace :grab do

  #抓取网页（需传入参数：tag=>网站标识，type=>还未定义）
  desc '抓取网页'
  task :spider, [ :mark, :type, :test ] do |t,args|
	require './lib/anemone/core.rb'
	require './lib/anemone/page.rb'
	args.with_defaults(:mark => 'def', :type => 1, :test => false)
	#是否测试
	is_test = args[:test]
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
	  #是否抓取子域名
	  is_sub_domain = web.is_subdomain?
	  #是否过滤url参数?(防止重复)
	  is_filter_param = web.is_filter_param?
      #要抓的地址(如果字段last_url不存在取字段url)
      if web.last_url.present?
        grab_url = web.last_url
      else
        grab_url = site_url
      end

	  #抓取选项
	  opt = {
		discard_page_bodies: true,
		#threads: 4,
		obey_robots_txt: false,
		user_agent: "Web Share",
		crawl_subdomains: is_sub_domain,
		large_scale_crawl: true
		#read_timeout: 30,
		#depth_limit: 1000
		#delay: pause
	  }

	  Anemone.crawl(URI.escape(grab_url), opt) do |d|
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
			  #是否过滤参数(如?page=2,防止重复)
			  if is_filter_param
				if page_url.include?('?')
				  page_url = page_url.split('?').first
				end
			  end
			  #防止重复抓取,去掉url后边的'/'
			  if page_url[-1]=='/'
				page_url = page_url[0,page_url.size-1]
			  end
			  puts "url: #{page_url}"

			  #抓取信息start
			  if page.doc
				page.doc.meta_encoding = 'utf-8'
				doc = page.doc
				#doc = Iconv.iconv("UTF-8","GB2312",doc)
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

					#如果是测试,则不存数据库
					if is_test
					  q+=1
					  puts "grab_success! #{q}"
					else
					  #如果遇到错误编码将停止抓取跳出错误,所以加上异常处理
					  begin
					    if web_page.save
					      q+=1
					      puts "grab_success! #{q}"
					    else
					      r+=1
					      puts "save failed! #{r}"
					    end
					  rescue
						puts "save error..."
					  end
					end #end is_test

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




  ##去除重复url
  desc "drop_repeat_url"
  task :drop_repeat_url, [:tag,:type] do |t,args|

	puts '======start======='
	items = WebRecord.where(:tab=>args[:tag],:state=>WebRecord::STATE[:no])

	items.each_with_index do |item,index|
		if item.present?
			item.destroy	

		end
	end

  end


end

