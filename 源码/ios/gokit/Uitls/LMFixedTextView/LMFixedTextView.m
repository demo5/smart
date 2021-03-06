//
//  LMFixedTextView.m
//  LMAlertViewDemo
//
//  Created by Lee McDermott on 10/12/2013.
//  Copyright (c) 2013 Bestir Ltd. All rights reserved.
//

#import "LMFixedTextView.h"

NSString *const LMFixedTextAttributeName = @"LMFixedText";

@implementation LMFixedTextView

#pragma mark - UITextView methods

- (void)setAttributedText:(NSAttributedString *)attributedText
{
	[attributedText enumerateAttribute:LMFixedTextAttributeName inRange:NSMakeRange(0, [attributedText length]) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
		if (value != nil) {
			// Found prefix
			if (range.location == 0) {
				self.prefixLength = range.length;
			}
			// Found suffix
			else if (range.location + range.length == [attributedText length]) {
				self.suffixLength = range.length;
			}
		}
	}];
	
	[super setAttributedText:attributedText];
	[self setSelectedTextRange:self.selectedTextRange];
}

- (void)setSelectedTextRange:(UITextRange *)selectedTextRange
{
	[super setSelectedTextRange:selectedTextRange];
	
	NSRange range = self.selectedRange;
	
	if (self.prefixLength > 0) {
		NSInteger prefixLength = self.prefixLength + 1;
		
		// If the start of the selection is past the hashtag suffix
		if (range.location < prefixLength) {
			self.selectedRange = NSMakeRange(prefixLength, 0);
		}
	}
	
	if (self.suffixLength > 0) {
		NSInteger suffixLength = self.suffixLength + 1;
		NSRange suffixRange = NSMakeRange([self.text length] - suffixLength, suffixLength);
		
		// If the start of the selection is past the hashtag suffix
		if (range.location > suffixRange.location) {
			self.selectedRange = NSMakeRange(suffixRange.location, 0);
		}
		// If the end of the selection crosses over into the hashtag suffix
		else if (range.location + range.length > suffixRange.location) {
			int length = (int)([self.text length] - suffixRange.length - range.location);
			self.selectedRange = NSMakeRange(range.location, length);
		}
	}
}

@end
