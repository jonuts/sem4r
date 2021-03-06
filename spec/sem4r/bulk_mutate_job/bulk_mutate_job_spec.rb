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
# -------------------------------------------------------------------------

require File.expand_path(File.dirname(__FILE__) + '/../../rspec_helper')

describe BulkMutateJob do
  include Sem4rSpecHelper

  before do
    @ad_group = mock("adgroup").as_null_object
  end

  it "should accept type accessor" do
    text_ad      = AdGroupTextAd.new(@ad_group) do
      headline     = "headline"
      description1 = "description1"
      description2 = "description2"
    end
    ad_operation = AdGroupAdOperation.add text_ad

    job             = BulkMutateJob.new
    job.campaign_id = 100
    job.add_operation ad_operation

    job.should have(1).operations
    job.num_parts.should == 1
    job.num_parts = 2
    job.num_parts.should == 2
  end

  it "should parse xml" do
    el  = read_model("//rval", "bulk_mutate_job", "get-res.xml")
    job = BulkMutateJob.from_element(el)
    job.id.should == 56889
    job.status.should == "PENDING"
  end

  it "should build xml only with id (input for google)" do
    job = BulkMutateJob.new
    job.instance_eval { @id = 1234 }
    puts job.to_xml.should == '<operand xsi:type="BulkMutateJob"><id>1234</id></operand>'
  end

  it "should build xml (input for google)" do
    @ad_group.stub(:id).and_return(3060284754)
    @campaign = stub("campaign")
    @campaign.stub(:id).and_return(100)

    job      = template_bulk_mutate_job(@campaign, @ad_group)

    expected = read_model("//operand", "bulk_mutate_job", "mutate-req.xml")
    job.to_xml('operand').should xml_equivalent(expected)
  end
end

