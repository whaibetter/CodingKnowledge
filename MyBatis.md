# Mybatis

[MyBatis常见面试题总结 | JavaGuide(Java面试 + 学习指南)](https://javaguide.cn/system-design/framework/mybatis/mybatis-interview.html#dao-接口的工作原理是什么-dao-接口里的方法-参数不同时-方法能重载吗)

[java - Mybatis系列全解（八）：Mybatis的9大动态SQL标签你知道几个？提前致女神！ - 框架系列全解 - SegmentFault 思否](https://segmentfault.com/a/1190000039335704)

### \#{}和${}在mybatis的区别

1. `${}`：属性引用，==直接使用具体的值  文本替换==
2. `#{}`：引用的是参数的==包装对象==。

使用场景：

- `#{}` **用户输入**，防止SQL注入。**复杂对象或者是一个集合时**。

  ```sql
  SELECT * FROM user WHERE name = #{username}
  # 在这个例子中，MyBatis会使用预编译的方式处理 #{username}，这可以防止SQL注入攻击。无论 User 对象的 username 属性的值是什么，MyBatis都会将其安全地转义，以防止SQL注入。
  ```

- `${}`的优点是**灵活性高**

  > - 如下是一个使用`${}`，动态排序的功能
  >
  > ```xml
  > <select id="findByDynamicSort" resultType="User">
  >   SELECT * FROM user
  >   WHERE 1=1
  >     <trim prefix="AND " prefixOverrides="AND "/>
  >     <if test="sort != null">
  >       ORDER BY ${sort}
  >     </if>
  > </select>
  > <!-- order by -age  -->
  > ```
  >
  >  如果 `sort= -age`，那么等价于 `ORDER BY`

###  xml 映射文件中，除了常见的 select、insert、update、delete 标签之外，还有哪些标签？

- `<resultMap>`、 `<parameterMap>`、 `<sql>片段标签`、 `<include>引入<sql>`、 `<selectKey>为不支持自增的主键生成策略标签`

- `<trim|where|set|foreach|if|choose|when|otherwise|bind>`

### Dao 接口的工作原理是什么？Dao 接口里的方法，参数不同时，方法能重载吗？

- `interface Mapper`'
- `<mapper namespace="com.whai.blog.mapper.BlogBrowseMapper">`

重载通过使用动态sql实现

```java
List<Student> getAllStu();
List<Student> getAllStu(@Param("id") Integer id);
```

```xml
<select id="getAllStu" resultType="com.pojo.Student">
  select * from student
  <where>
    <if test="id != null">
      id = #{id}
    </if>
  </where>
</select>
```

- Mybatis的XML里面的ID不允许重复，namespace+id为真实id



### MyBatis 是如何进行分页的？分页插件的原理是什么？

- 分页 使用 Limit **物理分页**
- 分页 使用 RowBound **逻辑分页，内存分页**
- 分页 使用 插件Interceptor拦截器

1. RowBounds **逻辑分页**：将所有符合条件的加载到内存再筛选

```java
List<BlogMain> getBlogPages(RowBounds rowBounds);
```

```java
List<BlogMain> blogPages = blogMainMapper.getBlogPages(new RowBounds(0, 3));
```

2. 插件 （PageHelper）及（MyBaits-Plus、tkmybatis）都是Interceptor拦截器分页

- Interceptor拦截器实现分页

> 答：**(1)** MyBatis 使用 RowBounds 对象进行分页，它是针对 ResultSet 结果集执行的内存分页，而非物理分页；**(2)** 可以在 sql 内直接书写带有物理分页的参数来完成物理分页功能，**(3)** 也可以使用分页插件来完成物理分页。
>
> 分页插件的基本原理是使用 MyBatis 提供的插件接口，实现自定义插件，在插件的拦截方法内拦截待执行的 sql，然后重写 sql，根据 dialect 方言，添加对应的物理分页语句和物理分页参数。
>
> 举例：`select _ from student` ，拦截 sql 后重写为：`select t._ from （select * from student）t limit 0，10`

### MyBatis 动态 sql 是做什么的？都有哪些动态 sql？能简述一下动态 sql 的执行原理不？

- 以**标签的形式**编写动态 sql，完成**逻辑判断和动态拼接 sql** 的功能

> - `<if></if>`
> - `<where></where>(trim,set)`
> - `<choose></choose>（when, otherwise）`
> - `<foreach></foreach>`
> - `<bind/>`

### MyBatis 是如何将 sql 执行结果封装为目标对象并返回的？都有哪些映射形式？

1. 使用 `<resultMap>` 标签映射返回
2. sql 列的别名功能 `select user_name as name`

有了列名与属性名的映射关系后，MyBatis 通过反射创建对象，同时使用反射给对象的属性逐一赋值并返回



### MyBatis 是否支持延迟加载？如果支持，它的实现原理是什么？

延迟加载的基本原理：**需要的时候才去单独调用事先保存好的sql**

 在`CGLIB` **创建目标对象的代理对象**的invoke中、如果**需要的字段**B为null，才会查询B并set。

- MyBatis 会将关联查询的操作**推迟到实际需要使用数据时**才执行

> Mybatis 仅支持`  association ` 关联对象和`  collection`  关联集合对象的延迟加载
>
> - ` association ` 指的就是一对一，
> - ` collection ` 指的就是一对多查询。
>
> 在 Mybatis配置文件中，可以配置是否启用延迟加载` lazyLoadingEnabled=true|false` 。
>
> 它的原理是，使用 CGLIB 创建目标对象的代理对象，当调用目标方法时，进入拦截器方法
>
> 比如调用 a.getB().getName()，拦截器 **invoke()方法发现 a.getB()是null 值**，那么就会单独发送事先保存好的查询关联 B 对象的 sql，**把 B 查询上来**，然后调用 a.setB(b)，于是 a 的对象 b 属性就有值了，接着完成 a.getB().getName()方法的调用。这就是延迟加载的基本原理。
> 当然了，不光是 Mybatis，几乎所有的包括 Hibernate，支持延迟加载的原理都
> 是一样的。

> ```XML
> <resultMap id="userMap" type="com.example.model.User">
>     <id column="id" property="id"/>
>     <result column="username" property="username"/>
>     <result column="password" property="password"/>
>     //配置延迟加载方式为lazy
>     <collection property="orderList" ofType="com.example.model.Order" select="getOrderListByUserId"
>                 fetchType="lazy"/>
>     //配置延迟加载方式为eager
>     <collection property="accountList" ofType="com.example.model.Account" select="getAccountListByUserId"
>                 fetchType="eager"/>
> </resultMap>
> ```
>
> 只有在需要使用orderList的时候才会再去查询order
>
> - 避免了表连接，但可能需要频繁进行查询

### MyBatis 的 xml 映射文件中，不同的 xml 映射文件，id 是否可以重复？

- 不同namespace，可以重复， `namespace+id `被视为真正的key

  - `Map<String, MappedStatement>` 

    - key: namespace+id


### 简述 MyBatis 的插件运行原理，以及如何编写一个插件

- MyBatis 使用 **JDK 的动态代理**，为需要**拦截的接口生成代理对象**以实现接口方法拦截功能。
  - 就是 `InvocationHandler` 的 `invoke()` 方法

> 如何编写一个插件：
>
> 1. **实现 Plugin 接口**: 你需要创建一个类，然后让这个类实现 `org.apache.ibatis.plugin.Plugin` 接口。
> 2. **覆盖 intercept 方法**: 在你的插件类中，你需要覆盖 ` Interceptor` 接口的 `intercept` 方法。在这个方法中，你可以修改传入的 `Invocation` 对象中的方法参数。
> 3. **设置插件**: 你需要在 MyBatis 的配置文件中添加你的插件类，或者在你的代码中使用 `SqlSessionFactoryBuilder` 的 `addPlugin` 方法来添加你的插件。

[配置_MyBatis中文网](https://mybatis.net.cn/configuration.html#plugins)



### MyBatis 都有哪些 Executor 执行器？它们之间的区别是什么？

- **`SimpleExecutor`** 简单：每执行一次 update 或 select，就开启一个 Statement 对象，用完立刻关闭 Statement 对象。
- **`ReuseExecutor`** **复用Statement**：执行 update 或 select，以 sql 作为 key 查找 Statement 对象，存在就使用，不存在就创建，用完后，**不关闭 Statement 对象**，而是放置于 Map<String, Statement>内，**供下一次使用**。简言之，就是**重复使用 Statement 对象**。
- **`BatchExecutor`** **多个Statement**：将所有 sql 都添加到批处理中（addBatch()），等待统一执行（executeBatch()），它缓存了多个 Statement 对象，每个 Statement 对象都是 addBatch()完毕后，等待逐一执行 executeBatch()批处理。与 JDBC 批处理相同。

###  MyBatis 中如何执行批处理？

-  使用 `BatchExecutor` 完成批处理

### MyBatis 是否可以映射 Enum 枚举类？

- 可以
- 自定义一个 `TypeHandler` ，实现 `TypeHandler` 的 `setParameter()` 和 `getResult()` 接口方法
  -  javaType 至 jdbcType 的转换
  -  jdbcType 至 javaType 的转换
