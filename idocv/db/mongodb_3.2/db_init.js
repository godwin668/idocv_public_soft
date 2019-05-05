//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
// MongoDB数据库初始化脚本		  I Doc View 2016年7月
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\

/*
 * 初始化数据库用户
 * 注：如需开启数据库验证，可打开以下代码段注释（删除“数据库验证代码开始”和“数据库验证代码结束”两行），
 *     修改数据库用户名(userName)和数据库密码(userPass)，并在预览服务的配置文件里设置相同的数据库访问用户名和密码
 */
/* 数据库验证代码开始>>>
var adminName = 'dbAdminName';								// 数据库管理员用户名
var adminPass = 'dbAdminPasswd';							// 数据库管理员密码
var userName = 'docviewUser';								// 数据库读写用户名，对应预览服务配置文件的数据库用户名
var userPass = 'docviewPasswd';								// 数据库读写密码，对应预览服务配置文件的数据库密码
db = db.getSiblingDB('admin');
db.createUser(
  {
    user: adminName,
    pwd: adminPass,
    roles: [ { role: "userAdminAnyDatabase", db: "admin" } ]
  }
);
db.auth(adminName, adminPass);
db = db.getSiblingDB('docview');
db.createUser(
  {
    user: userName,
    pwd: userPass,
    roles: [ { role: "readWrite", db: "docview" } ]
  }
);
db.auth(userName, userPass);
数据库验证代码结束<<< */

/*
 * 添加应用
 */
db.app.save(
  {
    "_id": "test",                    // 应用ID，对应服务器存储目录名称，如test对应目录D:\idocv\data\test，其中D:\idocv\data为数据根目录，参见conf.properties配置文件
    "name": "I Doc View",
    "token": "testtoken",             // token，调用预览服务接口时的密钥
    "phone": "4000007644",
    "email": "support@idocv.com",
    "status": NumberInt(0),
    "ctime": "2010-01-01 00:00:00",   // 创建时间
    "utime": "2010-01-01 00:00:00"    // 更新时间
  }
);

/*
 * 添加应用用户
 */
db.user.save(
  {
    "_id": "111111111111111111111111",// 用户ID：24位数字或字母
    "app": "test",                    // 应用id，对应上面应用的_id
    "email": "support@idocv.com",
    "username": "admin",              // 用户名
    "password": "admin",              // 密码
    "status": NumberInt(100),         // 用户状态：0：注册用户，但未验证邮箱；
                                      //           1：普通用户，可以上传和预览自己的文档；
                                      //           100：管理员，可以上传和预览当前用户所属应用下的所有文档。
    "ctime": "2013-01-01 00:00:00",   // 创建时间
    "utime": "2013-01-01 00:00:00"    // 更新时间
  }
);