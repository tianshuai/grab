# encoding: utf-8
# 网站列表
class Site < ActiveRecord::Base

  ##关系
  has_many :webpages

  ##验证
  validates :name, presence: true, length: { minimum: 2 }
  validates_presence_of :mark,                  message: '请输入标识'
  validates_uniqueness_of :mark,				message: '标识已存在'
  validates_presence_of :url,                   message: '请输入网址'
  validates_uniqueness_of :url,					message: '标识已存在'
  validates :remarks, 							length: { maximum: 140,   message: '长度不大于140个字符' }

  #field: name(网站名称), kind(类型: 1.抓取,2.未定义), state(状态: 0.关闭,1.正常), mark(标识:a-z), tags(标签), url(网址), keyword(关键字), match_tags（匹配标签，抓取时只会取含有该关键字的Url）,ignore_tags(需要过滤的关键字), sleep(间隔执行时间,单位秒,默认为3), is_subdomain(是否抓取子域名 0.否, 1.是;　默认0), conf(配置,不同规则的网站有不同的配置,见详情)

  ##常量
  #类型
  KIND = {
	alone: 1,
	group: 2	
  }

  #状态
  STATE = {
	#关闭
	no: 0,
	#开启
	ok: 1	
  }

  #正常
  scope :normal,			-> { where(state: STATE[:ok]) }

end

#抓取 list
class WebPage < ActiveRecord::Base

  ##关系
  belongs_to :site

  ##验证
  validates :title, 							length: { maximum: 150, message: '长度小于150个字符' }
  validates_presence_of :url,                   message: '请输入网址'
  validates_uniqueness_of :url,					message: '网址已存在'
  validates_presence_of :mark,                  message: '请输入标识'
  validates :description, 						length: { maximum: 65535, message: '长度不大于65535个字符' }
  validates :cover_img, 						length: { maximum: 65535, message: '长度不大于65535个字符' }
  validates :image_group, 						length: { maximum: 65535, message: '长度不大于65535个字符' }
  validates :tags, 								length: { maximum: 790,   message: '长度不大于790个字符' }

  #field: url(网址), site_id(关联网站id) kind(抓取类型: 1.单图,2.组图), state(状态: 0.未解析,1.解析成功), mark(标识:a-z), tags(标签), index(索引), title(标题), description(描述), cover_img(封面), image_group(图片组及图片描述) category(类型), content(备用), created_at, updated_at

  ##常量
  #类型
  KIND = {
	alone: 1,
	group: 2	
  }

  #状态
  STATE = {
	#未处理的页面(只有url)
	no: 0,
	#无效页面
	invalid: 1,
	#获取页面信息(未整理)
	ok: 2,
	#整理完成的页面
	finish: 3,
	#忽略(用于接口返回)
	ignore: 5,
	#发布成功(接口返回)
	success: 8
  }


  ##方法
  #路径是否存在?
  def self.exist_url?(url)
	webpage = self.find_by(url: url)
	return true if webpage.present?
	return false
  end

  #状态提示
  def state_str
	case self.state
	when 0 then '保存来源url'
	when 1 then '无效来源'
	when 2 then '获取信息'
	when 3 then '整理'
	when 5 then '忽略'
	when 8 then '发布成功'
	else
	  'error'
	end
  end

  #分类列表
  def self.site_list(site_id)
	return all if site_id.blank?
	return where(site_id: site_id.to_i)
  end

  #状态列表
  def self.state_list(stat)
	return all if stat.blank?
	return where(state: stat.to_i)
  end

  #是否抓取子域名
  def is_subdomain?
	if self.is_subdomain == 0
	  false
	else
	  true
	end
  end

end
