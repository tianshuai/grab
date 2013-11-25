grab
======

##grab 抓取网站图片

* 语言: ruby 2.0.0 +
* 数据库: mysql 5.5 +
* 环境: linux
* 作者: 视觉中国 by TianShuai

##介绍：分为前台页面内容显示及后台的抓取任务,暂不能记录抓取节点,如果失败或取消后重新从头抓取

##部署: 

1. 启动mysql并创建数据库`grab`,然后导入数据结构,数据备份所在当前目录db文件夹下
2. 进入终端,在当前目录下执行 bundle install 安装并更新所需gem包
3. 启动: 在终端执行 `rackup` 启动服务(默认端口号9292, 可通过 `-p` 参数指定 )


##操作步骤：

1. 在该目录下打开 终端，首次执行需要安装gem，bundle install,启动命令：rackup ,默认端口号为9292
2. 前台:打开浏览器访问首页：127.0.0.1:9292 ,按提示创建所要抓取的网站并分析网站源代码后填写要抓取的规则
3. 后台:抓取网页执行的任务：rake grab:spider[mark,type];需要传入参数mark,type;mark是要抓取的网站标识


##接口(略):
