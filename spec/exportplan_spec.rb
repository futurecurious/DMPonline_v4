require "json"
require "selenium-webdriver"
require "rspec"
require "yaml"
require "mail"
require "pdf/reader"
require "./spec/helper.rb"
require "./spec/before.rb"
require "./spec/after.rb"
require "./spec/user.rb"
require "./spec/plan.rb"
include RSpec::Expectations

include Before
include After
include User
include Plan

describe "Export Plan" do

  setup
  
  teardown
  
  before(:all) do
    begin
      create_and_verify_user
      create_and_verify_plan
      @section_headings = get_plan_section_headings
    rescue
      screen_capture
    end
  end
  
  after(:each) do
    if !example.instance_variable_get(:@exception).nil? 
      screen_capture
    end
    file = @download_dir + @properties['dmp_plan']['name'] + '.pdf' 
    FileUtils.remove file unless not File.exists?(file)
  end
  
  after(:all) do
    begin
      sign_out_user
      destroy_plan
      remove_previously_added_user('dmp_user')
    rescue
      screen_capture
    end
  end

  it "export plan as webpage" do
    win_handle = @driver.window_handle
    visit_export_page
    dropdown = @driver.find_element(id: 'select-form-format')
    options=dropdown.find_elements(tag_name: 'option')
    options.each {|option| option.click if option.text == 'html' } 
    @driver.find_element(:xpath, "//input[@value='Export']").click
    sleep 3
    @driver.switch_to.window(@driver.window_handles[1])
    (@driver.find_element(:css, "h1").text).should == @properties['dmp_plan']['name']
    @section_headings.each do |section| 
      (@driver.find_element(:class, "dmp_details").text).should include(section)
    end
    @driver.close
    @driver.switch_to.window(win_handle)
  end

  it "export plan as txt" do 
    win_handle = @driver.window_handle
    visit_export_page
   dropdown = @driver.find_element(id: 'select-form-format')
    options=dropdown.find_elements(tag_name: 'option')
    options.each {|option| option.click if option.text == 'text' }
    @driver.find_element(:xpath, "//input[@value='Export']").click
 
    sleep 3
    #@driver.switch_to.window(@driver.window_handles[1])
    #@driver.find_element(:css, "pre").text.should =~ /#{@properties['dmp_plan']['name']}/m
    #@section_headings.each do | section |
    #  @driver.find_element(:css, "pre").text.should include(section)
    #end
    #@driver.close
    #@driver.switch_to.window(win_handle)
  end
  
  it "export plan as pdf " do
    visit_export_page
    dropdown = @driver.find_element(id: 'select-form-format')
    options=dropdown.find_elements(tag_name: 'option')
    options.each {|option| option.click if option.text == 'pdf' }
    @driver.find_element(:xpath, "//input[@value='Export']").click

    reader = get_pdf
    
    # with admin details
    reader.page(1).text.gsub(/\s/,'').should include(@properties['dmp_plan']['name'].gsub(/\s/,''))
    reader.page(1).text.should include("Institution")
    # all pdfs
    @section_headings.each do | section |
      contains_section( reader, section ).should be_true
    end
    reader.page( reader.pages.count ).text.should include("This document was generated by DMP Builder") 
  end

  
  def get_pdf
    file = @download_dir + @properties['dmp_plan']['name'] + '.pdf'
    
    while(not FileTest.exist?(file))
      sleep 3
    end
    
    reader = PDF::Reader.new(file)

  end
  
  def contains_section( reader, section )
    reader.pages.any? { |page| page.text.include? section }
  end
  
end