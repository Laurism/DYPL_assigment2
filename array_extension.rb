class Array
	def select_first(cond) #cond = Items to select by
		if cond.size > 1
			self.each do |item|
				if item.send(cond[:name]) <= cond[:interval][:max]
					if cond[:interval].size > 1
						return item if item.send(cond[:name]) >= cond[:interval][:min]
					else
						return item
					end
				end
			end
		else
			att = cond.to_a # Attribute and it's value(s)
			if not att[0][1].kind_of? Array
				att[0][1] = [att[0][1]] ###########
			end
			self.each do |item|
				att[0][1].each do |value|
					return item if item.send(att[0][0]) == value
				end
			end
		end
	end
	def select_all(cond) #cond = Items to select by
		list = Array.new
		if cond.size > 1
			self.each do |item|
				if item.send(cond[:name]) <= cond[:interval][:max]
					if cond[:interval].size > 1
						list.push item if item.send(cond[:name]) >= cond[:interval][:min]
					else
						list.push item
					end
				end
			end
		else
			att = cond.to_a # Attribute and it's value(s)
			if not att[0][1].kind_of? Array
				att[0][1] = [att[0][1]] ###########
			end
			self.each do |item|
				att[0][1].each do |value|
					list.push item if item.send(att[0][0]) == value
				end
			end
		end
		list
	end
	def method_missing(mName, *args, &block)
		if mName.to_s =~ %r{select_first_where_(.*)_is$}
			eval "
				def self.#{mName}(#{$1})
					select_first(:#{$1} => #{$1})
				end
			"
		elsif mName.to_s =~ %r{select_first_where_(.*)_is_in$}
			eval "
				def self.#{mName}(#{$1})
					select_first(:name => :#{$1}, :interval => {:min => #{args[0]}, :max => #{args[1]}})
				end
			"
		elsif mName.to_s =~ %r{select_all_where_(.*)_is$}
			eval "
				def self.#{mName}(#{$1})
					select_all(:#{$1} => #{$1})
				end
			"
		elsif mName.to_s =~ %r{select_all_where_(.*)_is_in$}
			eval "
				def self.#{mName}(#{$1})
					select_all(:name => :#{$1}, :interval => {:min => #{args[0]}, :max => #{args[1]}})
				end
			"
		else 
		   super
		end	
		send(mName, args)   
	end
end
