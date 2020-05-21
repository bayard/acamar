local addonName, addon = ...
local FilterProcessor, L, AceGUI, private
if(addonName ~= nil) then
	FilterProcessor = addon:NewModule("FilterProcessor", "AceEvent-3.0", "AceHook-3.0", "AceConsole-3.0")
	L = LibStub("AceLocale-3.0"):GetLocale(addonName)
	AceGUI = LibStub("AceGUI-3.0")
	private = {}
else
	addon = {}

	bit = bit32

	function addon:log(...) end
	FilterProcessor = {}

	addon = {
		db = {
			global =
			{
				score_threshold = 50,
			},
			profile =
			{
				plist = 
				{
					player_a =
					{
						-- spam score
						score = 38,
						-- query level using limited api, should performed at low freq
						level = 1,
						-- obtained by getuserinfobyguid
						class = "warlock",
						-- msgs table
						msgs = {
							-- message hash
							["9876543210"] =
							{
								-- msg length
								len = 8,
								-- all non-meaningful chars or contain sick chars
								spamlike = true,
								-- first receive time
								first_time = 11111111,
								-- last sent time, first read should ignored after addon reload
								last_time = 21111111,
								-- total received time
								total = 6668,
								-- msgs which received at certain intervals
								freq_spams = 888,
								-- max requency msgs hourly
								max_freq = 521,
							},
						},
					},
				},
			},
		},
	}
end

------------------------------------------------------------------------------

----- utilities functions
local function StringHash(text)
	local counter = 1
	local len = string.len(text)
	for i = 1, len, 3 do 
		counter = math.fmod(counter*8161, 4294967279) +  -- 2^32 - 17: Prime!
		  (string.byte(text,i)*16776193) +
		  ((string.byte(text,i+1) or (len-i+256))*8372226) +
		  ((string.byte(text,i+2) or (len-i+256))*3932164)
	end
	return math.fmod(counter, 4294967291) -- 2^32 - 5: Prime (and different from the prime in the loop)
end

-- utf8 (WoW default encoding) to unicode table, end with 0
local function utf8to32(utf8str)
	assert(type(utf8str) == "string")
	local res, seq, val = {}, 0, nil
	for i = 1, #utf8str do
		local c = string.byte(utf8str, i)
		if seq == 0 then
			table.insert(res, val)
			seq = c < 0x80 and 1 or c < 0xE0 and 2 or c < 0xF0 and 3 or
			      c < 0xF8 and 4 or --c < 0xFC and 5 or c < 0xFE and 6 or
				  error("invalid UTF-8 character sequence")
			val = bit.band(c, 2^(8-seq) - 1)
		else
			val = bit.bor(bit.lshift(val, 6), bit.band(c, 0x3F))
		end
		seq = seq - 1
	end
	table.insert(res, val)
	table.insert(res, 0)
	return res
end

local sickchars ={
	--{b=0x0000, e=0x007F}, --Basic Latin
	--{b=0x0000, e=0x002F}, --Basic Latin - Special Characters
	--{b=0x0030, e=0x0039}, --Basic Latin - Digits
	--{b=0x003A, e=0x0040}, --Basic Latin - Special Characters
	--{b=0x0041, e=0x005A}, --Basic Latin - Upper Case Letters
	--{b=0x005B, e=0x0060}, --Basic Latin - Special Characters
	--{b=0x0061, e=0x007A}, --Basic Latin - Lower Case Letters
	--{b=0x007B, e=0x007F}, --Basic Latin - Special Characters
	{b=0x0080, e=0x00FF}, --C1 Controls and Latin-1 Supplement
	{b=0x0100, e=0x017F}, --Latin Extended-A
	{b=0x0180, e=0x024F}, --Latin Extended-B
	{b=0x0250, e=0x02AF}, --IPA Extensions
	{b=0x02B0, e=0x02FF}, --Spacing Modifier Letters
	{b=0x0300, e=0x036F}, --Combining Diacritical Marks
	{b=0x0370, e=0x03FF}, --Greek/Coptic
	{b=0x0400, e=0x04FF}, --Cyrillic
	{b=0x0500, e=0x052F}, --Cyrillic Supplement
	--{b=0x0530, e=0x058F}, --Armenian
	--{b=0x0590, e=0x05FF}, --Hebrew
	--{b=0x0600, e=0x06FF}, --Arabic
	--{b=0x0700, e=0x074F}, --Syriac
	{b=0x0750, e=0x077F}, --Undefined
	--{b=0x0780, e=0x07BF}, --Thaana
	{b=0x07C0, e=0x08FF}, --Undefined
	--{b=0x0900, e=0x097F}, --Devanagari
	--{b=0x0980, e=0x09FF}, --Bengali/Assamese
	--{b=0x0A00, e=0x0A7F}, --Gurmukhi
	--{b=0x0A80, e=0x0AFF}, --Gujarati
	--{b=0x0B00, e=0x0B7F}, --Oriya
	--{b=0x0B80, e=0x0BFF}, --Tamil
	--{b=0x0C00, e=0x0C7F}, --Telugu
	--{b=0x0C80, e=0x0CFF}, --Kannada
	--{b=0x0D00, e=0x0DFF}, --Malayalam
	--{b=0x0D80, e=0x0DFF}, --Sinhala
	--{b=0x0E00, e=0x0E7F}, --Thai
	--{b=0x0E80, e=0x0EFF}, --Lao
	--{b=0x0F00, e=0x0FFF}, --Tibetan
	--{b=0x1000, e=0x109F}, --Myanmar
	--{b=0x10A0, e=0x10FF}, --Georgian
	--{b=0x1100, e=0x11FF}, --Hangul Jamo
	--{b=0x1200, e=0x137F}, --Ethiopic
	{b=0x1380, e=0x139F}, --Undefined
	--{b=0x13A0, e=0x13FF}, --Cherokee
	--{b=0x1400, e=0x167F}, --Unified Canadian Aboriginal Syllabics
	--{b=0x1680, e=0x169F}, --Ogham
	--{b=0x16A0, e=0x16FF}, --Runic
	--{b=0x1700, e=0x171F}, --Tagalog
	--{b=0x1720, e=0x173F}, --Hanunoo
	--{b=0x1740, e=0x175F}, --Buhid
	--{b=0x1760, e=0x177F}, --Tagbanwa
	--{b=0x1780, e=0x17FF}, --Khmer
	--{b=0x1800, e=0x18AF}, --Mongolian
	{b=0x18B0, e=0x18FF}, --Undefined
	--{b=0x1900, e=0x194F}, --Limbu
	--{b=0x1950, e=0x197F}, --Tai Le
	{b=0x1980, e=0x19DF}, --Undefined
	--{b=0x19E0, e=0x19FF}, --Khmer Symbols
	{b=0x1A00, e=0x1CFF}, --Undefined
	{b=0x1D00, e=0x1D7F}, --Phonetic Extensions
	{b=0x1D80, e=0x1DFF}, --Undefined
	{b=0x1E00, e=0x1EFF}, --Latin Extended Additional
	{b=0x1F00, e=0x1FFF}, --Greek Extended
	{b=0x2000, e=0x206F}, --General Punctuation
	{b=0x2070, e=0x209F}, --Superscripts and Subscripts
	{b=0x20A0, e=0x20CF}, --Currency Symbols
	{b=0x20D0, e=0x20FF}, --Combining Diacritical Marks for Symbols
	{b=0x2100, e=0x214F}, --Letterlike Symbols
	{b=0x2150, e=0x218F}, --Number Forms
	{b=0x2190, e=0x21FF}, --Arrows
	{b=0x2200, e=0x22FF}, --Mathematical Operators
	{b=0x2300, e=0x23FF}, --Miscellaneous Technical
	{b=0x2400, e=0x243F}, --Control Pictures
	{b=0x2440, e=0x245F}, --Optical Character Recognition
	{b=0x2460, e=0x24FF}, --Enclosed Alphanumerics
	{b=0x2500, e=0x257F}, --Box Drawing
	{b=0x2580, e=0x259F}, --Block Elements
	{b=0x25A0, e=0x25FF}, --Geometric Shapes
	{b=0x2600, e=0x26FF}, --Miscellaneous Symbols
	{b=0x2700, e=0x27BF}, --Dingbats
	{b=0x27C0, e=0x27EF}, --Miscellaneous Mathematical Symbols-A
	{b=0x27F0, e=0x27FF}, --Supplemental Arrows-A
	{b=0x2800, e=0x28FF}, --Braille Patterns
	{b=0x2900, e=0x297F}, --Supplemental Arrows-B
	{b=0x2980, e=0x29FF}, --Miscellaneous Mathematical Symbols-B
	{b=0x2A00, e=0x2AFF}, --Supplemental Mathematical Operators
	{b=0x2B00, e=0x2BFF}, --Miscellaneous Symbols and Arrows
	{b=0x2C00, e=0x2E7F}, --Undefined
	--{b=0x2E80, e=0x2EFF}, --CJK Radicals Supplement
	--{b=0x2F00, e=0x2FDF}, --Kangxi Radicals
	{b=0x2FE0, e=0x2EEF}, --Undefined
	{b=0x2FF0, e=0x2FFF}, --Ideographic Description Characters
	--{b=0x3000, e=0x303F}, --CJK Symbols and Punctuation
	--{b=0x3040, e=0x309F}, --Hiragana
	--{b=0x30A0, e=0x30FF}, --Katakana
	--{b=0x3100, e=0x312F}, --Bopomofo
	{b=0x3130, e=0x318F}, --Hangul Compatibility Jamo
	--{b=0x3190, e=0x319F}, --Kanbun (Kunten)
	--{b=0x31A0, e=0x31BF}, --Bopomofo Extended
	{b=0x31C0, e=0x31EF}, --Undefined
	--{b=0x31F0, e=0x31FF}, --Katakana Phonetic Extensions
	{b=0x3200, e=0x32FF}, --Enclosed CJK Letters and Months
	{b=0x3300, e=0x33FF}, --CJK Compatibility
	{b=0x3400, e=0x4DBF}, --CJK Unified Ideographs Extension A
	{b=0x4DC0, e=0x4DFF}, --Yijing Hexagram Symbols
	--{b=0x4E00, e=0x9FAF}, --CJK Unified Ideographs
	{b=0x9FB0, e=0x9FFF}, --Undefined
	{b=0xA000, e=0xA48F}, --Yi Syllables
	{b=0xA490, e=0xA4CF}, --Yi Radicals
	{b=0xA4D0, e=0xABFF}, --Undefined
	--{b=0xAC00, e=0xD7AF}, --Hangul Syllables
	{b=0xD7B0, e=0xD7FF}, --Undefined
	{b=0xD800, e=0xDBFF}, --High Surrogate Area
	{b=0xDC00, e=0xDFFF}, --Low Surrogate Area
	{b=0xE000, e=0xF8FF}, --Private Use Area
	{b=0xF900, e=0xFAFF}, --CJK Compatibility Ideographs
	{b=0xFB00, e=0xFB4F}, --Alphabetic Presentation Forms
	--{b=0xFB50, e=0xFDFF}, --Arabic Presentation Forms-A
	{b=0xFE00, e=0xFE0F}, --Variation Selectors
	{b=0xFE10, e=0xFE1F}, --Undefined
	{b=0xFE20, e=0xFE2F}, --Combining Half Marks
	{b=0xFE30, e=0xFE4F}, --CJK Compatibility Forms
	--{b=0xFE50, e=0xFE6F}, --Small Form Variants
	--{b=0xFE70, e=0xFEFF}, --Arabic Presentation Forms-B
	--{b=0xFF00, e=0xFFEF}, --Halfwidth and Fullwidth Forms
	{b=0xFFF0, e=0xFFFF}, --Specials
	{b=0x10000, e=0x1007F}, --Linear B Syllabary
	{b=0x10080, e=0x100FF}, --Linear B Ideograms
	{b=0x10100, e=0x1013F}, --Aegean Numbers
	{b=0x10140, e=0x102FF}, --Undefined
	{b=0x10300, e=0x1032F}, --Old Italic
	{b=0x10330, e=0x1034F}, --Gothic
	{b=0x10380, e=0x1039F}, --Ugaritic
	{b=0x10400, e=0x1044F}, --Deseret
	--{b=0x10450, e=0x1047F}, --Shavian
	--{b=0x10480, e=0x104AF}, --Osmanya
	{b=0x104B0, e=0x107FF}, --Undefined
	{b=0x10800, e=0x1083F}, --Cypriot Syllabary
	{b=0x10840, e=0x1CFFF}, --Undefined
	{b=0x1D000, e=0x1D0FF}, --Byzantine Musical Symbols
	{b=0x1D100, e=0x1D1FF}, --Musical Symbols
	{b=0x1D200, e=0x1D2FF}, --Undefined
	{b=0x1D300, e=0x1D35F}, --Tai Xuan Jing Symbols
	{b=0x1D360, e=0x1D3FF}, --Undefined
	{b=0x1D400, e=0x1D7FF}, --Mathematical Alphanumeric Symbols
	{b=0x1D800, e=0x1FFFF}, --Undefined
	{b=0x20000, e=0x2A6DF}, --CJK Unified Ideographs Extension B
	{b=0x2A6E0, e=0x2F7FF}, --Undefined
	{b=0x2F800, e=0x2FA1F}, --CJK Compatibility Ideographs Supplement
	{b=0x2FAB0, e=0xDFFFF}, --Unused
	{b=0xE0000, e=0xE007F}, --Tags
	{b=0xE0080, e=0xE00FF}, --Unused
	{b=0xE0100, e=0xE01EF}, --Variation Selectors Supplement
	{b=0xE01F0, e=0xEFFFF}, --Unused
	{b=0xF0000, e=0xFFFFD}, --Supplementary Private Use Area-A
	{b=0xFFFFE, e=0xFFFFF}, --Unused
	{b=0x100000, e=0x10FFFD}, --Supplementary Private Use Area-B
}

local non_meaningful_text_chars ={
	--{b=0x0000, e=0x007F}, --Basic Latin
	{b=0x0000, e=0x002F}, --Basic Latin - Special Characters
	--{b=0x0030, e=0x0039}, --Basic Latin - Digits
	{b=0x003A, e=0x0040}, --Basic Latin - Special Characters
	--{b=0x0041, e=0x005A}, --Basic Latin - Upper Case Letters
	{b=0x005B, e=0x0060}, --Basic Latin - Special Characters
	--{b=0x0061, e=0x007A}, --Basic Latin - Lower Case Letters
	{b=0x007B, e=0x007F}, --Basic Latin - Special Characters
	{b=0x0080, e=0x00FF}, --C1 Controls and Latin-1 Supplement
	{b=0x0100, e=0x017F}, --Latin Extended-A
	{b=0x0180, e=0x024F}, --Latin Extended-B
	{b=0x0250, e=0x02AF}, --IPA Extensions
	{b=0x02B0, e=0x02FF}, --Spacing Modifier Letters
	{b=0x0300, e=0x036F}, --Combining Diacritical Marks
	{b=0x0370, e=0x03FF}, --Greek/Coptic
	{b=0x0400, e=0x04FF}, --Cyrillic
	{b=0x0500, e=0x052F}, --Cyrillic Supplement
	--{b=0x0530, e=0x058F}, --Armenian
	--{b=0x0590, e=0x05FF}, --Hebrew
	--{b=0x0600, e=0x06FF}, --Arabic
	--{b=0x0700, e=0x074F}, --Syriac
	{b=0x0750, e=0x077F}, --Undefined
	--{b=0x0780, e=0x07BF}, --Thaana
	{b=0x07C0, e=0x08FF}, --Undefined
	--{b=0x0900, e=0x097F}, --Devanagari
	--{b=0x0980, e=0x09FF}, --Bengali/Assamese
	--{b=0x0A00, e=0x0A7F}, --Gurmukhi
	--{b=0x0A80, e=0x0AFF}, --Gujarati
	--{b=0x0B00, e=0x0B7F}, --Oriya
	--{b=0x0B80, e=0x0BFF}, --Tamil
	--{b=0x0C00, e=0x0C7F}, --Telugu
	--{b=0x0C80, e=0x0CFF}, --Kannada
	--{b=0x0D00, e=0x0DFF}, --Malayalam
	--{b=0x0D80, e=0x0DFF}, --Sinhala
	--{b=0x0E00, e=0x0E7F}, --Thai
	--{b=0x0E80, e=0x0EFF}, --Lao
	--{b=0x0F00, e=0x0FFF}, --Tibetan
	--{b=0x1000, e=0x109F}, --Myanmar
	--{b=0x10A0, e=0x10FF}, --Georgian
	--{b=0x1100, e=0x11FF}, --Hangul Jamo
	--{b=0x1200, e=0x137F}, --Ethiopic
	{b=0x1380, e=0x139F}, --Undefined
	--{b=0x13A0, e=0x13FF}, --Cherokee
	--{b=0x1400, e=0x167F}, --Unified Canadian Aboriginal Syllabics
	--{b=0x1680, e=0x169F}, --Ogham
	--{b=0x16A0, e=0x16FF}, --Runic
	--{b=0x1700, e=0x171F}, --Tagalog
	--{b=0x1720, e=0x173F}, --Hanunoo
	--{b=0x1740, e=0x175F}, --Buhid
	--{b=0x1760, e=0x177F}, --Tagbanwa
	--{b=0x1780, e=0x17FF}, --Khmer
	--{b=0x1800, e=0x18AF}, --Mongolian
	{b=0x18B0, e=0x18FF}, --Undefined
	--{b=0x1900, e=0x194F}, --Limbu
	--{b=0x1950, e=0x197F}, --Tai Le
	{b=0x1980, e=0x19DF}, --Undefined
	--{b=0x19E0, e=0x19FF}, --Khmer Symbols
	{b=0x1A00, e=0x1CFF}, --Undefined
	{b=0x1D00, e=0x1D7F}, --Phonetic Extensions
	{b=0x1D80, e=0x1DFF}, --Undefined
	{b=0x1E00, e=0x1EFF}, --Latin Extended Additional
	{b=0x1F00, e=0x1FFF}, --Greek Extended
	{b=0x2000, e=0x206F}, --General Punctuation
	{b=0x2070, e=0x209F}, --Superscripts and Subscripts
	{b=0x20A0, e=0x20CF}, --Currency Symbols
	{b=0x20D0, e=0x20FF}, --Combining Diacritical Marks for Symbols
	{b=0x2100, e=0x214F}, --Letterlike Symbols
	{b=0x2150, e=0x218F}, --Number Forms
	{b=0x2190, e=0x21FF}, --Arrows
	{b=0x2200, e=0x22FF}, --Mathematical Operators
	{b=0x2300, e=0x23FF}, --Miscellaneous Technical
	{b=0x2400, e=0x243F}, --Control Pictures
	{b=0x2440, e=0x245F}, --Optical Character Recognition
	{b=0x2460, e=0x24FF}, --Enclosed Alphanumerics
	{b=0x2500, e=0x257F}, --Box Drawing
	{b=0x2580, e=0x259F}, --Block Elements
	{b=0x25A0, e=0x25FF}, --Geometric Shapes
	{b=0x2600, e=0x26FF}, --Miscellaneous Symbols
	{b=0x2700, e=0x27BF}, --Dingbats
	{b=0x27C0, e=0x27EF}, --Miscellaneous Mathematical Symbols-A
	{b=0x27F0, e=0x27FF}, --Supplemental Arrows-A
	{b=0x2800, e=0x28FF}, --Braille Patterns
	{b=0x2900, e=0x297F}, --Supplemental Arrows-B
	{b=0x2980, e=0x29FF}, --Miscellaneous Mathematical Symbols-B
	{b=0x2A00, e=0x2AFF}, --Supplemental Mathematical Operators
	{b=0x2B00, e=0x2BFF}, --Miscellaneous Symbols and Arrows
	{b=0x2C00, e=0x2E7F}, --Undefined
	--{b=0x2E80, e=0x2EFF}, --CJK Radicals Supplement
	--{b=0x2F00, e=0x2FDF}, --Kangxi Radicals
	{b=0x2FE0, e=0x2EEF}, --Undefined
	{b=0x2FF0, e=0x2FFF}, --Ideographic Description Characters
	{b=0x3000, e=0x303F}, --CJK Symbols and Punctuation
	--{b=0x3040, e=0x309F}, --Hiragana
	--{b=0x30A0, e=0x30FF}, --Katakana
	--{b=0x3100, e=0x312F}, --Bopomofo
	{b=0x3130, e=0x318F}, --Hangul Compatibility Jamo
	--{b=0x3190, e=0x319F}, --Kanbun (Kunten)
	--{b=0x31A0, e=0x31BF}, --Bopomofo Extended
	{b=0x31C0, e=0x31EF}, --Undefined
	--{b=0x31F0, e=0x31FF}, --Katakana Phonetic Extensions
	{b=0x3200, e=0x32FF}, --Enclosed CJK Letters and Months
	{b=0x3300, e=0x33FF}, --CJK Compatibility
	{b=0x3400, e=0x4DBF}, --CJK Unified Ideographs Extension A
	{b=0x4DC0, e=0x4DFF}, --Yijing Hexagram Symbols
	--{b=0x4E00, e=0x9FAF}, --CJK Unified Ideographs
	{b=0x9FB0, e=0x9FFF}, --Undefined
	{b=0xA000, e=0xA48F}, --Yi Syllables
	{b=0xA490, e=0xA4CF}, --Yi Radicals
	{b=0xA4D0, e=0xABFF}, --Undefined
	--{b=0xAC00, e=0xD7AF}, --Hangul Syllables
	{b=0xD7B0, e=0xD7FF}, --Undefined
	{b=0xD800, e=0xDBFF}, --High Surrogate Area
	{b=0xDC00, e=0xDFFF}, --Low Surrogate Area
	{b=0xE000, e=0xF8FF}, --Private Use Area
	{b=0xF900, e=0xFAFF}, --CJK Compatibility Ideographs
	{b=0xFB00, e=0xFB4F}, --Alphabetic Presentation Forms
	--{b=0xFB50, e=0xFDFF}, --Arabic Presentation Forms-A
	{b=0xFE00, e=0xFE0F}, --Variation Selectors
	{b=0xFE10, e=0xFE1F}, --Undefined
	{b=0xFE20, e=0xFE2F}, --Combining Half Marks
	{b=0xFE30, e=0xFE4F}, --CJK Compatibility Forms
	--{b=0xFE50, e=0xFE6F}, --Small Form Variants
	--{b=0xFE70, e=0xFEFF}, --Arabic Presentation Forms-B
	{b=0xFF00, e=0xFFEF}, --Halfwidth and Fullwidth Forms
	{b=0xFFF0, e=0xFFFF}, --Specials
	{b=0x10000, e=0x1007F}, --Linear B Syllabary
	{b=0x10080, e=0x100FF}, --Linear B Ideograms
	{b=0x10100, e=0x1013F}, --Aegean Numbers
	{b=0x10140, e=0x102FF}, --Undefined
	{b=0x10300, e=0x1032F}, --Old Italic
	{b=0x10330, e=0x1034F}, --Gothic
	{b=0x10380, e=0x1039F}, --Ugaritic
	{b=0x10400, e=0x1044F}, --Deseret
	--{b=0x10450, e=0x1047F}, --Shavian
	--{b=0x10480, e=0x104AF}, --Osmanya
	{b=0x104B0, e=0x107FF}, --Undefined
	{b=0x10800, e=0x1083F}, --Cypriot Syllabary
	{b=0x10840, e=0x1CFFF}, --Undefined
	{b=0x1D000, e=0x1D0FF}, --Byzantine Musical Symbols
	{b=0x1D100, e=0x1D1FF}, --Musical Symbols
	{b=0x1D200, e=0x1D2FF}, --Undefined
	{b=0x1D300, e=0x1D35F}, --Tai Xuan Jing Symbols
	{b=0x1D360, e=0x1D3FF}, --Undefined
	{b=0x1D400, e=0x1D7FF}, --Mathematical Alphanumeric Symbols
	{b=0x1D800, e=0x1FFFF}, --Undefined
	{b=0x20000, e=0x2A6DF}, --CJK Unified Ideographs Extension B
	{b=0x2A6E0, e=0x2F7FF}, --Undefined
	{b=0x2F800, e=0x2FA1F}, --CJK Compatibility Ideographs Supplement
	{b=0x2FAB0, e=0xDFFFF}, --Unused
	{b=0xE0000, e=0xE007F}, --Tags
	{b=0xE0080, e=0xE00FF}, --Unused
	{b=0xE0100, e=0xE01EF}, --Variation Selectors Supplement
	{b=0xE01F0, e=0xEFFFF}, --Unused
	{b=0xF0000, e=0xFFFFD}, --Supplementary Private Use Area-A
	{b=0xFFFFE, e=0xFFFFF}, --Unused
	{b=0x100000, e=0x10FFFD}, --Supplementary Private Use Area-B
}

-- check if unicode table cotains sick chars (garbage chars)
-- return: len, garbage
-- len: length of string (in utf8 encoding)
-- garbage: true/false, true if contains garbage chars
function contains_sickchars(utfstr)
	if(utfstr == nil or utfstr == "") then
		return 0, false
	end
	
	local unicode_table = utf8to32(utfstr)
	local len = #unicode_table

	len = len -1 

	for key, uchar in pairs(unicode_table) do
		if(uchar~=0) then 
			for _, garbage_block in pairs(sickchars) do
				if(uchar>=garbage_block.b and uchar<=garbage_block.e) then
					--print("key=", key)
					return len, true
				end
			end
		end
	end

	return len, false
end

-- check if a utf string don't contains any meaningful char
-- return: len, non_meaningful
-- len: length of string (in utf8 encoding)
-- non_meaningful: true/false, true if string has no meanful char
function all_non_meaningful(utfstr)
	if(utfstr == nil or utfstr == "") then
		return 0, true
	end
	
	local unicode_table = utf8to32(utfstr)
	local len = #unicode_table

	len = len -1 

	for key, uchar in pairs(unicode_table) do
		if(uchar~=0) then 
			meaningful = true
			for _, nontext_block in pairs(non_meaningful_text_chars) do
				if(uchar>=nontext_block.b and uchar<=nontext_block.e) then
					meaningful = false
					break
				end
			end
			if(meaningful) then
				return len, false
			end
		end
	end

	return len, true
end

-----------------------------------------------------

function FilterProcessor:loaddb()
	addon.db.profile.plist = addon.db.profile.plist or {}
end

function FilterProcessor:OnInitialize()
	FilterProcessor:loaddb()
end

function FilterProcessor:OnNewMessage(...)
	local msgdata = ...

	self:LeaningMessage(msgdata)

	local score = self:GetSpamScore()
	-- Spam score results in block action
	--addon:log(table_to_string({player=msgdata.player,score=score, score_threshold=addon.db.global.score_threshold}))
	if(score>addon.db.global.score_threshold) then
		return true, score
	else
		return false, 0
	end
end

function FilterProcessor:GetSpamScore()
	return 36
end

function FilterProcessor:LeaningMessage(msgdata)
	--addon:log("leaning [" .. msgdata.from .. "] channal=[" .. msgdata.chan_id_name .. "] msg=" .. msgdata.message)
	--local md5str = md5.sumhexa(msgdata.message)
	hashstr = StringHash(msgdata.message)
	msgdata.hash = hashstr

	self:BehaviorNewMessage(msgdata)
end

function FilterProcessor:BehaviorNewMessage(msgdata)
	local len, hassick, notmeaningful = self:GetMsgSpec(msgdata.message)

	if(hassick or notmeaningful) then 
		addon:log("spam:" .. tostring(spamlike) .. ", len=" .. len .. " [" .. 
			msgdata.from .. "] channal=[" .. msgdata.chan_id_name .. 
			"] hash=" .. hashstr .. ", msg=" .. msgdata.message)
	end

	user_metrics = {}
	for k,v in pairs(addon.db.profile.plist) do
		-- if user data found
		if( k == msgdata.from ) then
			-- if(v[''])
		end
	end
end

-- return: len, garbage
-- len: length of string (in utf8 encoding)
-- garbage: true/false, true if spam like (contain sick chars or has non meanful char)
function FilterProcessor:GetMsgSpec(message)
	if(message == nil or message == "") then
		return 0, false
	end

	len, hassick = contains_sickchars(message)
	_, notmeaningful = all_non_meaningful(message)

	return len, hassick, notmeaningful
end

---------------------------
-- test functions
if addonName == nil then
	function test1()
		a='收G G G G G G G G G G ………出的MMM………骗子滚……收G G G G G G G G G G ………出的MMM………骗子滚……收G G G G G G G G G G ………出的MMM………骗子滚……'
		print(a)
		len, found = contains_sickchars(a)
		print(len, " sick:", found)
		len, found = all_non_meaningful(a)
		print(len, " non-meaningful:", found)
	end


	test1()
end
-- EOF