require 'pdf/reader'
require 'wordpress_uitlity'
require 'rmagick'

class PdfConverterController < ApplicationController
  before_filter :wordpress_utility, only: :publish
  after_filter :cleanup_temp_files, only: :publish

  def new
  end

  def publish
    @link = @wordpress_utility.publish(*extract_images_and_text)
    flash[:errors] = @wordpress_utility.errors.join('\n') unless @wordpress_utility.errors.nil?
    flash[:success] = 'PDF uploaded successfully.'
    binding.pry
    render 'show'
  end

  private

    def extract_images_and_text
      content = ''
      @pdf_file = File.basename params[:pdf_file].path
      extractor = PDFUtility::ExtractImages::Extractor.new

      PDF::Reader.open(params[:pdf_file].path) do |reader|
        reader.pages.each do |page|
          content += page.text
          extractor.page(page)
        end
      end

      logger.debug "All Images >>>>>>>>>>>>>> #{extractor.images}"
      images = extractor.images.compact
      @images = images.partition { |image| image.split('.').last == 'tif' }

      convert_images(@images.first)
      [content, images]
    end

    def wordpress_utility
      @wordpress_utility = WordpressUtility::Post.new({ host: ENV['HOST'],
                                                         user:  ENV['USERNAME'],
                                                         password: ENV['PASSWORD'],
                                                         path:  ENV['WP_PATH'] })
    end

    def convert_images(tif_images)
      tif_images.each_with_index do |image, index|
        png = Magick::ImageList.new(image)
        png.write "#{image}.png"
        delete_file(image)
        tif_images[index] = "#{image}.png"
      end
    end

    def cleanup_temp_files
      @images.flatten.map { |image| delete_file(image) }
      delete_file(@pdf_file)
    end

    def delete_file(file)
      begin
        File.delete(file)
      rescue => e
        logger.error "File #{file} is not deleted"
        logger.error e
      end
    end
end