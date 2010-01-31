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
  class AdgroupTextAd < AdgroupAd

    def initialize(adgroup, &block)
      super( adgroup )
      self.type = TextAd
      if block_given?
        instance_eval(&block)
        save
      end
    end

    def to_s
      "#{@id} textad #{@textad[:url]}"
    end

    def to_xml
      <<-EOFS
        <adGroupId>#{adgroup.id}</adGroupId>
        <ad xsi:type="TextAd">
          <url>#{url}</url>
          <displayUrl>#{display_url}</displayUrl>
          <headline>#{headline}</headline>
          <description1>#{description1}</description1>
          <description2>#{description2}</description2>
        </ad>
        <status>ENABLED</status>
      EOFS
    end

    ###########################################################################

    g_accessor :headline  
    g_accessor :description1 
    g_accessor :description2

    ###########################################################################

    def self.from_element(adgroup, el)
      new(adgroup) do
        @id         = el.elements["id"].text
        type          el.elements["Ad.Type"].text
        url           el.elements["url"].text
        display_url   el.elements["displayUrl"].text
        headline      el.elements["headline"].text
        description1  el.elements["description1"].text
        description2  el.elements["description2"].text
      end
    end

    def self.create(adgroup, &block)
      new(adgroup, &block).save
    end

    ############################################################################

    def save
      soap_message = service.adgroup_ad.create(credentials, to_xml)
      add_counters( soap_message.counters )
      rval = REXML::XPath.first( soap_message.response, "//mutateResponse/rval")
      id = REXML::XPath.match( rval, "value/ad/id" ).first
      @id = id.text
      self
    end

  end
end

