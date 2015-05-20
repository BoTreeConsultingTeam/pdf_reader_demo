require 'pdf/reader'
require 'wordpress_uitlity'
require 'rmagick'

class PdfConverterController < ApplicationController

  after_filter :edit_post, :post, :image_upload, :convert_images, :wordpress_utility,  only: :convert

  def new
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
    logger.debug "All Images >>>>>>>>>>>>>> #{extractor.images}"
    @images = extractor.images.compact
    @images = @images.partition {|image| image.split('.').last == 'tif'}
    @tiff_images = @images.first
    @other_images = @images.last
    render 'show'
  end

  def image
    logger.debug ">>>>>>>>>>>>>>>>>>>>>>>#{request.format.to_s}"
    send_data(open(Rails.root.join("#{params[:filename]}.#{params[:ext]}"), "rb").read)
    #send_file( Rails.root.join("2.jpg"), :disposition => 'inline', :type => request.format.to_s, :x_sendfile => true)
  end

  private
    def wordpress_utility
      @wordpress_utility = WordpressUtility::Post.new({ host: ENV['HOST'],
                                                 user:  ENV['USERNAME'],
                                                 password: ENV['PASSWORD'],
                                                 path:  ENV['WP_PATH'] })
    end

    def post
      @post = @wordpress_utility.create_post({ title: get_title_from_content(@document), content: @document })
      flash[:notice] = 'Successfuly Posted'
    end

    def get_title_from_content(content)
      content.squish.split(' ')[0, 6].join(' ')
    end

    def convert_images
      @images.flatten.each do |image|
        png = Magick::ImageList.new(image)
        png.write "#{image}.png"
      end
    end

    def image_upload
      @image_urls = []
      @images.flatten.each do |image|
        @image = @wordpress_utility.upload_image("#{image}.png")
        @image_urls << @image['url']
      end
      flash[:notice] = 'Successfuly Uploaded'
    end

    def edit_post
      @wordpress_utility.edit_post( { id: @post.to_i,
                                      content: @document,
                                      images: @image_urls.map { |image| "<img src='#{image}'></img>" }
                                   } )
    end

end