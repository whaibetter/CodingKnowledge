- Spring常见面试题总结

  

  ## Spring 基础

  ### 什么是 Spring 框架?

  很多模块的集合，使用这些模块可以很方便地协助我们进行开发。

  - Data
  - Web
  - AOP
  - Aspects

  ![Spring5.x主要模块](http://img.whaifree.top//20200831175708.png)

  #### core container

  - **spring-core**：Spring 框架基本的核心工具类。
  - **spring-beans**：提供对 bean 的创建、配置和管理等功能的支持。
  - **spring-context**：提供对国际化、事件传播、资源加载等功能的支持。
  - **spring-expression**：提供对表达式语言（Spring Expression Language） SpEL 的支持，只依赖于 core 模块，不依赖于其他模块，可以单独使用。

  ### Spring,Spring MVC,Spring Boot 之间什么关系?

  - Spring 主要是 core container（主要提供 IoC 依赖注入功能的支持）

  - Spring MVC 是 Spring 中的一个很重要的模块，主要赋予 Spring 快速构建 MVC 架构的 Web 程序的能力。**MVC 是模型(Model)、视图(View)、控制器(Controller)**的简写，其核心思想是通过将业务逻辑、数据、显示分离来组织代码。

  - SpringBoot

    > 使用 Spring 进行开发各种配置过于麻烦比如开启某些 Spring 特性时，需要用 XML 或 Java 进行显式配置。
    >
    > **（减少配置文件，开箱即用！）**
    >
    > **Spring Boot 帮你简化了 Spring MVC 的很多配置，真正做到开箱即用！**

  ## IOC

  ### Spring IoC 是什么？优缺点？案例？

  - Inversion of Control

    > 是一种设计思想
    >
    > - **将对象的管理交给IoC容器**
    >
    >   需要什么对象直接从IoC容器中获取，由IoC来进行对象的注入

    - 优点
      1. 简化开发的过程，无需考虑对象如何创建
      2. 配置好，在需要地时候直接使用

  - [Spring IOC 容器源码分析_Javadoop](https://javadoop.com/post/spring-ioc)

    > ClassPathXmlApplicationContext
    >
    > ```xml
    > <bean id="messageService" class="com.javadoop.example.MessageServiceImpl"/>
    > ```
    >
    > ```java
    > // 用我们的配置文件来启动一个 ApplicationContext
    > ApplicationContext context = new ClassPathXmlApplicationContext("classpath:application.xml");
    > 
    > 
    > // 从 context 中取出我们的 Bean，而不是用 new MessageServiceImpl() 这种方式
    > MessageService messageService = context.getBean(MessageService.class);
    > ```
    >
    > - 需要地时候直接从context获取就可以了

  ### -----BeanFactory是什么？

  - 负责生产和管理各个 bean 实例的工厂

  - ApplicationContext 其实就是一个 BeanFactory

    

  ###  什么是 Spring Bean？

  - Bean 代指的就是那些被 IoC 容器所管理的对象。

  ### Bean 的作用域有哪些?如何配置？

  - **singleton** : IoC 容器中只有唯一的 bean 实例。Spring 中的 bean 默认都是单例的，是对单例设计模式的应用。
  - **prototype** : 每次获取都会创建一个新的 bean 实例。也就是说，连续 `getBean()` 两次，得到的是不同的 Bean 实例

  ```java
  @Bean
  @Scope(value = ConfigurableBeanFactory.SCOPE_PROTOTYPE)
  @Component 
  @Scope(ConfigurableBeanFactory.SCOPE_PROTOTYPE)
  ```

  ### 将一个类声明为 Bean 的注解有哪些?

  > `@Component`：通用的注解，可标注任意类为 `Spring` 组件。如果一个 Bean 不知道属于哪个层，可以使用`@Component` 注解标注。
  >
  > `@Repository` : 对应持久层即 Dao 层，主要用于数据库相关操作。
  >
  > `@Service` : 对应服务层，主要涉及一些复杂的逻辑，需要用到 Dao 层。
  >
  > `@Controller` : 对应 Spring MVC 控制层，主要用于接受用户请求并调用 `Service` 层返回数据给前端页面

  ### @Component 和 @Bean 的区别是什么？

  1. `@Component` 注解作用于类，而`@Bean`注解作用于方法。
  2. `@Component` 通过 `@ComponentScan` 自动装配，`@Bean` 为在此方法中生产Bean（`@Bean new Interpret`）
  3. `@Bean` 注解比 `@Component` 注解的自定义性更强，使用第三方库的时候要用

  ### 注入 Bean 的注解有哪些？

  | Annotaion    | Package                            | Source       |
  | ------------ | ---------------------------------- | ------------ |
  | `@Autowired` | `org.springframework.bean.factory` | Spring 2.5+  |
  | `@Resource`  | `javax.annotation`                 | Java JSR-250 |
  | `@Inject`    | `javax.inject`                     | Java JSR-330 |

  ###  @Autowired 和 @Resource 的区别是什么？@Qualifier有什么用

  - `@Autowired` byType-->byName，如果有多个实现类可能无法正确注入，这时会根据名称注入
  - 通过 `@Qualifier` 注解来显式指定名称
  - ` @Resource `byName-->byType

  ```java
  @Autowired
  private SmsService smsServiceImpl1;
  // 正确注入  SmsServiceImpl1 对象对应的 bean
  // smsServiceImpl1 就是我们上面所说的名称
  @Autowired
  @Qualifier(value = "smsServiceImpl1")
  private SmsService smsService;
  ```

  ```java
  @Resource
  private SmsService smsServiceImpl1;
  @Resource(name = "smsServiceImpl1")
  private SmsService smsService;
  ```

  **区别：**

  > - `@Autowired` 是 Spring 提供的注解，`@Resource` 是 JDK 提供的注解。
  > - `Autowired` 默认byType，`@Resource`默认byName
  > - `Autowired`可以通过 `@Qualifier`，`@Resource`可以通过 `name`显示指定
  > - `@Resource`不能在构造函数使用

  ### Bean 是线程安全的吗？如何解决？

  分情况

  1. ProtoType不存在线程安全问题，每次都获取一个实例

  2. 如果Singleton下**有状态（包含可变的成员变量的对象）**，有线程安全问题。

  解决

  1. 避免定义可变的成员变量
  2. **定义一个 `ThreadLocal` 成员变量，将成员变量存在这里**

  

  ### ----Bean 的生命周期?

  ![Spring Bean 生命周期](http://img.whaifree.top//b5d264565657a5395c2781081a7483e1.jpg)

  > [Spring bean生命周期的源码分析（超级详细）_springbean生命周期 luban-CSDN博客](https://blog.csdn.net/qq_40634846/article/details/106604539)
  >
  > 1. **创建前准备阶段** 下文和相关配置中解析并查找Bean有关的扩展实现，
  > 2. **实例化**（Instantiation） 反射创建BeanDefinition
  > 3. **依赖注入**
  > 4. **初始化**（Initialization）执行各种通知、前置后置方法
  > 5. **销毁**（Destruction）
  >
  > ![在这里插入图片描述](http://img.whaifree.top//20210707225212729.png)
  >
  > 【史上最完整的Spring Bean的生命周期】https://www.bilibili.com/video/BV1584y1r7n6?vd_source=21aa5b1c385af63d5599b344a74f3ebe
  >
  > 1. 扫描所有类
  > 2. 找到要的类，并定义对应的BeanDefinition，放入Map
  > 3. 遍历Map生成对应的Bean
  >    1. 构造对象 creatBeanInstance 反射 构造方法 @Autowired
  >       - 根据参数在单例池中查找参数进行赋值
  >    2. 填充属性 populateBean **三级缓存机制依赖注入**
  >    3. 初始化实例 initializeBean 
  >       - invokeAwareMethods
  >       - invokeinitMethods
  >    4. 注册销毁
  > 4. addSingleton
  > 5. close
  >    - postProcessBeforeDestruction
  >    - 

  ### Spring 中，有两个 id 相同的 bean，会报错吗，如果会报错，在哪个阶段报错

  - id标志bean，有唯一性，会报错。

  - 这个错误发生Spring对XML文件进行解析**转化为BeanDefinition**的阶段。

  - 在`@Configuration`中的Bean会覆盖，在Spring IOC容器中只会注册第一个声明的Bean的实例

    - 根据@Autowired 和 @Resource 进行ByType ByName引入，会有不同效果

    ```java
    @Configuration
    public class MyConfiguration{
        // 只会生效一个
    	@Bean(name = 'conf')
    	public Adapter1 a1(){
    		return new Adapter1();
    	}
    	@Bean(name = 'conf')
    	public Adapter2 a2(){
    		return new Adapter2();
    	}
    }
    ```

  ### Spring如何解决循环依赖问题？

  > 三级缓存，其实就是用来存放不同类型的Bean。
  >
  > - 第一级缓存存放完全**初始化好的Bean**，这个Bean可以直接使用了
  > - 第二级缓存存放**原始的Bean对象（未赋值）**，也就是说Bean里面的属性还没有进行赋值
  > - 第三级缓存存放**Bean工厂对象**（主要是解决代理对象的循环依赖问题），用来生成原始Bean对象并放入到二级缓存中
  >
  > 把Bean的**实例化**和Bean中**属性的依赖注入**这两个过程分离出来。
  >
  > ### A循环依赖B
  >
  > ==注入不完整的再初始化进入一级缓存==
  >
  > 1. 创建A，放入三级缓存
  >    - 需要B
  > 2. 创建B，放入三级缓存
  >    - 需要A（已经创建了）
  > 3. 已经创建的A进入二级缓存A
  >    - B直接注入不完整的A
  > 4. B完成初始化，并放入一级缓存
  > 5. A注入B
  >    - 从一级缓存获取B
  >    - A完成注入，放入一级缓存

  Spring本身只能解决单实例存在的循环引用问题，但是存在以下四种情况需要人为干预：

  - 多实例的Setter注入导致的循环依赖，需要把Bean改成单例。
  - constructor注入导致的循环依赖，可以通过@Lazy注解
  - DependsOn导致的循环依赖，找到注解循环依赖的地方，迫使它不循环依赖。
  - 单例的代理对象Setter注入导致的循环依赖，可以使用@Lazy注解，或者使用@DependsOn注解指定加载先后关系。

  ### Spring中BeanFactory和FactoryBean的区别?

  [Spring中的BeanFactory与FactoryBean看这一篇就够了 - 宜春 - 博客园 (cnblogs.com)](https://www.cnblogs.com/yichunguo/p/13922189.html)

  Bean**Factory** 工厂 **IOC容器的核心接口**

  - BeanFactory是负责生产和管理Bean的一个工厂接口，提供一个Spring Ioc容器规范,，getBean从容器中获取指定的Bean实例。
  - BeanFactory在产生Bean的同时，还提供了解决Bean之间的依赖注入的能力，也就是所谓的DI

  Factory**Bean ** 

  - 能**生产或者修饰对象生成的工厂Bean**,它的实现与设计模式中的工厂模式和修饰器模式类似

    通过实现该接口定制实例化Bean的逻辑，**第三方库实现该接口进行实例化**

  > FactoryBean表现的是一个工厂的职责。 **即一个Bean A如果实现了FactoryBean接口，那么A就变成了一个工厂，根据A的名称获取到的实际上是工厂调用getObject()返回的对象，而不是A本身，如果要获取工厂A自身的实例，那么需要在名称前面加上'&'符号。** 通俗点表达就是
  >
  > > - getObject(' name ')   返回**工厂返回的**的实例 
  > > - getObject(' &name ')   返回**工厂本身**的实例

  ```java
  public interface BeanFactory {
  	//对FactoryBean的转义定义，因为如果使用bean的名字检索FactoryBean得到的对象是工厂生成的对象，
  	//如果需要得到工厂本身，需要转义
  	String FACTORY_BEAN_PREFIX = "&";
  
  	//根据bean的名字，获取在IOC容器中得到bean实例
  	Object getBean(String name) throws BeansException;
  
  	//根据bean的名字和Class类型来得到bean实例，增加了类型安全验证机制。
  	<T> T getBean(String name, @Nullable Class<T> requiredType) throws BeansException;
  
  	Object getBean(String name, Object... args) throws BeansException;
  
  	<T> T getBean(Class<T> requiredType) throws BeansException;
  
  	<T> T getBean(Class<T> requiredType, Object... args) throws BeansException;
  
  	//提供对bean的检索，看看是否在IOC容器有这个名字的bean
  	boolean containsBean(String name);
  
  	//根据bean名字得到bean实例，并同时判断这个bean是不是单例
  	boolean isSingleton(String name) throws NoSuchBeanDefinitionException;
  
  	boolean isPrototype(String name) throws NoSuchBeanDefinitionException;
  
  	boolean isTypeMatch(String name, ResolvableType typeToMatch) throws NoSuchBeanDefinitionException;
  
  	boolean isTypeMatch(String name, @Nullable Class<?> typeToMatch) throws NoSuchBeanDefinitionException;
  
  	//得到bean实例的Class类型
  	@Nullable
  	Class<?> getType(String name) throws NoSuchBeanDefinitionException;
  
  	//得到bean的别名，如果根据别名检索，那么其原名也会被检索出来
  	String[] getAliases(String name);
  }
  
  ```

  ```java
  public interface FactoryBean<T> {
  	//从工厂中获取bean【这个方法是FactoryBean的核心】
  	@Nullable
  	T getObject() throws Exception;
  	
  	//获取Bean工厂创建的对象的类型【注意这个方法主要作用是：该方法返回的类型是在ioc容器中getbean所匹配的类型】
  	@Nullable
  	Class<?> getObjectType();
  	
  	//Bean工厂创建的对象是否是单例模式
  	default boolean isSingleton() {
  		return true;
  	}
  }
  ```

  

  ## AoP

  ### 谈谈自己对于 AOP 的了解?

  将那些与业务无关，但又需要为业务共用的模块（例如事务处理、日志管理、权限控制等）封装起来，降低耦合

  - 优点：降低耦合，可拓展性

  ### AOP原理是什么呢？

  Spring AOP 就是基于动态代理的

  - 基于接口的 **JDK Proxy**，
  - 基于类的 **Cglib** 

  ### Spring AOP 和 AspectJ AOP 有什么区别？

  - **Spring AOP 属于==运行时==增强，而 AspectJ 是==编译时==增强。** 
  - Spring AOP 基于代理(Proxying)，而 AspectJ 基于字节码操作(Bytecode Manipulation)。

  当切面太多的话，最好选择 AspectJ ，它比 Spring AOP 快很多。

  ### AspectJ 定义的通知类型有哪些？

  - before
  - after
  - afterReturning
  - afterThrowing （与afterReturning互斥）
  - Around

  ### 多个切面的执行顺序如何控制？

  - `@Order` 注解直接定义切面顺序

  - 实现`Ordered` 接口重写 `getOrder` 方法。

    ```java
    // 值越小优先级越高
    @Order(3)
    @Component
    @Aspect
    public class LoggingAspect implements Ordered {
    
        // ....
    
        @Override
        public int getOrder() {
            // 返回值越小优先级越高
            return 1;
        }
    }
    
    ```

  ## Spring MVC

  ### 说说自己对于 Spring MVC 了解?

  - 模型(Model)、视图(View)、控制器(Controller)
  - MVC 是一种设计模式

  ###  Spring MVC 的核心组件有哪些？

  **根据请求，找到处理器的过程**

  - **`DispatcherServlet`**：**核心的中央处理器**，负责接收请求、分发，并给予客户端响应。

  - **`HandlerMapping`**：**处理器映射器**，根据 URL 去匹配查找能处理的 `Handler` ，并会将请求涉及到的拦截器和 `Handler` 一起封装。

  - **`HandlerAdapter`**：**处理器适配器**，根据 `HandlerMapping` 找到的 `Handler` ，适配执行对应的 `Handler`；

  - **`Handler`**：**请求处理器**，处理实际请求的处理器。

  - **`ViewResolver`**：**视图解析器**，根据 `Handler` 返回的逻辑视图 / 视图，解析并渲染真正的视图，并传递给 `DispatcherServlet` 响应客户端

    

  ### SpringMVC 工作原理了解吗?

  - 中央处理器拦截请求
  - DS调用映射器**匹配**Handler（Controller）
  - DS调用适配器**执行**Handler（Controller）
  - 响应ModelAndView给DS
  - 视图解析器解析MaV

  ![img](http://img.whaifree.top//de6d2b213f112297298f3e223bf08f28.png)

  ### 统一异常处理怎么做？

  [spring的@ControllerAdvice注解 - yanggb - 博客园 (cnblogs.com)](https://www.cnblogs.com/yanggb/p/10859907.html)

  -  `@ControllerAdvice`  Controller增强器，作用是给Controller控制器添加统一的操作或处理。

     1. `@ExceptionHandler`，用于捕获Controller中抛出的指定类型的异常

     2. `@InitBinder`，用于request中自定义参数解析方式进行注册，从而达到自定义指定格式参数的目的。**如转换日期格式**

     3. `@ModelAttribute`，表示其注解的方法将会在目标Controller方法执行之前执行。

  ```java
  @RestControllerAdvice
  @Slf4j
  public class GlobalExceptionHandler{
      
  
      /**
       * 权限校验异常
       */
      @ExceptionHandler(AccessDeniedException.class)
      public AjaxResult handleAccessDeniedException(AccessDeniedException e, HttpServletRequest request)
      {
          String requestURI = request.getRequestURI();
          e.printStackTrace();
          log.error("请求地址'{}',权限校验失败'{}'", requestURI, e.getMessage());
          return AjaxResult.error("没有权限，请联系管理员授权");
      }
  ```

  - `ExceptionHandlerMethodResolver` 中 `getMappedMethod` 方法

  ## SpringBoot

  ### 什么是 SpringBoot 自动装配？

  - 无需进行Bean的配置，直接`@SpringBootApplication`进行strat就行

  - 启动时会扫描外部引用 jar 包中的`META-INF/spring.factories`文件，将文件中配置的类型信息加载到 Spring 容器 **配置都写好了**

    

  ### SpringBoot 是如何实现自动装配的？如何实现按需加载？

  > 1. `@EnableAutoConfiguration`
  > 2. `Import(AutoConfigurationImportSelector.class) `自动配置选择器
  > 3.  `getAutoConfigurationEntry`方法会**扫描所有SpringBootStarter的 `META-INF/spring.factories`**
  >    - `META-INF/spring.factories`里面就是需要的 `@xxxAutoConfigure`
  >    - **按需加载：** `@ConditionalOnClass({ RabbitTemplate.class, Channel.class })`

  - 注解

  ```java
  /**
  表示一个configuration类，声明一个或多个@Bean方法，同时触发auto-configuration和component scanning 。这是一个方便的注释，相当于声明@Configuration 、 @EnableAutoConfiguration和@ComponentScan 
   */
  @Target(ElementType.TYPE)
  @Retention(RetentionPolicy.RUNTIME)
  @Documented
  @Inherited
  @SpringBootConfiguration
  @EnableAutoConfiguration // 自动配置机制
  @ComponentScan(excludeFilters = { @Filter(type = FilterType.CUSTOM, classes = TypeExcludeFilter.class),
  		@Filter(type = FilterType.CUSTOM, classes = AutoConfigurationExcludeFilter.class) }) // 扫描各种@Component
  public @interface SpringBootApplication {
  ```

  ```java
  @Target(ElementType.TYPE)
  @Retention(RetentionPolicy.RUNTIME)
  @Documented
  @Inherited
  @AutoConfigurationPackage
  @Import(AutoConfigurationImportSelector.class) // 通过这个类自动装配
  public @interface EnableAutoConfiguration {
  ```

  #### AutoConfigurationImportSelector 自动配置选择器

  ```java
  public class AutoConfigurationImportSelector implements DeferredImportSelector, BeanClassLoaderAware, ResourceLoaderAware, BeanFactoryAware, EnvironmentAware, Ordered {
      	@Override
  	public String[] selectImports(AnnotationMetadata annotationMetadata) {
  		if (!isEnabled(annotationMetadata)) {
  			return NO_IMPORTS;
  		}
           //<2>.获取所有需要装配的bean
  		AutoConfigurationEntry autoConfigurationEntry = getAutoConfigurationEntry(annotationMetadata);
  		return StringUtils.toStringArray(autoConfigurationEntry.getConfigurations());
  	}
  }
  
  public interface DeferredImportSelector extends ImportSelector {
  }
  
  public interface ImportSelector { // 获取所有符合条件的类全限定类名，被加载到IOC
      String[] selectImports(AnnotationMetadata var1);
  }
  
  ```

  - 返回配置，过滤不满足@DependOn等的类

  ```java
  	/**
  根据导入@Configuration类的AnnotationMetadata返回AutoConfigurationImportSelector.AutoConfigurationEntry 
  	 */
  	protected AutoConfigurationEntry getAutoConfigurationEntry(AnnotationMetadata annotationMetadata) {
  		if (!isEnabled(annotationMetadata)) {
  			return EMPTY_ENTRY;
  		}
  		AnnotationAttributes attributes = getAttributes(annotationMetadata);
  		List<String> configurations = getCandidateConfigurations(annotationMetadata, attributes);// 返回应该加载的配置
  		configurations = removeDuplicates(configurations);
  		Set<String> exclusions = getExclusions(annotationMetadata, attributes);//用于获取EnableAutoConfiguration注解中的 exclude 和 excludeName。
  		checkExcludedClasses(configurations, exclusions);
  		configurations.removeAll(exclusions);
  		configurations = getConfigurationClassFilter().filter(configurations);// 过滤ConditionOn不满足的类
  		fireAutoConfigurationImportEvents(configurations, exclusions);
  		return new AutoConfigurationEntry(configurations, exclusions);
  	}
  ```

  ```java
  /**
  使用给定的类加载器从"META-INF/spring.factories"加载给定类型的工厂实现的完全限定类名。
  参数：
  factoryType – 代表工厂的接口或抽象类 
  classLoader – 用于加载资源的类加载器；可以为null以使用默认值
  */
  public static final String FACTORIES_RESOURCE_LOCATION = "META-INF/spring.factories";
  
  	public static List<String> loadFactoryNames(Class<?> factoryType, @Nullable ClassLoader classLoader) {
  		String factoryTypeName = factoryType.getName();
  		return loadSpringFactories(classLoader).getOrDefault(factoryTypeName, Collections.emptyList());
  	}
  ```

  ### 如何实现一个 Starter？

  

  ### 如何理解Spring Boot中的Starter？

  - Starter是Spring Boot的四大核心功能特性之一，除此之外，Spring Boot还有自动装配、Actuator监控等特性。

  - 只需要关心业务逻辑，减少对配置和外部环境的依赖。

    > **自动装配Bean**、从功能维度，自动引入相关Jar和版本
    >
    > **配置维护** yaml中配置

    官方维护的starter的以spring-boot-starter开头的前缀。

    第三方维护的starter是以spring-boot-starter结尾的后缀

  

  ## Spring 框架中用到了哪些设计模式？

  > 关于下面这些设计模式的详细介绍，可以看我写的 [Spring 中的设计模式详解open in new window](https://javaguide.cn/system-design/framework/spring/spring-design-patterns-summary.html) 这篇文章。

  - **工厂设计模式** : Spring 使用工厂模式通过 `BeanFactory`、`ApplicationContext` 创建 bean 对象。
  - **代理设计模式** : Spring AOP 功能的实现。
  - **单例设计模式** : Spring 中的 Bean 默认都是单例的。
  - **模板方法模式** : Spring 中 `jdbcTemplate`、`hibernateTemplate` 等以 Template 结尾的对数据库操作的类，它们就使用到了模板模式。
  - **包装器设计模式** : 我们的项目需要连接多个数据库，而且不同的客户在每次访问中根据需要会去访问不同的数据库。这种模式让我们可以根据客户的需求能够动态切换不同的数据源。
  - **观察者模式:** Spring 事件驱动模型就是观察者模式很经典的一个应用。
  - **适配器模式** : Spring AOP 的增强或通知(Advice)使用到了适配器模式、spring MVC 中也是用到了适配器模式适配`Controller`。
  - ……

  ## Spring 事务

  ### Spring 事务中事务传播行为?有哪几种？

  - 事务传播行为是为了解决方法调用的事务问题。

  > 1. **传播 `TransactionDefinition.PROPAGATION_REQUIRED`** 该方法在事务中，就为该事务的一部分；如果不在，启动一个新事务。（B属于A）
  > 2. **新建 `TransactionDefinition.PROPAGATION_REQUIRES_NEW`** 不管外部方法，直接重启一个新事务。
  > 3. **嵌套 `TransactionDefinition.PROPAGATION_NESTED`** 嵌套一个子事务
  > 4. 强制性 **`TransactionDefinition.PROPAGATION_MANDATORY`**

  1. **`TransactionDefinition.PROPAGATION_SUPPORTS`**: 如果当前存在事务，则加入该事务；如果当前没有事务，则以非事务的方式继续运行。
  2. **`TransactionDefinition.PROPAGATION_NOT_SUPPORTED`**: 以非事务方式运行，如果当前存在事务，则把当前事务挂起。
  3. **`TransactionDefinition.PROPAGATION_NEVER`**: 以非事务方式运行，如果当前存在事务，则抛出异常。

  ### Spring 事务中的隔离级别有哪几种?

  > - 脏读：A读取到B未提交的数据 
  >
  >   **解决：Read_commited 读已经提交的**
  >
  > - 不可重复读：A前后多次读取，数据内容不一致，其实是B修改了数据
  >
  >   **解决：REPEATABLE_READ ，读取数据时加共享锁，写数据时加排他锁，都是事务提交才释放锁。**
  >
  > - 幻读：A前后多次读取，条数不一致，其实是B增减了条数
  >
  >   **解决：serializable 串行单线程**

  1. 读未提交 模式（READ_UNCOMMITTED），脏读、不可重复读、幻读
  2. 读已提交模式（READ_COMMITTED) **Mysql默认** ，不可重复读、幻读
  3. 可重复读模式（REPEATABLE_READ），在这种隔离级别下，幻读
  4. 串行化 模式（SERIALIZABLE）。串行事务，没有安全问题

  ```java
  public enum Isolation {
      DEFAULT(TransactionDefinition.ISOLATION_DEFAULT), 
      READ_UNCOMMITTED(TransactionDefinition.ISOLATION_READ_UNCOMMITTED), 
      READ_COMMITTED(TransactionDefinition.ISOLATION_READ_COMMITTED),
      REPEATABLE_READ(TransactionDefinition.ISOLATION_REPEATABLE_READ),
      SERIALIZABLE(TransactionDefinition.ISOLATION_SERIALIZABLE);
      
      private final int value;
      Isolation(int value) {
          this.value = value;
      }
      public int value() {
          return this.value;
      }
  }
  ```

  ### @Transactional(rollbackFor = Exception.class)的作用

  - `@Transcational`会在`RuntimeException`回滚，数据库里面的数据也会回滚。
  - `rollbackFor = Exception.class` 可以让`非RuntimeException`也回滚

  ##  Spring Data JPA

  ##  Spring Security

  ###  hasRole 和 hasAuthority 有区别吗？

  [Spring Security 中的 hasRole 和 hasAuthority 有区别吗？ (qq.com)](https://mp.weixin.qq.com/s/GTNOa2k9_n_H0w24upClRw)

  hasRole 的处理逻辑和 hasAuthority 似乎一模一样

  - hasRole 这里会自动给传入的字符串加上 `ROLE_` 前缀，所以在数据库中的权限字符串需要加上 `ROLE_` 前缀。即数据库中存储的用户角色如果是 `ROLE_admin`，这里就是 admin。

  ```java
  private static String hasAuthority(String authority) {
   return "hasAuthority('" + authority + "')";
  }
  
  private static String hasRole(String role) {
   Assert.notNull(role, "role cannot be null");
   if (role.startsWith("ROLE_")) {
    throw new IllegalArgumentException(
      "role should not start with 'ROLE_' since it is automatically inserted. Got '"
        + role + "'");
   }
   return "hasRole('ROLE_" + role + "')";
  }
  ```

  

  ###  如何对密码进行加密？

  `PasswordEncoder` 接口一共也就 3 个必须实现的方法。

  ```java
  public interface PasswordEncoder {
      // 加密也就是对原始密码进行编码
      String encode(CharSequence var1);
      // 比对原始密码和数据库中保存的密码
      boolean matches(CharSequence var1, String var2);
      // 判断加密密码是否需要再次进行加密，默认返回 false
      default boolean upgradeEncoding(String encodedPassword) {
          return false;
      }
  }
  
  public class BCryptPasswordEncoder implements PasswordEncoder
  ```

  ### 如何优雅更换系统使用的加密算法？

  发现现有的加密算法无法满足我们的需求，需要更换成另外一个加密算法，通过`DelegatingPasswordEncoder` 兼容多种不同的密码加密方案。

  ```java
  String idForEncode = "bcrypt";
  Map  encoders = new HashMap<>();
  encoders.put(idForEncode, new BCryptPasswordEncoder());
  encoders.put("noop", NoOpPasswordEncoder.getInstance());
  encoders.put("pbkdf2", new Pbkdf2PasswordEncoder());
  encoders.put("scrypt", new SCryptPasswordEncoder());
  encoders.put("sha256", new StandardPasswordEncoder());
   
  PasswordEncoder passwordEncoder = new DelegatingPasswordEncoder(idForEncode, encoders);
  // 密码存储格式
  // 密码的一般格式为：
  // {id}encodedPassword
  ```

  ## Spring&SpringBoot常用注解总结