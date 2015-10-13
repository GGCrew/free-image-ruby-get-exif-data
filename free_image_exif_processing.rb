module FreeImage

	FreeImage.enum :metadata_model, [	
		:fimd_comments, 0,
		:fimd_exif_main, 1,
		:fimd_exif_exif, 2,
		:fimd_exif_gps, 3,
		:fimd_exif_makernote, 4,
		:fimd_exif_interop, 5,
		:fimd_iptc, 6,
		:fimd_xmp, 7,
		:fimd_geotiff, 8,
		:fimd_animation, 9,
		:fimd_custom, 10,
		:fimd_exif_raw, 11
	]

	FreeImage.enum :tag_data_type, [
		:fidt_notype, 0, # Placeholder (do not use this type)
		:fidt_byte, 1, # 8-bit unsigned integer
		:fidt_ascii, 2, # 8-bit byte that contains a 7-bit ASCII code; the last byte must be NUL (binary zero)
		:fidt_short, 3, # 16-bit (2-byte) unsigned integer
		:fidt_long, 4, # 32-bit (4-byte) unsigned integer
		:fidt_rational, 5, # Two  LONGs:  the  first  represents  the  numerator  of  a  fraction;  the  second,  the denominator
		:fidt_sbyte, 6, # An 8-bit signed (twos-complement) integer
		:fidt_undefined, 7, # An 8-bit byte that may contain anything, depending on the definition of the field.
		:fidt_sshort, 8, # A 16-bit (2-byte) signed (twos-complement) integer
		:fidt_slong, 9, # A 32-bit (4-byte) signed (twos-complement) integer
		:fidt_srational, 10, # Two  SLONG’s: the first represents  the  numerator of a fraction, the second  the denominator
		:fidt_float, 11, # Single precision (4-byte) IEEE format
		:fidt_double, 12, # Double precision (8-byte) IEEE format
		:fidt_ifd, 13, # FIDT_IFD data type is identical to LONG, but is only used to store offsets
		:fidt_palette, 14, # 32-bit (4-byte) RGBQUAD
		:fidt_long8, 16, # 64-bit unsigned integer
		:fidt_slong8, 17, # 64-bit signed integer
		:fidt_ifd8, 18 # FIDT_IFD8 data type is identical to LONG8, but is only used to store offsets
	]


  class FITAG < FFI::Struct
		layout :key,					:string,
					 :description,	:string,
					 :id,						:word,
					 :type,					:word,
					 :count,				:dword, 
					 :length,				:dword,
					 :value,				:dword
	end


  # DLL_API BOOL DLL_CALLCONV FreeImage_GetMetadata(FREE_IMAGE_MDMODEL model, FIBITMAP *dib, const char *key, FITAG **tag);
  attach_function('FreeImage_GetMetadata', [:metadata_model, :pointer, :string, :pointer], FreeImage::Boolean)

	# DLL_API const char *DLL_CALLCONV FreeImage_GetTagKey(FITAG *tag);
	attach_function('FreeImage_GetTagKey', [:pointer], :string)

	# DLL_API const char *DLL_CALLCONV FreeImage_GetTagDescription(FITAG *tag);
	attach_function('FreeImage_GetTagDescription', [:pointer], :string)

	# DLL_API WORD DLL_CALLCONV FreeImage_GetTagID(FITAG *tag);
	attach_function('FreeImage_GetTagID', [:pointer], :word)

	# DLL_API FREE_IMAGE_MDTYPE DLL_CALLCONV FreeImage_GetTagType(FITAG *tag);
	attach_function('FreeImage_GetTagType', [:pointer], :tag_data_type)

	# DLL_API DWORD DLL_CALLCONV FreeImage_GetTagCount(FITAG *tag);
	attach_function('FreeImage_GetTagCount', [:pointer], :dword)

	# DLL_API DWORD DLL_CALLCONV FreeImage_GetTagLength(FITAG *tag);
	attach_function('FreeImage_GetTagLength', [:pointer], :dword)

	# DLL_API const void *DLL_CALLCONV FreeImage_GetTagValue(FITAG *tag);
	attach_function('FreeImage_GetTagValue', [:pointer], :pointer)


	#..#


	def self.get_fitag_value(fitag)
		return_value = case FreeImage_GetTagType(fitag)
			when :fidt_ascii
				FreeImage_GetTagValue(fitag).read_string

			else
				logger.debug('UNEXPECTED FITAG Tag Type!')
				nil

		end

		return return_value
	end


end
