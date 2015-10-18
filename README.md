# free-image-ruby-get-exif-data
A one-file monkey-patch to CFIS's "FreeImage bindings for Ruby" gem that adds the ability to read EXIF data from image files.

Summary of workflow:
- Load image via FreeImage (or just the image's header data)
- Get a pointer to the requested piece of EXIF data
- Create a new FITAG object based on the EXIF pointer data
- Use FreeImage functions to parse values from the FITAG object

Sample code:

	def get_exif_data(image_file, metadata_model, key_name)
		return_value = nil # Assume failure

		# Load only header data from source file
		FreeImage::Bitmap.new(
			FreeImage.FreeImage_Load(
				FreeImage::FreeImage_GetFIFFromFilename(image_file),
				image_file,
				FreeImage::AbstractSource::Decoder::FIF_LOADNOPIXELS
			)
		) do |image_header|

			begin
				# Check if there were any errors when loading the image.  Most commonly triggered by invalid/incomplete image files.
				# If this fails, Ruby throws an error and we skip to the "rescue" block
				FreeImage.check_last_error

				fitag_pointer = FFI::MemoryPointer.new :pointer

        # Returns true if key_name found within metadata_model chunk of EXIF block, otherwise returns false
				if FreeImage.FreeImage_GetMetadata(metadata_model, image_header, key_name, fitag_pointer)
					fitag = FreeImage::FITAG.new(fitag_pointer.read_pointer())
					return_value = FreeImage.get_fitag_value(fitag)
				end

			rescue
				logger.debug "INSERT COMMENT HERE"

			end
		
		end
		return return_value
	end


Sample code to find an EXIF metadata model and iterate through its tags:

	def list_exif_tags(image_file)
		# Load only header data from source file
		FreeImage::Bitmap.new(
			FreeImage.FreeImage_Load(
				FreeImage::FreeImage_GetFIFFromFilename(image_file),
				image_file,
				FreeImage::AbstractSource::Decoder::FIF_LOADNOPIXELS
			)
		) do |image_header|

			fitag_pointer = FFI::MemoryPointer.new :pointer
	
			for model in [:fimd_exif_exif, :fimd_exif_main, :fimd_exif_gps, :fimd_exif_makernote, :fimd_exif_interop, :fimd_iptc, :fimd_xmp, :fimd_geotiff, :fimd_animation, :fimd_custom, :fimd_exif_raw]
				# Function will return nil if EXIF model is not found
				metadata_pointer = FreeImage.FreeImage_FindFirstMetadata(model, image_header, fitag_pointer)
				if metadata_pointer
					begin
						fitag = FreeImage::FITAG.new(fitag_pointer.read_pointer())
						p "#{model} -- #{FreeImage.FreeImage_GetTagKey(fitag)}"
						# FreeImage_FindNextMetadata will return true or false, depending if it was able to advance to a new tag or is at the end of the tags.  fitag_pointer will be updated to the new tag.
					end while FreeImage.FreeImage_FindNextMetadata(metadata_pointer, fitag_pointer)
				end
			end
		end
	end
