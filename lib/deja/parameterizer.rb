module Deja
  class Parameterizer
    def self.parameterize_query(query)
      query_string = query.to_s
      #NODE CREATE
      if query_string.index("CREATE") == 0
        return parameterize_node_create(query_string)
      #READ
      elsif query_string.index("START") == 0
        #REL CREATE
        return parameterize_rel_create(query_string) if query_string.include?("CREATE")
        #NODE/REL UPDATE
        if query_string.sub(/'[^'\\]*(?:\\.[^'\\]*)*'/, '').sub(/"[^"\\]*(?:\\.[^"\\]*)*"/, '').include?("SET")
          return parameterize_update(query_string)
        end
        #NODE/REL DELETE
        return parameterize_read(query_string)
      else
        return query_string, nil
      end
    end

    def self.num?(str)
      begin
        !!Integer(str)
      rescue ArgumentError, TypeError
        false
      end
    end

    def self.bool?(str)
      str = str.downcase
      str == 'true' || str == 'false' || str == 'null'
    end

    def self.null?(str)
      str == 'NULL'
    end

    def self.join_params(params)
      params.keys.map{|k| "#{k}:{#{k}}"}.join(',')
    end

    def self.extract_start_end(query_string)
      regex = /=(node|relationship|rel)(:[a-zA-Z_]+)?\(([^\)]+)\)/
      start_node, end_node = query_string.scan(regex).map{|arr| arr[2] }

      start_node = start_node.include?('=') ? start_node.split('=')[1] : start_node
      end_node = end_node.include?('=') ? end_node.split('=')[1] : end_node if end_node
      return start_node, end_node
    end

    def self.regex_create_params
      /([^\s{]+)\s:\s(\d+|"(?:[^"\\]|\\.)*"+|'(?:[^'\\]|\\.)*'|true|false|null)/i
    end

    def self.regex_update_params
      /[^\.\s,]+\.([^\s]+)\s=\s(\d+|"(?:[^"\\]|\\.)*"+|'(?:[^'\\]|\\.)*'|true|false|null)/i
    end

    def self.extract_params(query_string, regex)
      # Replace extra escaped single and double quotes with ascii-0.
      query_string_no_escaped_quotes = query_string.gsub(/\\'/, '___CRUNCHBASE_SINGLEQUOTE___').gsub(/\\"/, '___CRUNCHBASE_DOUBLEQUOTE___')
      # This regex was derived from:
      # http://stackoverflow.com/questions/5695240/php-regex-to-ignore-escaped-quotes-within-quotes,
      # which is supposed to handle escaped quotes, but doesn't work
      # quite right.  Theoretically though, we have replaced escaped
      # quotes in the string with ascii-0 chars, which we then put
      # back as regular single quotes below.
      params = Hash[query_string_no_escaped_quotes.scan(regex)]
      params.each do |k, v|
        if num?(v)
          params[k] = v.to_i
        elsif null?(v)
          params[k] = nil
        elsif bool?(v)
          params[k] = (v == 'true')
        else
          # Remove leading and trailing single quotes, and replace the ascii-0's back into single quotes
          params[k] = v[1..-2].gsub('___CRUNCHBASE_SINGLEQUOTE___',"'").gsub('___CRUNCHBASE_DOUBLEQUOTE___', '"')
        end
      end
      return { :data => params }
    end

    def self.extract_update_target(query_string)
      query_string.scan(/SET\s([^\.]+)/).first.first
    end

    def self.join_update_params(target, params)
      params.keys.map{|k| "#{target}.#{k}={#{k}}"}.join(',')
    end

    def self.parameterize_update(query_string)
      target = extract_update_target(query_string)
      start_node, end_node = extract_start_end(query_string)
      first_part = query_string.partition('SET')[0..1].join('')
      first_part.sub!(start_node, '{start_node}')
      last_part = query_string.rpartition('RETURN')[1..2].join('')
      params = extract_params(query_string, regex_update_params)[:data]
      joined_params = join_update_params(target, params)
      params['start_node'] = num?(start_node) ? start_node.to_i : start_node[1..-2]
      if end_node
        first_part.sub!(end_node, '{end_node}')
        params['end_node'] = num?(end_node) ? end_node.to_i : end_node[1..-2]
      end
      return "#{first_part} #{joined_params} #{last_part}", params
    end

    def self.parameterize_read(query_string)
      params = {}
      start_node, end_node = extract_start_end(query_string)
      query_string.sub!(start_node, '{start_node}')
      params['start_node'] = num?(start_node) ? start_node.to_i : start_node[1..-2]
      if end_node
        query_string.sub!(end_node, '{end_node}')
        params['end_node'] = num?(end_node) ? end_node.to_i : end_node[1..-2]
      end
      return query_string, params
    end

    def self.parameterize_node_create(query_string)
      first_part = query_string.partition('{')[0..1].join('')
      last_part = query_string.rpartition('}')[1..2].join('')
      params = extract_params(query_string, regex_create_params)
      return "#{first_part}data#{last_part}", params
    end

    def self.parameterize_rel_create(query_string)
      start_node, end_node = extract_start_end(query_string)
      first_part = query_string.partition('{')[0..1].join('')
      first_part.sub!(start_node, '{start_node}')
      first_part.sub!(end_node, '{end_node}')
      last_part = query_string.rpartition('}')[1..2].join('')
      params = extract_params(query_string, regex_create_params)
      # removes escaped quotes
      params['start_node'] = num?(start_node) ? start_node.to_i : start_node[1..-2]
      params['end_node'] = num?(end_node) ? end_node.to_i : end_node[1..-2]

      return "#{first_part}data#{last_part}", params
    end
  end
end
