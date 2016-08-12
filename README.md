# -Sample-MaxEducation-iOS

使用步骤：

1、在maxleap.cn中创建app，记录appid和clientkey。

2、更换AppDelegate.m中的宏定义为1中的appid和clientkey：

    #define MAXLEAP_APPID           @"your_app_id"
    #define MAXLEAP_CLIENTKEY       @"your_client_key"

3、如果要使用微博、QQ和微信第三方登录，需要先在相应的开发者后台注册app，输入正确的app信息。

4、更换AppDelegate.m中的以下宏定义：

    #define WECHAT_APPID            @"your_wechat_appid"
    #define WECHAT_SECRET           @"your_wechat_secret"
    #define WEIBO_APPKEY            @"your_weibo_appkey"
    #define WEIBO_REDIRECTURL       @"your_weibo_redirect_url"
    #define QQ_APPID                @"your_qq_appid"

5、更新Info.plist文件中URL Types中以上第三方登陆需要的设置。

6、云存储使用

  1).在maxleap.cn后台对应的app中创建表格，添加字段
  
  2).云储存中的所有对象都继承自MLObject，MLObject类中提供提供CRUD方法
  
     MLObject *obj = ****;
     
     [obj saveInBack....];
     
  3).获取云储存表格中的数据
  
    MLQuery *query = [MLQuery queryWithClassName@"TABLE_NAME"];
    
    query可以设置查询条件：
    
    [query whereKey:@"aKey(eg.age)" equalTo:@"18"];
    
    [query findObjectsInBackgroundWithBlock:(nullable MLArrayResultBlock)block];
    
    query 会在根据设置条件查询符合的MLObject，会在block 中返回结果。
  
