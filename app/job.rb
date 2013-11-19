# encoding: utf-8

helpers do
  def page_title(name)
	"#{name}bar"
  end

  def truncate(str, length=15)
	return str if str.blank?
	return str[0, length]
  end
end

get '/'	do
  @sites = Site.paginate(page: params[:page], per_page: 10)
  erb :index
end

get '/site/new' do
  @site = Site.new
  erb :'sites/new'
end

post '/site/create' do
  @site = Site.new(params[:site])
  if @site.save
	redirect '/'
  else
	erb :'sites/new'
  end
end

get '/site/edit/:id' do
  
  begin
	@site = Site.find(params[:id])
  rescue ActiveRecord::RecordNotFound
	halt 401, '内容不存在!'
  else
    if @site
    else
	  halt 401, '内容不存在!'
    end
  end
  erb :'sites/edit'
end

patch '/site/update/:id' do
  @site = Site.find(params[:id])
  if @site.update(params[:site])
	redirect '/'
  else
	erb :'sites/edit'
  end
end

get '/site/destroy/:id' do
  begin
    @site = Site.find(params[:id])
  rescue ActiveRecord::RecordNotFound
	halt 401, '内容不存在!'
  else
	if @site.destroy
	  redirect '/'
	else
	  redirect '/'
	end
  end
end

#url记录
get '/site/page_list' do
  site_id = params[:site_id] || ''
  stat = params[:stat] || ''
  @web_pages = WebPage.site_list(site_id).state_list(stat).paginate(page: params[:page], per_page: 100)

  erb :'sites/page_list'
end

#抓取详情页
get '/site/show/:id' do
  begin
    @web_page = WebPage.find(params[:id])
  rescue ActiveRecord::RecordNotFound
	halt 401, '内容不存在!'
  else
    erb :'sites/show'
  end
end

#shijue_api sites list
get '/api/sites' do
  #parm = JSON.parse(params[:parm])
  sites = Site.normal
  arr = []
  sites.each do |d|
	hash = {
	  id: d.id,
	  mark: d.mark,
	  name: d.name,
	  kind: d.kind,
	  state: d.state,
	  url: d.url,
	  keyword: d.keyword,
	  match_tags: d.match_tags,
	  ignore_tags: d.ignore_tags,
	  sleep: d.sleep
	}
	arr << hash
  end
  return { Result: true, Data: arr }.to_json
end

#shijue_api web_pages list
get '/api/web_pages' do
  parm = JSON.parse(params[:parm])
  site_id = parm['RequestBody']['Query']['SiteId']
  per_page = parm['ResultOptions']['ItemCount']
  page = parm['ResultOptions']['ItemStartNumber']
  arr = []
  puts parm
  web_pages = WebPage.site_list(site_id).state_list(3).paginate(page: page, per_page: per_page)
  web_pages.each do |d|
	hash = {
	  id: d.id,
	  mark: d.mark,
	  title: d.title,
	  url: d.url,
	  tags: d.tags,
	  kind: d.kind,
	  cover_img: d.cover_img,
	  image_group: d.image_group,
	  category: d.category
	}
	arr << hash
  end

  return { ResponseHeader: {code: 200}, Data: arr }.to_json
end

#shijue_api web_page show
get '/api/web_page' do
  parm = JSON.parse(params[:parm])
  result = {}
  begin
    @web_page = WebPage.find(parm['id'])
  rescue ActiveRecord::RecordNotFound
	result[:Result] = false
	result[:Info] = '内容不存在!'
  else
    result[:Result] = true
	web_page = {
	  id: @web_page.id,
	  mark: @web_page.mark,
	  title: @web_page.title,
	  description: @web_page.description,
	  url: @web_page.url,
	  content: @web_page.content,
	  tags: @web_page.tags,
	  kind: @web_page.kind,
	  site_id: @web_page.site_id,
	  keyword: @web_page.keyword,
	  category: @web_page.category,
	  index: @web_page.index,
	  cover_img: @web_page.cover_img,
	  image_group: @web_page.image_group,
	  created_at: @web_page.created_at,
	  updated_at: @web_page.updated_at
	}
	result[:Data] = web_page
  end
  return result.to_json
  
end

#shijue_api set web_page state
get '/api/set_state' do
  parm = JSON.parse(params[:parm])
  result = {}
  begin
    @web_page = WebPage.find(parm['id'])
  rescue ActiveRecord::RecordNotFound
	result[:Result] = false
	result[:Info] = '内容不存在!'
  else
	if @web_page.update(state: parm['state'])
      result[:Result] = true
	  result[:Info] = '设置成功!'
	else
      result[:Result] = false
	  result[:Info] = '设置失败!'
	end
  end
  return result.to_json
end
