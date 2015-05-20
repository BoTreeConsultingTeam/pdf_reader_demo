require 'pdf/reader'
require 'wordpress_uitlity'
require 'rmagick'

class PdfConverterController < ApplicationController

  after_filter :edit_post, :post, :image_upload, :convert_images,  only: :convert

  def new
  end

  def post
    wp_utility = WordpressUtility::Post.new
    @post = wp_utility.create_post({ content: @document })
    flash[:notice] = 'Successfuly Posted'
  end

  def convert_images
    @images.flatten.each do |image|
      png = Magick::ImageList.new(image)
      png = png.scale(300, 300)
      png.write "#{image}.png"
    end
  end

  def image_upload
    wp_utility = WordpressUtility::Post.new
    @image_urls = []
    @images.flatten.each do |image|
      @image = wp_utility.upload_image("/home/hiren/rails_application/BlogPosting/pdf_reader_demo/#{image}.png")
      @image_urls << @image['url']
    end
    flash[:notice] = 'Successfuly Uploaded'
  end

  def edit_post
    wp_utility = WordpressUtility::Post.new
    wp_utility.edit_post({ id: @post.to_i, content: @document, images: @image_urls.map { |image| "<img src='#{image}'></img>" } })
  end

  def convert
    @document = ""
    extractor = PDFUtility::ExtractImages::Extractor.new
    PDF::Reader.open(params[:file].path) do |reader|
      reader.pages.each do |page|
        @document += page.text
        extractor.page(page)
      end
    end
    puts "All Images >>>>>>>>>>>>>> #{extractor.images}"
    @images = extractor.images.compact
    @images = @images.partition {|image| image.split('.').last == 'tif'}
    @tiff_images = @images.first
    @other_images = @images.last
    render 'show'
  end

   def image
    puts ">>>>>>>>>>>>>>>>>>>>>>>#{request.format.to_s}"
    send_data(open(Rails.root.join("#{params[:filename]}.#{params[:ext]}"), "rb").read)
    #send_file( Rails.root.join("2.jpg"), :disposition => 'inline', :type => request.format.to_s, :x_sendfile => true)
  end
end