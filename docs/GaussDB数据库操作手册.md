# GaussDB数据库操作手册

## 登陆IAM账户

登陆网址：<https://auth.huaweicloud.com/authui/login?id=beihangdb>。IAM账号密码由助教提前给出，登录后请修改密码。登录界面如下

![E:\Documents\NewWeChat\WeChat Files\wxid_iqqtnccmkr8h22\FileStorage\Temp\1664331029468.png](media/image1.png)

如直接在华为云登陆界面登陆，请使用IAM用户登陆，租户名请填写beihangdb，IAM用户名和密码由助教为每个同学分发。

![E:\Documents\NewWeChat\WeChat Files\wxid_iqqtnccmkr8h22\FileStorage\Temp\1664330960968.png](media/image2.png)

## 使用DAS连接数据库

### 查看数据库实例

成功登陆IAM账户后，进行如下操作，使用DAS连接数据库。指导手册中的数据库实例为gauss-7a55，实际实验中请以老师给出的实例为准。

![E:\Documents\NewWeChat\WeChat Files\wxid_iqqtnccmkr8h22\FileStorage\Temp\1662633770435.png](media/image3.png)

在服务列表，选择数据库中的数据库管理服务DAS，进入DAS服务界面。

![E:\Documents\NewWeChat\WeChat Files\wxid_iqqtnccmkr8h22\FileStorage\Temp\1662640842222.png](media/image4.png)

点击页面上方的“资源”，进入我的资源页面。![E:\Documents\NewWeChat\WeChat Files\wxid_iqqtnccmkr8h22\FileStorage\Temp\1662641059680.png](media/image5.png)![E:\Documents\NewWeChat\WeChat Files\wxid_iqqtnccmkr8h22\FileStorage\Temp\1662641136036.png](media/image6.png)

点击资源类型为“实例”的条目的“查看详情”，进入实例结点的详情页面。**请一定进行这项操作，方便后期连接数据库实例**。

![E:\Documents\NewWeChat\WeChat Files\wxid_iqqtnccmkr8h22\FileStorage\Temp\1663125044730.png](media/image7.png)

可将页面下拉，查看实例的结点信息。可查看各个结点的监控指标。也可浏览左侧栏目中的备份恢复，日志管理等栏目，体会华为云数据库的丰富功能。

### 连接DAS

![E:\Documents\NewWeChat\WeChat Files\wxid_iqqtnccmkr8h22\FileStorage\Temp\1662634230040.png](media/image8.png)

重新进入DAS服务界面。设置DAS连接服务，选择左侧“开发工具”，进入登陆界面。

![E:\Documents\NewWeChat\WeChat Files\wxid_iqqtnccmkr8h22\FileStorage\Temp\1662641491559.png](media/image9.png)

点击“新增数据库实例登陆”进入设置页面。在此设置页面，“数据库引擎”选择GaussDB(for MySQL)，然后在“数据库来源”中就会出现GaussDB (for MySQL)数据库实例，接着选中想要连接的实例。使用助教为每位同学提供的数据库登录用户名及密码，然后先测试下连接，测试成功后会提示“连接成功”，勾选“记住密码”、打开“定时采集”，设置完成后点击“立即新增”。

![E:\Documents\NewWeChat\WeChat Files\wxid_iqqtnccmkr8h22\FileStorage\Temp\1662684075393.png](media/image10.png)

新增完成后，通过点击操作中的“登录”可以进入到相应的数据库实例，具体如下。然后可以进行数据库建表、增删查改等操作。

![E:\Documents\NewWeChat\WeChat Files\wxid_iqqtnccmkr8h22\FileStorage\Temp\1662687646938.png](media/image11.png)

## 数据库基本操作

### 新建表及增删查改操作

可点击库名进入数据库，可点击操作执行相应的数据库操作。**由于学生用户无创建数据库的权限，注意不要随意删除数据库。**

![E:\Documents\NewWeChat\WeChat Files\wxid_iqqtnccmkr8h22\FileStorage\Temp\1662690940515.png](media/image12.png)

新建表基本操作如下图所示：

![E:\Documents\NewWeChat\WeChat Files\wxid_iqqtnccmkr8h22\FileStorage\Temp\1663125674823.png](media/image13.png)

![E:\Documents\NewWeChat\WeChat Files\wxid_iqqtnccmkr8h22\FileStorage\Temp\1663125695373.png](media/image14.png)

点击“打开表”查看数据详情，在详情页面可通过图形化界面进行增删查改等操作。也可通过SQL语句进行数据的增删查改操作。

![E:\Documents\NewWeChat\WeChat Files\wxid_iqqtnccmkr8h22\FileStorage\Temp\1663125975658.png](media/image15.png)

![E:\Documents\NewWeChat\WeChat Files\wxid_iqqtnccmkr8h22\FileStorage\Temp\1663125995264.png](media/image16.png)

### 其他基本操作

可点击SQL操作进行SQL查询，使用SQL语句对数据库进行操作，也可以查看SQL执行记录

![](media/image17.png)

在SQL查询页面可以点击“库名”切换操作对应的数据库

![E:\Documents\NewWeChat\WeChat Files\wxid_iqqtnccmkr8h22\FileStorage\Temp\1662689979878.png](media/image18.png)

针对某个数据库，可以进入左侧的视图、存储过程、触发器等页面，设置并保存相关操作。

![E:\Documents\NewWeChat\WeChat Files\wxid_iqqtnccmkr8h22\FileStorage\Temp\1663126258966.png](media/image19.png)

**附录 权限列表**

表4-1 权限列表

| 权限类型                             |         是否具有权限          |
|--------------------------------------|:-----------------------------:|
| 查看GaussDB数据库参数的权限          | 登陆对应IAM账户后具有此权限， |
| 使用DAS服务完成数据库操作            |  DAS服务配置成功后具有此权限  |
| 在对应的DAS用户下创建数据库的权限    |              无               |
| 关于数据库实例的购买、修改配置等权限 |              无               |
