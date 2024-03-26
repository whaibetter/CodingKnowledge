> [京东后端](https://mp.weixin.qq.com/s/CdlsLN-qys3sJLBM8GDK7g)
>
> - ArrayList 和 LinkedList 的时间复杂度
> - HashSet 和 ArrayList 的区别
> - HashSet 怎么判断元素重复，重复了是否 put
> - hashcode 和 equals 方法只重写一个行不行，只重写 equals 没重写 hashcode，map put 的时候会发生什么
> - 有了解 JVM 吗
> - 堆和栈的区别是什么
> - 垃圾回收器的作用是什么
> - 什么是内存泄露
> - Java 编译时异常和运行时异常的区别
> - return 先执行还是 finally 先执行
> - 事务的四个特性，怎么理解事务一致性
> - JDBC 的执行步骤
> - 创建连接拿到的是什么对象
> - statement 和 preparedstatement 的区别
> - select 语句的执行顺序
> - Spring 事务怎么实现的
> - 事务的传播机制
> - 查询和更新都频繁的字段是否适合创建索引，为什么
> - 联合索引 abc，a=1,c=1/b=1,c=1/a=1,c=1,b=1走不走索引

###  ArrayList 和 LinkedList 的时间复杂度

- 随机访问：ArrayList O1，LinkedList On
-  `get(E element) `都是On
- 插入、删除  ArrayList On 但需要移动元素 LinkedList也是On但不用移动元素
  - ArrayList尾插、尾删除O1
  - LinkedList头插、头删除O1

###  HashSet 和 ArrayList 的区别？HashSet 怎么判断元素重复，重复了是否 put？

- 一个属于Set、一个属于List

- 都来自Collection

- ArrayList是数组实现（保持插入顺序）、HashSet是基于HashMap实现（顺序不确定）

  - HashSet 保证每个元素唯一，不允许重复元素，基于元素的 **hashCode 和 equals 方法**来确定元素的唯一性。

    ```java
    public boolean contains(Object o) {
        return map.containsKey(o);
    }
    ```

    ```java
    static final Object PRESENT = new Object();
    public boolean add(E e) {
        return map.put(e, PRESENT)==null;
    }
    // 调用HashMap的put方法
    ```

- put的过程

  第一步，通过 hash 方法计算 key 的哈希值。

  第二步，数组进行第一次扩容。

  第三步，根据哈希值计算 key 在数组中的下标，如果对应下标正好没有存放数据，则直接插入。

  - 如果对应下标已经有数据了，返回该数据

    `return map.put(e, PRESENT)==null;` 



###  hashcode 和 equals 方法只重写一个行不行，只重写 equals 没重写 hashcode，map put 的时候会发生什么

- 重写equal表示两个对象是一样的，如果不重写hashcode会将两个对象**映射到不同的集合中**

###  有了解 JVM 吗

###  堆和栈的区别是什么
###  垃圾回收器的作用是什么



###  什么是内存泄露？内存溢出？对应的场景有哪些？

- **内存溢出**（Out Of Memory）：就是申请内存时，JVM 没有足够的内存空间。通俗说法就是去蹲坑发现坑位满了。
  - 堆内存溢出：大对象、内存泄露
  - 栈内存溢出：递归
  - 方法区溢出：创建大量类、动态代理生成类
- **内存泄露**（Memory Leak）：就是申请了内存，但是没有释放，导致内存空间浪费。通俗说法就是有人占着茅坑不拉屎。**无法释放不用的内存**
  - 对象引用无法及时释放
  - 资源没有close释放
  - 循环引用

###  Java 编译时异常和运行时异常的区别

![图片](http://42.192.130.83:9000/picgo/imgs/640)

- Throwable
  - Error
  - Exception

编译时异常（Checked Exception）SQLExceptin IOException

- 在编译时必须被**显式处理**（捕获或声明抛出）

运行时异常（Runtime Exception）NullPointerException、IndexOutOfBoundsException 

- Java 编译器不要求必须处理它们（即不需要捕获也不需要声明抛出）。

###  return 先执行还是 finally 先执行

```awk
0: iconst_1         // 将常量值 1 压入栈顶
   1: istore_1         // 将栈顶的值存储到局部变量表的索引为 1 的位置
   2: iconst_2         // 将常量值 2 压入栈顶
   3: ireturn          // 从方法中返回栈顶的整数值

   4: astore_1         // 将栈顶的引用类型值存储到局部变量表的索引为 1 的位置
   5: iconst_2         // 将常量值 2 压入栈顶
   6: ireturn          // 从方法中返回栈顶的整数值

   7: astore_2         // 将栈顶的引用类型值存储到局部变量表的索引为 2 的位置
   8: iconst_2         // 将常量值 2 压入栈顶
   9: ireturn          // 从方法中返回栈顶的整数值
```

```java
public int tryTest() {

    try {
        return 1;
    } catch (Exception e) {

    }finally {
        return 2;
    }
}
```

###  事务的四个特性，怎么理解事务一致性

ACID

- Auto 原子性 要么都发生要么都不发生，事务；转账的过程不能只完成一部分 

- Consistency 一致性，转账前后AB的总额一定是一样的；

- Isolation 隔离性，一个事务不会干扰其他事务。隔离性主要是为了解决事务并发的**脏读、不可重复读、幻读**等。

  数据库系统通过事务隔离级别（如读未提交、读已提交、可重复读、串行化）来实现事务的隔离性。

- Duration 持久性

  事务一旦提交，它对数据库所做的**更改就是永久性的**。

  通过数据库的**恢复和日志**机制来实现的，确保提交的**事务更改不会丢失**。

###  JDBC 的执行步骤

驱动-连接-Stat-执行-Res-Close

#### 1. 加载数据库驱动

`Class.forName("com.mysql.cj.jdbc.Driver");`

#### 2. 建立数据库连接

`Connection conn = DriverManager.getConnection(
  "jdbc:mysql://localhost:3306/databaseName", "username", "password");`

#### 3. 创建`Statement`对象

`Statement stmt = conn.createStatement();`

`PreparedStatement pstmt = conn.prepareStatement("SELECT * FROM tableName WHERE column = ?"); //预编译 SQL 语句`
pstmt.setString(1, "value");

#### 4. 执行 SQL 语句

`ResultSet rs = stmt.executeQuery("SELECT * FROM tableName");`

#### 5. 处理结果集

`while (rs.next()) {
  String data = rs.getString("columnName");
  *// 处理每一行数据*
}`

#### 6. 关闭资源

`if (rs != null) rs.close();
if (stmt != null) stmt.close();
if (conn != null) conn.close();`

在 Java 开发中，通常会使用 JDBC 模板库（如 Spring 的 JdbcTemplate）或 ORM 框架（如 Hibernate、MyBatis、MyBatis-Plus）来简化数据库操作和资源管理。

###  创建连接拿到的是什么对象

在 JDBC 的执行步骤中，创建连接后拿到的对象是`java.sql.Connection`对象。

`Connection`对象代表了应用程序和数据库的一个连接会话。

一旦获得`Connection`对象，就可以使用它来创建执行 SQL 语句的`Statement`、`PreparedStatement`和`CallableStatement`对象，以及管理事务等。



###  statement 和 preparedstatement 的区别

#### 1. 预编译 每次执行Statement是否要重新编译执行

**Statement**：每次执行`Statement`对象的`executeQuery`或`executeUpdate`方法时，SQL 语句在数据库端都需要重新编译和执行。这适用于一次性执行的 SQL 语句。

**PreparedStatement**：代表预编译的 SQL 语句的对象。这意味着 SQL 语句在`PreparedStatement`**对象创建时就被发送到数据库进行预编译**。

#### 2. 参数化查询

- **PreparedStatement**：支持参数化查询，即可以在 SQL 语句中使用问号（?）作为参数占位符。通过`setXxx`方法（如`setString`、`setInt`）设置参数，可以**有效防止 SQL 注入**。



###  以下select 语句的执行顺序

```sql
SELECT DISTINCT t1.column1, t2.column2
FROM table1 t1
JOIN table2 t2 ON t1.id = t2.id
WHERE t1.column3 = 'value'
GROUP BY t1.column1, t2.column2
HAVING COUNT(*) > 1
ORDER BY t1.column1
LIMIT 10;
```

1. from on join
2. where
3. groub by
4. having
5. **select DISTINCT**
6. orderby
7. top limit



###  Spring 事务怎么实现的

> Spring事务有两种：
>
> ### 声明式事务
>
> 1. 在 Bean 初始化阶段**创建代理对象**，获取属性切面 `@Transactional` 注解及其属性值
> 2. 通过代理调用，触发AOP拦截；`TransactionInterceptor extend  MethodInterceptor` ，调用父类`invokeWithinTransaction`方法进行开启事务、事务提交、异常回滚等。
>
> ### 编程式事务
>
> 使用 TransactionTemplate 、PlatformTransactionManager 显式声明事务，手动提交、回滚。

声明式事务管理

> 声明式事务是建立在 **AOP** 之上的。
>
> 通过 AOP 功能，对方法前后进行拦截，将事务处理的功能编织到拦截的方法中，也就是在**目标方法开始之前启动一个事务**，**在目标方法执行完之后根据执行情况提交或者回滚事务**。
>
> 1. **在 Bean 初始化阶段创建代理对象**：初始化单例 Bean 的时候，会遍历所有的 BeanPostProcessor 实现类，并执行其 postProcessAfterInitialization 方法。**获取事务的属性切面 `@Transactional` 注解及其属性值**。
>
>    根据得到的切面创建一个代理对象JDK or Cglib
>
> 2. 通过**代理对象调用 Bean 方法**的时候，会触发对应的 AOP 增强拦截
>
>    声明式事务是一种环绕增强，对应接口为`MethodInterceptor`，事务增强对该接口的实现为`TransactionInterceptor`
>
> 
>
> 声明式事务管理最细粒度只能作用到方法级别
>
> ```java
> org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory#applyBeanPostProcessorsAfterInitialization
> @Deprecated(since = "6.1")
> @Override
> public Object applyBeanPostProcessorsAfterInitialization(Object existingBean, String beanName)
>       throws BeansException {
> 
>    Object result = existingBean;
>    for (BeanPostProcessor processor : getBeanPostProcessors()) {
>       Object current = processor.postProcessAfterInitialization(result, beanName);
>       if (current == null) {
>          return result;
>       }
>       result = current;
>    }
>    return result;
> }
> 
> org.springframework.transaction.interceptor.AbstractFallbackTransactionAttributeSource#computeTransactionAttribute
> @Nullable
> protected TransactionAttribute computeTransactionAttribute(Method method, @Nullable Class<?> targetClass) {
>    // Don't allow non-public methods, as configured.
>    if (allowPublicMethodsOnly() && !Modifier.isPublic(method.getModifiers())) {
>       return null;
>    }
> 
>    // The method may be on an interface, but we need attributes from the target class.
>    // If the target class is null, the method will be unchanged.
>    Method specificMethod = AopUtils.getMostSpecificMethod(method, targetClass);
> 
>    // First try is the method in the target class.
>    TransactionAttribute txAttr = findTransactionAttribute(specificMethod);
>    if (txAttr != null) {
>       return txAttr;
>    }
> ```
>
> 默认使用 JDK 动态代理创建代理，如果目标类是接口，则使用 JDK 动态代理，否则使用 Cglib
>
> ### 事务拦截器
>
> ```java
> /**
>  * 调用目标方法时的拦截处理。
>  * <p>此方法主要负责在交易环境中调用目标方法。它首先确定目标类，然后通过
>  * {@code invokeWithinTransaction} 方法在事务环境中执行实际的方法调用。
>  *
>  * @param invocation 方法调用的详细信息，包括调用的方法、目标对象等。
>  * @return 方法的返回值，可能会是任何类型。
>  * @throws Throwable 如果在方法执行过程中发生异常。
>  */
> @Override
> @Nullable
> public Object invoke(MethodInvocation invocation) throws Throwable {
> 	// 确定目标类，如果目标对象不为空，则获取其真实类，否则为null。
> 	// 这个信息对于确定事务属性是必要的。
> 	Class<?> targetClass = (invocation.getThis() != null ? AopUtils.getTargetClass(invocation.getThis()) : null);
> 
> 	// 在事务环境中调用目标方法 包括开启事务、事务提交、异常回滚
> 	return invokeWithinTransaction(invocation.getMethod(), targetClass, new CoroutinesInvocationCallback() {
> 		@Override
> 		@Nullable
> 		public Object proceedWithInvocation() throws Throwable {
> 			// 执行实际的方法调用
> 			return invocation.proceed();
> 		}
> 		@Override
> 		public Object getTarget() {
> 			// 获取目标对象
> 			return invocation.getThis();
> 		}
> 		@Override
> 		public Object[] getArguments() {
> 			// 获取方法参数数组
> 			return invocation.getArguments();
> 		}
> 	});
> }
> ```

- @Transactional

> Spring 框架中，事务管理相关最重要的 3 个接口如下：
>
> - **`PlatformTransactionManager`**：（平台）事务**管理器**，Spring 事务策略的核心。
> - 描述：
>   - **`TransactionDefinition`**：事务定义信息(事务隔离级别、传播行为、超时、只读、回滚规则)。
>   - **`TransactionStatus`**：事务运行状态。
>
> ------
>
> - 隔离级别
> - 传播行为
> - 回滚规则
> - 是否只读
> - 事务超时

编程式事务管理

- TransactionTemplate 
- PlatformTransactionManager 

```java
@Autowired
private TransactionTemplate transactionTemplate;
public void testTransaction() {

        transactionTemplate.execute(new TransactionCallbackWithoutResult() {
            @Override
            protected void doInTransactionWithoutResult(TransactionStatus transactionStatus) {

                try {

                    // ....  业务代码
                } catch (Exception e){
                    //回滚
                    transactionStatus.setRollbackOnly();
                }

            }
        });
}
```

```java
@Autowired
private PlatformTransactionManager transactionManager;

public void testTransaction() {

  TransactionStatus status = transactionManager.getTransaction(new DefaultTransactionDefinition());
          try {
               // ....  业务代码
              transactionManager.commit(status);
          } catch (Exception e) {
              transactionManager.rollback(status);
          }
}
```



###  事务的传播机制

7种传播机制

【外部事务，内部事务】

1. Required 没有事务创建、**有事务就加入** 
2. Support 只**支持**当前事务，没有就不事务 
3. Mandatory  **强制**当前事务，没有就报错
4. Required_new 新建事务，存在的事务会挂起
5. Not_Supported 不支持事务，有事务会异常
6. Nested 嵌套一个子事务

![image-20240325122709601](http://42.192.130.83:9000/picgo/imgs/image-20240325122709601.png)

###  查询和更新都频繁的字段是否适合创建索引，为什么

索引提供了快速查找的方式，数据访问的时间复杂度从O(n)降低到了O(log n)。

但修改数据同时要修改索引，导致B+树的分裂、旋转

### 联合索引 abc，a=1,c=1/b=1,c=1/a=1,c=1,b=1走不走索引

half 表明 a=1,c=1 会使用联合索引。但因为缺少了 B 字段的条件

false  不会使用联合索引

true
