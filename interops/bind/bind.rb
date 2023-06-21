require "js"
def bind(name, func=nil, &block)
  JS.global[:self][name.to_sym] = if func then func else block end
end

def foo()
  puts "Hello Ruby!"
end

def bar()
    puts "Hello JS!"
end

bind("foo") do
  foo
end

bind("bar", &method(:bar)) 
