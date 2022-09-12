
* [Learning-Markdown (Markdown 入门参考)](https://xianbai.me/learn-md/index.html) 

# MarkDown test
## what is markdown
## how does it work
## why we need markdown
### this is 
#### faf 
fasf dfa fad 
fasd  
fa  
*斜体文本*  
_斜体文本_  
**粗体文本**  
__粗体文本__  
***粗斜体文本***  
___粗斜体文本___  

# 分隔线

***

* * *

*****

- - -

----------


Try to put a blank line before.

---

and after a horizontal rule.  


RUNOOB.COM  
GOOGLE.COM  
~~BAIDU.COM~~  
<u>带下划线文本</u>  

创建脚注格式类似这样 [^RUNOOB]  


[^RUNOOB]: 菜鸟教程 -- 学的不仅是技术，更是梦想！！！ 

* 第一项
* 第二项
* 第三项

+ 第一项
+ 第二项
+ 第三项


- 第一项
- 第二项
- 第三项

1. 第一项
2. 第二项
3. 第三项

## new 
1. 第一项：
    - 第一项嵌套的第一个元素
    - 第一项嵌套的第二个元素
2. 第二项：
    - 第二项嵌套的第一个元素
    - 第二项嵌套的第二个元素
# 区块
> 区块引用  
> 菜鸟教程  
> 学的不仅是技术更是梦想  

## 区块嵌套
> 最外层  
> > 第一层嵌套  
> > > 第二层嵌套  
## 区块中使用列表
> 区块中使用列表
> 1. 第一项
> 2. 第二项
> + 第一项
> + 第二项
> + 第三项
## 列表中使用区块
* 第一项
    > 菜鸟教程
    > 学的不仅是技术更是梦想
* 第二项
# Markdown 代码
`printf()` 函数  
```javascript
$(document).ready(function () {
    alert('RUNOOB');
});
```
# 链接
这是一个链接 [菜鸟教程](https://www.runoob.com)  
<https://www.runoob.com>  
## 高级链接
这个链接用 1 作为网址变量 [Google][1]  
这个链接用 runoob 作为网址变量 [Runoob][runoob]  
然后在文档的结尾为变量赋值（网址） 

[1]: http://www.google.com/  
[runoob]: http://www.runoob.com/  
# Markdown 图片
![alt 属性文本](图片地址)

![alt 属性文本](图片地址 "可选标题")  
![RUNOOB 图标](http://static.runoob.com/images/runoob-logo.png)

![RUNOOB 图标](http://static.runoob.com/images/runoob-logo.png "RUNOOB")

这个链接用 1 作为网址变量 [RUNOOB][1].  
然后在文档的结尾为变量赋值（网址）  
[1]: http://static.runoob.com/images/runoob-logo.png
<img src="http://static.runoob.com/images/runoob-logo.png" width="100%">  

# Markdown 表格

## 单元格和表头
使用 | 来分隔不同的单元格，使用 - 来分隔表头和其他行:  
为了美观，可以使用空格对齐不同行的单元格，并在左右两侧都使用 | 来标记单元格边界:  
```
|    name    | age |
| ---------- | --- |
| LearnShare |  12 |
| Mike       |  32 |
```
|    name    | age |
| ---------- | --- |
| LearnShare |  12 |
| Mike       |  32 |

>为了使 Markdown 更清晰，| 和 - 两侧需要至少有一个空格（最左侧和最右侧的 | 外就不需要了）。

## 对齐
在表头下方的分隔线标记中加入 :，即可标记下方单元格内容的对齐方式:
>:--- 代表左对齐
:--: 代表居中对齐
---: 代表右对齐

```
| left | center | right |
| :--- | :----: | ----: |
| aaaa | bbbbbb | ccccc |
| a    | b      | c     |
```
| left | center | right |
| :--- | :----: | ----: |
| aaaa | bbbbbb | ccccc |
| a    | b      | c     |
>如果不使用对齐标记，单元格中的内容默认左对齐；表头单元格中的内容会一直居中对齐（不同的实现可能会有不同表现）。

## 插入其他内容
表格中可以插入其他 Markdown 中的行内标记：
```
|     name     | age |             blog                |
| ------------ | --- | ------------------------------- |
| _LearnShare_ |  12 | [LearnShare](http://xianbai.me) |
| __Mike__     |  32 | [Mike](http://mike.me)          |
```
|     name     | age |             blog                |
| ------------ | --- | ------------------------------- |
| _LearnShare_ |  12 | [LearnShare](http://xianbai.me) |
| __Mike__     |  32 | [Mike](http://mike.me)          |


# Markdown 高级技巧
## 支持的 HTML 元素  
使用 <kbd>Ctrl</kbd>+<kbd>Alt</kbd>+<kbd>Del</kbd> 重启电脑  

## 转义  
>**文本加粗**  
>\*\* 正常显示星号 \*\*  

Markdown 支持以下这些符号前面加上反斜杠来帮助插入普通的符号：  
> \\   反斜线  
> \`   反引号  
> \*   星号  
> \_   下划线  
> \{}  花括号  
> \[]  方括号  
> \()  小括号  
> \#   井字号  
> \+   加号  
> \-   减号  
> \.   英文句点  
> \!   感叹号  

## 公式
>\$...\$ 或者 \(...\) 中的数学表达式将会在行内显示。  
>\$\$...\$\$ 或者 \[...\] 或者 ```math 中的数学表达式将会在块内显示。  

$$
\begin{Bmatrix}
   a & b \\
   c & d
\end{Bmatrix}
$$
$$
\begin{CD}
   A @>a>> B \\
@VbVV @AAcA \\
   C @= D
\end{CD}
$$

## 笔记
1. 横向流程图源码格式：
```mermaid
graph LR
A[方形] -->B(圆角)
    B --> C{条件a}
    C -->|a=1| D[结果1]
    C -->|a=2| E[结果2]
    F[横向流程图]
```

2. 竖向流程图源码格式
```mermaid
graph TD
A[方形] --> B(圆角)
    B --> C{条件a}
    C --> |a=1| D[结果1]
    C --> |a=2| E[结果2]
    F[竖向流程图]
```
3. 标准流程图源码格式
```flow
st=>start: 开始框
op=>operation: 处理框
cond=>condition: 判断框(是或否?)
sub1=>subroutine: 子流程
io=>inputoutput: 输入输出框
e=>end: 结束框
st->op->cond
cond(yes)->io->e
cond(no)->sub1(right)->op
```
4. 标准流程图源码格式（横向）
```flow
st=>start: 开始框
op=>operation: 处理框
cond=>condition: 判断框(是或否?)
sub1=>subroutine: 子流程
io=>inputoutput: 输入输出框
e=>end: 结束框
st(right)->op(right)->cond
cond(yes)->io(bottom)->e
cond(no)->sub1(right)->op
```
5. UML时序图源码样例
```sequence
对象A->对象B: 对象B你好吗?（请求）
Note right of 对象B: 对象B的描述
Note left of 对象A: 对象A的描述(提示)
对象B-->对象A: 我很好(响应)
对象A->对象B: 你真的好吗？
```
6. UML时序图源码复杂样例
```sequence
Title: 标题：复杂使用
对象A->对象B: 对象B你好吗?（请求）
Note right of 对象B: 对象B的描述
Note left of 对象A: 对象A的描述(提示)
对象B-->对象A: 我很好(响应)
对象B->小三: 你好吗
小三-->>对象A: 对象B找我了
对象A->对象B: 你真的好吗？
Note over 小三,对象B: 我们是朋友
participant C
Note right of C: 没人陪我玩
```
7. UML标准时序图样例
```mermaid
%% 时序图例子,-> 直线，-->虚线，->>实线箭头
  sequenceDiagram
    participant 张三
    participant 李四
    张三->王五: 王五你好吗？
    loop 健康检查
        王五->王五: 与疾病战斗
    end
    Note right of 王五: 合理 食物 <br/>看医生...
    李四-->>张三: 很好!
    王五->李四: 你怎么样?
    李四-->王五: 很好!
```
8. 甘特图样例
```mermaid
%% 语法示例
        gantt
        dateFormat  YYYY-MM-DD
        title 软件开发甘特图
        section 设计
        需求                      :done,    des1, 2014-01-06,2014-01-08
        原型                      :active,  des2, 2014-01-09, 3d
        UI设计                     :         des3, after des2, 5d
    未来任务                     :         des4, after des3, 5d
        section 开发
        学习准备理解需求                      :crit, done, 2014-01-06,24h
        设计框架                             :crit, done, after des2, 2d
        开发                                 :crit, active, 3d
        未来任务                              :crit, 5d
        耍                                   :2d
        section 测试
        功能测试                              :active, a1, after des3, 3d
        压力测试                               :after a1  , 20h
        测试报告                               : 48h
```
