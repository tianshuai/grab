# encoding: utf-8
class Site < ActiveRecord::Base

  ##关系
  has_many :webpages

  validates :name, presence: true, length: { minimum: 2 }
  validates_presence_of :mark,                  message: '请输入标识'
  validates_uniqueness_of :mark,				message: '标识已存在'
  validates_presence_of :url,                   message: '请输入网址'
  validates_uniqueness_of :url,					message: '标识已存在'

  #field: name(网站名称), kind(类型: 1.抓取,2.未定义), state(状态: 0.关闭,1.正常), mark(标识:a-z), tags(标签), url(网址), keyword(关键字), match_tags（匹配标签，抓取时只会取含有该关键字的Url）,ignore_tags(需要过滤的关键字), sleep(间隔执行时间,单位秒,默认为3), conf(配置,不同规则的网站有不同的配置,见详情)

  ##常量
  #类型
  KIND = {
	alone: 1,
	group: 2	
  }

  #状态
  STATE = {
	#未处理的页面
	no: 0,
	#处理完成的页面
	ok: 1	
  }

end

class WebPage < ActiveRecord::Base

  ##关系
  belongs_to :site

  #validates :title, presence: true, length: { minimum: 2 }
  validates_presence_of :url,                   message: '请输入网址'
  validates_uniqueness_of :url,					message: '网址已存在'
  validates_presence_of :mark,                  message: '请输入标识'

  #field: url(网址), site_id(关联网站id) kind(抓取类型: 1.单图,2.组图), state(状态: 0.未解析,1.解析成功), mark(标识:a-z), tags(标签), index(索引), title(标题), description(描述), cover_img(封面), category(类型), content(备用), created_at, updated_at

  ##常量
  #类型
  KIND = {
	alone: 1,
	group: 2	
  }

  #状态
  STATE = {
	#未处理的页面
	no: 0,
	#无效页面
	invalid: 1,
	#处理完成的页面
	ok: 2
  }


  ##方法
  #路径是否存在?
  def self.exist_url?(url)
	webpage = self.find_by(url: url)
	return true if webpage.present?
	return false
  end

end
