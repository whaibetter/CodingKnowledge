### //TODO

![image-20240318203823107](http://42.192.130.83:9000/picgo/imgs/image-20240318203823107.png)

#### Redis了解吗，作用

高效的KV对存储和访问

- 不同数据类型有不同的作用
  - String  分布式锁、缓存
  - ZSet 需要有序并且不能重复的场景，例如排行榜、热门文章。
  - Set 提供不能重复的场景，例如共同好友、好友推荐的场景
  - List 可以用做消息队列，**发布/订阅系统和实时数据流等场景**
  - Hash  对象存储
  - HyperLog 只要12kb就存储，例如网状UV User Visit的统计（唯一用户统计、基数统计）
  - Geo 地理位置，支持地理位置的查询和计算
  - Bitmap 提供了位存储的数据结构，比如统计用户在线情况，用户签到记录

#### Redis数据结构有哪些，你在项目中使用的是哪一种

- String set nx 设置缓存，在有效期内存储缓存

- BitMap setbit key 设置指定key的某一位为1，表示签到，BITCOUNT 命令统计位为1的数量

- ZSet Zadd key 1 设置内容并设置得分，Zrange获取的分的排行

- List 使用 LPUSH 和 RPUSH 命令将消息添加到列表中

- Hash Haset HGet 对hash对象进行操作

- Hyperlog pfadd pfcount获取基数

  

#### Redis健壮性

- aof、rdb
- 集群同步、主从复制

#### 同步、异步

- 同步：按顺序执行，异步：**非阻塞**，执行下一个任务不用等待上一个任务执行完成；通常通过回调函数、事件或者轮询等方式来通知任务的调用者。
- 从一个运行流程中讲，同步指的是发出的消息按流程到后端，后端每个服务逐步向下执行结束后依次返回；异步指的是消息发送到某一层就返回，剩下到操作交给其他服务完成。
  - 例如购买某个商品，后端在接收到数据后调用扣款的一个服务即可能够给到返回，但后台会异步地调用如邮件服务等服务
  - 例如，在对数据库进行修改时，我们常常要更新redis缓存，我们可以让修改redis的操作交给消息队列，消息队列给到对应的消费者异步的进行修改，此时数据库修改的操作成果早就返回到用户端了。

#### 创建线程的方法哪些

- new Thread

- extend Thread

- new Thread(new Runnable(){})

- Callable.call + FutureTask

- **线程池** 

  ```java
  // 提交 Callable 任务给线程池执行
  Future<String> future = executor.submit(new MyCallable());
  ```

#### 线程池作用

- 实现线程的复用，不用频繁的开启关闭线程。
  - 线程的管理、任务调度、
- **线程池会存储收集的任务并存储在队列中**，线程调度就是从队列中获取任务进行执行run方法，**线程执行结束后返回线程池并等待下一个任务的分配。**

#### Springboot spring springMvc

- 相辅相成的作用
- SpringBoot提供了一系列开箱即用的操作，不用自己去定义很多的对象
- Spring 主要在于IOC与AOP
  - IOC让对象的创建不在依赖手动创建，而提交给到了IOC容器，松耦合
  - **事务管理**
  - AOP 使用动态代理的机制，让我们可以对特定的切面进行统一处理，降低了耦合、日志统计、性能监控。
- Spring MVC在于提供了Model View Controller的分层，提供了一套关于Servlet的封装的**Web开发框架，灵活的处理请求和响应的机制、参数效验、视图渲染**

#### Aop 、IOC

- aop使得与核心业务代码不相干的代码能够分离开，并且有效降低耦合。**从核心业务逻辑中分离出来，实现了关注点的集中管理和复用。**
- ioc 依赖关系由系统管理，不用手动管理。

#### 浅拷贝，深拷贝？如何使用

深拷贝和浅拷贝是只针对**Object和Array**这样的引用数据类型的。
深拷贝和浅拷贝的示意图大致如下：
![图片描述](http://42.192.130.83:9000/picgo/imgs/6c073cff2875a4277054bf0d4f363548.png)

- 浅拷贝：在引用中有共用的地址
  - 如clone只是clone了一个新的对象，但里面的引用还是原来的User(Count).clone() user不一样，但Count是用的同一个
- 深拷贝：对象的所有参数都copy个新的地址
  - 实现`Cloneable`接口，并重写`clone()`方法，在`clone()`方法中**对引用类型字段进行深度复制**。
  - 使用序列化和反序列化实现深拷贝。将对象写入输出流（如`ByteArrayOutputStream`），然后从输入流（如`ByteArrayInputStream`）读取对象，实现对象的深拷贝。



#### List a,List b; a=b是浅拷贝还是深拷贝，怎么才能深拷贝

- 浅拷贝，引用的都是同一个地址。
  - 使用Clone并重写clone将所有引用对象都重新拷贝
  - 使用**序列化和反序列化**：通过将对象进行序列化，将其转换为字节流，然后再进行反序列化，可以实现深拷贝。

#### 接口、抽象类的区别，抽象类的作用

- 抽象类是需要继承的、接口是需要实现的。

- 接口一般只有方法的定义，抽象类有抽象方法和具体方法。但在后续jdk8版本中，接口中也增加了static和default的支持

- 实现接口必须实现其全部的方法，继承抽象类不需要。

- **接口是一种纯粹的抽象定义**，定义了一系列**方法的方法声明**。抽象类作为模板或基类，提供**默认实现和强制子类实现特定行为**。

  ![image-20240318213034310](http://42.192.130.83:9000/picgo/imgs/image-20240318213034310.png)

#### String stringbuffer stringbuilder

- **线程安全** StringBuilder 是线程不安全的
- **可变性** StringBuilder 可变；StringBuffer可变但是加了syncronized、String final**不可变**线程安全
- 单线程下使用StringBuilder更好，线程安全，且操作很快。

#### Springboot的注解哪些

- @Configuration
- @SpringBootApplication
- **@Bean**
- **@ConfigurationPropertiesy** 引入外部配置文件
- **@Autowired**
- **@Resource**
- **@ConditionalOn....**

```java
@Configuration
@ConditionalOnClass(LanguageDriver.class)
public class MybatisLanguageDriverAutoConfiguration {

  private static final String CONFIGURATION_PROPERTY_PREFIX = "mybatis.scripting-language-driver";

  /**
   * Configuration class for mybatis-freemarker 1.1.x or under.
   */
  @Configuration
  @ConditionalOnClass(FreeMarkerLanguageDriver.class)
  @ConditionalOnMissingClass("org.mybatis.scripting.freemarker.FreeMarkerLanguageDriverConfig")
  public static class LegacyFreeMarkerConfiguration {
    @Bean
    @ConditionalOnMissingBean
    FreeMarkerLanguageDriver freeMarkerLanguageDriver() {
      return new FreeMarkerLanguageDriver();
    }
          @Bean
    @ConditionalOnMissingBean
    @ConfigurationProperties(CONFIGURATION_PROPERTY_PREFIX + ".freemarker")
    public FreeMarkerLanguageDriverConfig freeMarkerLanguageDriverConfig() {
      return FreeMarkerLanguageDriverConfig.newInstance();
    }
  }
 
```

#### 你项目中怎么向前端传数据的？

1. WebSocket
2. HTTP，设计RestFul的协议，前端通过发送HTTP请求到这些路径来获取数据。后端可以使用常见的Web框架（如Spring MVC）来处理请求，并将数据以JSON、XML等格式返回给前端。