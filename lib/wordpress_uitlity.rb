require 'rubypress'
require 'mime/types'

module WordpressUtility
  class Post
    attr_reader :errors

    def initialize(params)
      @errors = []
      @uploaded_images = []
      @wordpress_client = Rubypress::Client.new( host: params[:host],
                                                username: params[:user],
                                                password: params[:password],
                                                path: params[:path] )
    end

    def publish(text, images)
      post_id = create_post({ title: get_title_from_content(text), content: text })

      upload_images(images)

      edit_post({ id: post_id.to_i,
                  content: text,
                  images: @uploaded_images.map { |image| "<img src='#{image}'></img>" }
                })

      draft_post_link(post_id.to_i)
    end

    def create_post(params)
      @wordpress_client.newPost( content: {
                                           post_status: 'draft',
                                           post_date: Time.now,
                                           post_content: params[:content].squish,
                                           post_title: params[:title]
                                          }
                               )
    end

    def edit_post(params)
      @wordpress_client.editPost( post_id: params[:id],
                                  content: {
                                            post_content: "#{params[:content]} #{params[:images].join("\n")}"
                                           }
                                )
    end

    def upload_image(filename)
      image = @wordpress_client.uploadFile(data: { name: File.basename(filename),
                                            type: MIME::Types.type_for(filename).first.to_s,
                                            bits: XMLRPC::Base64.new(File.open(filename).read)
                                          }
                                    )
      @uploaded_images << image['url']
    end

    def draft_post_link(id)
      "Click <a href='http://#{ENV['HOST']}/wp-admin/post.php?post=#{id}&action=edit' target='_blank'> here </a> to update the Post" if id.present?
    end

    private
      def upload_images(images)
        images.each do |image|
          begin
            upload_image(image)
          rescue => e
            @errors << 'Unable to upload few images' unless @errors.include?('Unable to upload few images')
          end
        end
      end

      def get_title_from_content(content)
        content.squish.split(' ')[0, 6].join(' ')
      end
  end
end