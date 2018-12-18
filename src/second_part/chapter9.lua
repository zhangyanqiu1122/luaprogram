---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by zxy.
--- DateTime: 2018/12/17 20:40
---

--[[
在Lua中，函数是严格遵循词法定界的第一类值

“第一类值”意味Lua语言中的函数与其他常见类型的值具有同等权限：
1. 一个程序可以将某个函数保存到变量中或表中
2. 可以将某个函数作为参数传递给其他函数
3. 可以将耨个函数作为其他函数的返回值返回

“词法定界”意味Lua语言中的函数可以访问包含其自身的外部函数中变量（Lua完全支持Lambda演算）
--]]

--？？Lambda演算

--[[
9.1 函数是第一类值
--]]

--第一类值得示例

--[[
a = {p = print}
a.p("Hello World")

print = math.sin
a.p(print(1))

math.sin = a.p
math.sin(10,20)

--]]
function foo(x) return 2*x end  --语法糖
foo = function(x) return 2*x end  --右边的表达式是函数构造器

--Lua语言中，所有的函数都是匿名(anonymous)的。

--[[
像函数sort这样以另一个函数为参数的函数，我们称之为高阶函数。
高阶函数是一种强大的编程机制，而利用匿名函数作为参数正是其灵活性的主要来源。

也可以不用匿名函数
--]]

-- -------------------例子一，排序函数---------------------------------------
network = {
    {name = "grauna", Ip = "210.26.30.34"},
    {name = "arraial",Ip = "210.26.30.23"},
    {name = "lua", Ip = "210.26.23.12"},
    {name = "derain", Ip = "210.26.23.20"},
}

table.sort(network, function(a,b) return (a.name > b.name) end)

for i = 1, #network do
    print(network[i].name, network[i].Ip)
end


-- ------------------例子二，导数，下面这段代码特别不明白----------------------
function derivative(f, delta)
    delta = delta or (1e-4)
    return function(x)
        return (f(x + delta) - f(x))/delta
    end
end

c = derivative(math.sin)
print(math.cos(5.2),c(5.2))
print(math.cos(10), c(10))

--[[
9.2 非全局函数
--]]

--函数不仅可以被存储在全局变量中，还可以被存储在表字段和局部变量中。

-- ------------------示例一--------------------
--第一种
lib = {}
lib.foo = function(x,y) return x * y end
lib.goo = function(x,y) return x - y end
print(lib.foo(2,3), lib.goo(2,3))

--第二种 表构造器
lib1 = {
    foo = function(x,y) return x + y end,
    goo = function(x,y) return x - y end
}

--第三种 特殊的语法定义这类函数
lib2 = {}
function lib2.foo(x,y) return x + y end
function lib2.goo(x,y) return x - y end

--[[
一个函数存储到局部变量中，就得到一个局部函数，一个被限定在指定作用域中使用的函数。
--]]

--局部函数的语法糖
local function f(param)
    --body
end

--扩展，这样递归函数没有问题
local foo;
foo = function(param)
    --body
end

-- ----------------------递归例子----------------------------------
--[[
local fact = function(n)
    if n == 0 then return 1
    else return n * fact(n-1) --有问题
    end
end

--]]

local fact
fact = function(n)
    if n == 0 then return 1
    else return n * fact(n-1)
    end
end

print(fact(10))

--上面的技巧对间接递归函数是无效的，间接递归的情况下，必须使用与明确前向声明等价的形式
local f --"前向"声明
local function g()
    -- some code
    f()
    --some code
end

function f()
    --some code
    g()
    --some code
end

--[[
9.3 语法定界
--]]

--[[
当编写一个被其他函数B包含的函数A时，被包含的函数A可以访问包含其的函数B的所有局部变量，
这种特性称为词法定界。
--]]

-- 示例
-- 第一种
names = {"Peter","Paul","Mary"}
grades = {Mary = 10, Paul = 7, Peter = 8}
table.sort(names, function(n1,n2)
    return grades[n1] > grades[n2]
end)

--[[
第二种 传给函数sort的匿名函数可以访问grades,而grades是包含匿名函数的外层函数sortbygrade的形参。
在匿名函数中，grades既不是全局变量也不是局部变量，而是非全局变量（上值）
--]]
function sortbygrade(names, grades)
    table.sort(names, function(n1,n2)
        return grades[n1] < grades[n2]
    end)
end

sortbygrade(names,grades)

for i = 1, #names do
    print(names[i])
end

--函数作为第一类值，能够逃逸（escape）出它们变量的原始定界范围。
--闭包，一个闭包就是一个函数外加能够使该函数正确访问非全局变量所需的其他机制。
function newCounter()
    local count = 0
    return function()
        count = count + 1
        return count
    end
end

c1 = newCounter()
print(c1())
print(c1())

--[[
Lua语言中只有闭包没有函数，函数本身只是闭包的一种原型。
闭包对于回调（callback）函数来说很有用。
--]]
--示例一 典型的例子 创建按钮
function add_to_display(digit)
    print("add_to_display:"..tostring(digit))
end

function digitButton(digit)
    return {label = tostring(digit),
            action = function()
                add_to_display(digit)
            end
    }
end

Button = digitButton(5)
print(Button.label)
Button.action()

--示例二 预定义函数
--第一种写法
local oldsin = math.sin
math.sin = function(x)
    return oldsin(x * (math.pi / 180))
end

print(math.sin(100))
--第二种写法 do代码段来限制局部变量oldsin的作用范围；根据可见性规则，局部变量oldsin只在这部分代码段中有效。
do
    local oldsin = math.sin
    local k = math.pi / 180
    math.sin = function(x)
        return oldsin(x * k)
    end
    print(math.sin(100))
end

--示例三，创建安全的运行时环境，即所谓的沙盒
do
    local oldOpen = io.open
    local access_OK = function(filename, mode)
        --check access
    end
    io.open = function(filename, mode)
        if access_OK(filename, mode) then
            return oldOpen(filename, mode)
        else
            return nil, "access denied"
        end
    end
end

--[[
9.4 小试函数式编程
--]]

--示例一 定义一个根据指定的圆心和半径创建圆盘的工厂
function disk1(x,y)
    return (x - 1.0)^2 + (y - 3.0)^2 <= 4.5^2
end
--替换为下面函数
function disk(cx, cy ,r)
    return function(x, y)
        return (x - cx)^2 + (y - cy)^2 <= r^2
    end
end
d = disk(1.0, 3.0, 4.5)
print(d(1,2))

--示例二 指定边界的轴对称矩形
function rect(left, right, bottom, up)
    return function(x, y)
        return left <= x and x<= right and bottom <= y and y<= up
    end
end

--示例三 改变和组合区域

function complement(r)
    return function(x, y)
        return not r(x,y)
    end
end

--示例四 区域的并集、交集和差集
function union(r1,r2)
    return function(x,y)
        return r1(x,y) or r2(x,y)
    end
end

function intersection(r1,r2)
    return function(x,y)
        return r1(x,y) and r2(x,y)
    end
end

function difference(r1,r2)
    return function(x,y)
        return r1(x,y) and not r2(x,y)
    end
end

--示例四 按照指定的增量评议指定区域
function translate(r,dx,dy)
    return function(x,y)
        return r(x - dx, y - dy)
    end
end

--示例五 在PBM文件中绘制区域
function plot(r,M,N)
    io.write("P1\n", M, " ", N, "\n")
    for i = 1, N do
        local y = (N - i*2)/N
        for j = 1, M do
           local x = (j*2 - M)/M
            io.write(r(x,y) and "1" or "0
            ")
        end
        io.write("\n")
    end
end

c1 = disk(0,0,1)
plot(difference(c1,translate(c1,0.3,0)),50,50)






