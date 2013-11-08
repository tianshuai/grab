# encoding: utf-8

helpers do
  def page_title(name)
	"#{name}bar"
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


  #url记录
  get '/site/web_page/list' do
	site_id = params[:site_id] || 0
	WebPage.where()
  end

end
