require 'yaml'

module Model
  def self.generate(filepath)
    my_array = IO.readlines(filepath)

    className = my_array[0].split(":")[1].lstrip.split(", ")[0]
    # if the spec file is incorrect / contain "\n"
    if my_array[0].split(":")[1].lstrip[-1] == "\n"
      className = className.split("\n")[0]
    end

    attributes = Array.new
    constraints = Array.new

    # Creating attributes and constraints Arrays
    my_array.each do |line|
      line = line.split("\n")[0]
      lineAttr = line.split(" :")[0].lstrip
      param = line.split(":")[1].lstrip.split(", ")

      value = param[1]

      if lineAttr == "title"
        next
      elsif lineAttr == "attribute"
        if Class == (eval "#{value}.class")
          attributes.push(Array[param[0], eval(value)])
        end
      elsif lineAttr == "constraint"
        if String == (eval "#{value}.class")
          constraints.push(Array[param[0], eval(value)])
        end
      end
    end

    # Creating a better constraints Array
    constr = []
    i = 0
    attributes.each do |attr|
      constr << []
      constraints.each do |cons|
        if cons[0] == attr[0]
          constr[i] << cons[1]
        end
      end
      i += 1
    end

    # Create Class className with getters/setters AND constraints awareness
    eval("class #{className}; end ")
    to_eval = String.new
    to_eval << "#{className}.class_eval do; "

    i = 0
    constr.each do |con|
      to_eval << "def #{attributes[i][0]}; if ( "
      con.each do |add_constraint|
        to_eval << "(" << add_constraint.gsub(attributes[i][0], "@#{attributes[i][0]}") << ") and "
      end
      to_eval << "@#{attributes[i][0]}.class == #{attributes[i][1]} ); "
      to_eval << "@#{attributes[i][0]}; else; raise RuntimeError; end; end; "
      to_eval << "def #{attributes[i][0]}=(val); if ( "
      con.each do |add_constraint|
        to_eval << "(" << add_constraint.gsub(attributes[i][0], "val") << ") and "
      end
      to_eval << "val.class == #{attributes[i][1]} ); "
      to_eval << "@#{attributes[i][0]}=(val); else; raise RuntimeError; end; end; "
      i += 1
    end
    to_eval << "end "
    eval to_eval

    ganman = String.new
    ganman << "#{className}.class_eval do; def load_from_file(path); "

    ganman << "f = YAML.load_file(path); t = Array.new; i = 0; f.first[1].each do |fkey|; "
    ganman << "merge = \"t[\" << i.to_s << \"] = #{className}.new\"; eval merge; "
    ganman << "#{attributes}.each do |attr|; if fkey[attr.first]; if attr[1] == String; "
    ganman << "merge = \"t[\" << i.to_s << \"].\" << attr[0] << \" = \\\"\" << fkey[attr.first] << \"\\\"\"; eval merge; else; "
    ganman << "merge = \"t[\" << i.to_s << \"].\" << attr[0] << \" = \" << fkey[attr.first].to_s; eval merge; end; end; end; "
    ganman << "i += 1; end; return t; "
    ganman << "end; end "

    eval ganman

    # What is the correct return value then? A Class. So, eval "#{className}"
    return eval "#{className}.new"
  end

end
