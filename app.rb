require 'digest/sha1'
require 'net/https'
require 'json'
require 'rexml/document'
include REXML

get "/" do
    "Hello"
end

# wechat接入认证
get "/wechat/msg" do
    signature = params['signature']
    echostr = params['echostr']
    timestamp = params['timestamp']
    nonce = params['nonce']
    token=settings.token
    temp_str = [token, timestamp, nonce].sort!.join
    sha1_str = Digest::SHA1.hexdigest(temp_str)
    puts sha1_str
    puts signature
    if sha1_str == signature
        echostr
    else 
        "Auth failed!"
    end
end

# 消息处理
post "/wechat/msg" do
    request.body.rewind  # in case already read it
    xml_data = request.body.read
    puts "get a wechat msg: #{xml_data}"
    xmldoc = Document.new(xml_data)
    msg_type = XPath.first(xmldoc, "//MsgType").text
    to_user = XPath.first(xmldoc, "//ToUserName").text
    from_user = XPath.first(xmldoc, "//FromUserName").text
    if msg_type == "text" 
        content = XPath.first(xmldoc, "//Content").text
        if content[-1,1] == "?" or  content[-1,1] == "？"  
            answer = get_yes_no_answer!
            if answer['answer'].downcase == "yes" 
                chp = get_chp!
                message = answer['answer'] + "\n" + chp['data']['text']
            else 
                du = get_du!
                message = answer['answer'] + "\n" + du['data']['text']
            end
        else
            pyq = get_chp!
            message = "问我一个问题，请用?结尾" + "\n" + pyq['data']['text']
        end
        get_wechat_msg(from_user, to_user, message) # 互换收发信人
    elsif msg_type == "event"
        pyq = get_chp!
        message = "问我一个问题，请用?结尾" + "\n" + pyq['data']['text']
        get_wechat_msg(from_user, to_user, message) # 互换收发信人
    else 
        "success"
    end
end

def get_wechat_msg(to_user, from_user, message)
    doc = REXML::Document.new
    element_xml = doc.add_element('xml')
    element_to_user_name = element_xml.add_element('ToUserName')
    element_from_user_name = element_xml.add_element('FromUserName')
    element_to_msg_type = element_xml.add_element('MsgType')
    element_to_content = element_xml.add_element('Content')
    element_create_time = element_xml.add_element('CreateTime')
    CData.new to_user, '', element_to_user_name 
    CData.new from_user, '', element_from_user_name 
    CData.new 'text', '', element_to_msg_type 
    element_create_time.add_text Time.now.to_i.to_s 
    CData.new message, '', element_to_content 
    output = ""
    doc.write(output)
    output
end

def get_yes_no_answer!
    url = URI('https://yesno.wtf/api')
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    body = http.get(url).body
    JSON.parse(body)
end

def get_chp!
    url = URI('https://api.shadiao.pro/chp')
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    body = http.get(url).body
    JSON.parse(body)
end

def get_du!
    url = URI('https://api.shadiao.pro/du')
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    body = http.get(url).body
    JSON.parse(body)
end