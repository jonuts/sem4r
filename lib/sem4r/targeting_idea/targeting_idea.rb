# -------------------------------------------------------------------------
# Copyright (c) 2009-2010 Sem4r sem4ruby@gmail.com
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# 
# -------------------------------------------------------------------------

module Sem4r


  class TargetingIdea
    include SoapAttributes

    enum :AttributeTypes, [
      :AdFormatSpecListAttribute,
      :BooleanAttribute,
      :DoubleAttribute,
      :IdeaTypeAttribute,
      :InStreamAdInfoAttribute,
      :IntegerAttribute,
      :IntegerSetAttribute,
      :LongAttribute,
      :MonthlySearchVolumeAttribute,
      :PlacementTypeAttribute,
      :StringAttribute,
      :WebpageDescriptorAttribute,
      :KeywordAttribute,
      :MoneyAttribute,
      :PlacementAttribute,
      :LongRangeAttribute,
      :MonthlySearchVolumeAttribute]

    attr_reader :attributes
    
    def initialize(&block)
      if block_given?
        block.arity < 1 ? instance_eval(&block) : block.call(self)
      end
    end

    def self.from_element(el)
      els = el.xpath("ns2:data", el.namespaces)
      @attributes = els.map do |el|
        el1 = el.xpath("ns2:value", el.namespaces)
        xml_type =       el1.xpath("ns2:Attribute.Type", el.namespaces).text.strip
        case xml_type
        when IdeaTypeAttribute
          TIdeaTypeAttribute.from_element(el1)
        when KeywordAttribute
          TKeywordAttribute.from_element(el1)
        when MonthlySearchVolumeAttribute
          TMonthlySearchVolumeAttribute.from_element(el1)
        end
      end
    end

    def to_s
      @attributes.collect { |attr| attr.to_s }.join("\n")
    end

  end

  class TKeywordAttribute
    include SoapAttributes

    g_accessor :text
    g_accessor :match_type

    def initialize(&block)
      if block_given?
        block.arity < 1 ? instance_eval(&block) : block.call(self)
      end
    end

    def self.from_element( el )
      namespaces = el.document.collect_namespaces
      el1 = el.at_xpath("ns2:value", namespaces)
      new do
        text       el1.at_xpath("xmlns:text", namespaces).text
        match_type el1.at_xpath("xmlns:matchType", namespaces).text
      end
    end

    def to_s
      "Keyword '#{text}' '#{match_type}'"
    end
  end
  
  class TMonthlySearchVolumeAttribute
    include SoapAttributes

    g_accessor :text
    g_accessor :values

    def initialize(&block)
      if block_given?
        block.arity < 1 ? instance_eval(&block) : block.call(self)
      end
    end

    def self.from_element( el )
      historical_values = []
      el.elements.each do |node|
        next if node.name == "Attribute.Type"
        historical_value = { :year => node.xpath("xmlns:year", el.namespaces).text,
                             :month => node.xpath("xmlns:month", el.namespaces).text}
        historical_value.merge!(:count => node.xpath("xmlns:count", el.namespaces).text) if node.xpath("xmlns:count", el.namespaces)
        historical_values << historical_value
      end
      new do
        values historical_values
      end
    end

    def to_s
      "Values: #{values.inspect}"
    end
  end

  class TIdeaTypeAttribute
    include SoapAttributes

    g_accessor :value

    def initialize(&block)
      if block_given?
        block.arity < 1 ? instance_eval(&block) : block.call(self)
      end
    end

    def self.from_element( el )
      new do
        value       el.xpath("ns2:value", el.document.collect_namespaces).text
      end
    end

    def to_s
      "Idea '#{value}'"
    end
  end

end
