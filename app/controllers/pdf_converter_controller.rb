require 'pdf/reader'
class PdfConverterController < ApplicationController
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
    puts "All Images >>>>>>>>>>>>>> #{extractor.images}"
    @images = extractor.images
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