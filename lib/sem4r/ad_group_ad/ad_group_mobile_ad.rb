# -*- coding: utf-8 -*-
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

  # From: http://code.google.com/apis/adwords/v2009/docs/reference/AdGroupAdService.MobileAd.html
  #   A mobile ad can contain a click-to-call phone number, a link to a website, or both.
  #   You specify which features you want by setting certain fields, as shown in the following table.
  #   For example, to create a click-to-call mobile ad, set the fields in the Click-to-call column.
  #   A hyphen means don't set the corresponding field.
  class AdGroupMobileAd < AdGroupAd

    enum :Markups, [
      :CHTML,
      :HTML,
      :WML,
      :XHTML
    ]

    def initialize(ad_group, &block)
      @carriers = []
      self.type = MobileAd
      super
    end

    # MobileAd
    g_accessor     :headline
    g_accessor     :description
    g_set_accessor :markup, {:values_in => :Markups}
    g_set_accessor :carrier         # default carrier  'ALLCARRIERS'
    g_accessor     :business_name   # 20 caratteri 10 per il giappone
    g_accessor     :country_code
    g_accessor     :phone_number

    def image
      @image
    end

    def image(&block)
      @image = MobileAdImage.new(self, &block)
    end

    #
    # @private
    #
    def _xml(t)
      t.adGroupId   ad_group.id
      t.ad("xsi:type" => "MobileAd") do |ad|
        ad.headline        headline
        ad.description     description
        unless markups.empty?
          markups.each do |m|
            ad.markupLanguages m
          end
        end
        unless carriers.empty?
          carriers.each do |carrier|
            ad.mobileCarriers carrier
          end
        end
        ad.businessName    business_name
        ad.countryCode     country_code
        ad.phoneNumber     phone_number
      end
      t.status status
    end

    def xml(t, tag = nil)
      if tag
        t.__send__(tag, {"xsi:type" => "AdGroupAd"}) { |t| _xml(t) }
      else
        _xml(t)
      end
    end

    def to_xml(tag)
      xml(Builder::XmlMarkup.new, tag)
    end


    def self.from_element(ad_group, el)
      new(ad_group) do
        @id         = el.at_xpath("id").text.strip.to_i
        # type          el.at_xpath("Ad.Type").text
        headline       el.at_xpath("headline").text.strip
        description    el.at_xpath("description").text.strip
        business_name  el.at_xpath("businessName").text.strip
        country_code   el.at_xpath("countryCode").text.strip
        phone_number   el.at_xpath("phoneNumber").text.strip
        # TODO: estrarre le carriers
      end
    end

    def save
      unless @id
        soap_message = service.ad_group_ad.create( credentials, to_xml("operand") )
        add_counters( soap_message.counters )
        rval = soap_message.response.xpath("//mutateResponse/rval", soap_message.response_headers).first
        id = rval.xpath("value/ad/id").first
        @id = id.text.strip.to_i
      end
      self
    end

  end
end
