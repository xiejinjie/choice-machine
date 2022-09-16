# 选择机 公众号

微信公众号 选择机

用户在公众号发送一个问题，用？结尾，后台接受到消息之后会回复yes/no，并回复一段有趣的话

使用沙雕api开放接口回复彩虹屁和毒鸡汤
https://api.shadiao.pro/chp
https://api.shadiao.pro/du

想用yesno开放接口回复动态图和yes/no,但发现微信不支持回复gif
https://yesno.wtf/api

## 部署
部署在阿里云FC平台，函数启动命令 bundle exec rackup -o 0.0.0.0 -p 80。打包代码上传到平台之后需要执行 bundle install命令，保证函数运行环境正常。接受到微信平台推送消息之后，请求开放接口，组装消息后回复给用户。

## 启动命令
bundle exec rackup -o 0.0.0.0 -p 80

## 本地测试
bundle install
bundle exec rackup

