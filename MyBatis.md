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

 在`CGLIB` 创建目标对象的代理对象的invoke中、如果**需要的字段**B为null，才会查询B并set。

### MyBatis 的 xml 映射文件中，不同的 xml 映射文件，id 是否可以重复？

- 不同namespace，可以重复， `namespace+id `被视为真正的key

  - `Map<String, MappedStatement>` 

    - key: namespace+id

    



### MyBatis 都有哪些 Executor 执行器？它们之间的区别是什么？

- **`SimpleExecutor`** 简单：每执行一次 update 或 select，就开启一个 Statement 对象，用完立刻关闭 Statement 对象。
- **`ReuseExecutor`** **复用Statement**：执行 update 或 select，以 sql 作为 key 查找 Statement 对象，存在就使用，不存在就创建，用完后，**不关闭 Statement 对象**，而是放置于 Map<String, Statement>内，**供下一次使用**。简言之，就是**重复使用 Statement 对象**。
- **`BatchExecutor`** **多个Statement**：将所有 sql 都添加到批处理中（addBatch()），等待统一执行（executeBatch()），它缓存了多个 Statement 对象，每个 Statement 对象都是 addBatch()完毕后，等待逐一执行 executeBatch()批处理。与 JDBC 批处理相同。

###  MyBatis 中如何执行批处理？

-  使用 `BatchExecutor` 完成批处理

### MyBatis 是否可以映射 Enum 枚举类？
