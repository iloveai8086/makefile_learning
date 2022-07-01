# 检索src目录下面的CPP后缀文件，用shell 的find
srcs := $(shell find src -name "*.cpp")

# 将src的后缀的.cpp替换为.o  解决了多级目录的查找问题
objs := $(srcs:.cpp=.o)

# 将src/前缀替换为 objs/前缀
objs := $(objs:src/%=objs/%)

debug:
	@echo objs is[$(objs)]

include_paths := /media/ros/A666B94D66B91F4D/ros/make/lean/curl7.78.0/include /media/ros/A666B94D66B91F4D/ros/make/lean/openssl-1.1.1j/include

library_paths := /media/ros/A666B94D66B91F4D/ros/make/lean/curl7.78.0/lib /media/ros/A666B94D66B91F4D/ros/make/lean/openssl-1.1.1j/lib

ld_librarys :=curl ssl crypto

run_paths := $(library_paths:%=-Wl,-rpath=%)
# 增加run_paths变量，语法是 g++ main.o test.o -o out.bin -Wl,rpath=/xxx/openssl/lib
# run_path 就是运行时的so的查找路径，通过这个变量避免运行时候找不到so，也避免把so复制到workspace 的目录
# 把每一个头文件路径的前面加上-I，库文件路径前面加上-L，链接前面加上-l
include_paths := $(include_paths:%=-I%)     # 头文件
library_paths := $(library_paths:%=-L%)
ld_librarys := $(ld_librarys:%=-l%)       # 链接
# 使用$(var:source=dest)的语法，将每个路径前面加上特定的符号，变为g++指令需要的
# -i是配置头文件的路径  -L配置库的路径   -l是配置依赖的so

$(info $(run_paths))

compile_flags := -std=c++11 -w -g -O0 $(include_paths)
# 增加compile flgs，增加编译选项，例如使用C++11的特性，-w避免警告 -g生成调试信息 -O0优化级别关闭
link_flags := $(library_paths) $(ld_librarys) $(run_paths)

objs/%.o : src/%.cpp
	@echo 编译$< 生成$@,目录: $(dir $@)   $@
	@mkdir -p $(dir $@)
	g++ -c $< -o $@ $(compile_flags)    #把编译选项增加到g++后面

workspace/pro : $(objs)
	@echo 这里的所有的依赖项是[$^]
	@echo link$@
	g++ $^ -o $@ $(link_flags)

# 定义简洁指令，make pro即可生成程序
pro : workspace/pro
	@echo 编译完成

# 定义make run 编译好直接执行
run : pro
	@cd workspace && ./pro

# 定义make clean,清理垃圾
clean:
	@rm -rf workspace/pro objs

# 定义伪符号，这些符号就不被看成文件了
.PHONY : pro run debug clean




