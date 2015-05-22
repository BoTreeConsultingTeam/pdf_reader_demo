require 'pdf/reader'
require 'wordpress_uitlity'
require 'rmagick'
require 'zip'

class PdfConverterController < ApplicationController
  before_filter :wordpress_utility, only: :publish
  after_filter :cleanup_temp_files, only: :publish

  def new
  end

  def publish
    @link = @wordpress_utility.publish(*extract_blog_content)
    flash[:errors] = @wordpress_utility.errors.join('\n') unless @wordpress_utility.errors.nil?
    flash[:success] = "PDF uploaded successfully.  #{@link}"
    redirect_to root_path
  end

  private
    def extract_blog_content
      @content = ''
      @images = []
      params[:pdf_file].path.split('.').last == 'pdf' ? extract_images_and_text( params[:pdf_file].path ) : extract_zip
      [ @content, @images.flatten ]
    end

    def extract_zip
      files = []
      Zip::File.open(params[:pdf_file].path) do |zip_file|
        zip_file.each do |pdf_file|
          pdf_file.extract("#{pdf_file.name}")
          files << pdf_file.name
        end
      end

      files.sort_by { |file| file.split('-').last }.map { |pdf_file| extract_images_and_text(pdf_file) }

      delete_file(File.basename(params[:pdf_file].path))
    end

    def extract_images_and_text(pdf_file)
      extractor = PDFUtility::ExtractImages::Extractor.new
      PDF::Reader.open( pdf_file ) do |reader|
        reader.pages.each do |page|
          @content += page.text
          extractor.page(page)
        end
      end

      logger.debug "All Images >>>>>>>>>>>>>> #{extractor.images}"
      images = extractor.images.compact
      images = images.partition { |image| image.split('.').last == 'tif' }
      @images << images
      convert_images(images.first)
      delete_file(File.basename(pdf_file))
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
      @images.flatten.map { |image| delete_file(image); delete_file(image.split('.png').first) }
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