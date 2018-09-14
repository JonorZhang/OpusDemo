//
//  PlotView.m
//  Opus
//
//  Created by Jonor on 2018/9/13.
//  Copyright © 2018年 Jonor. All rights reserved.
//

#import "PlotView.h"

@implementation PlotView

- (void)setPoints:(NSData *)points {
    _points = points;
    [self setNeedsDisplay];
}

- (CGFloat)coordinateYFromShort:(short)s {
    CGFloat f = 0.0;
    f = (s / maxY + 1) * self.bounds.size.height / 2;
//    NSLog(@"%d, %.2f", s, f);
    return f;
}

CGFloat maxY = 0.0;

- (void)drawRect:(CGRect)rect {
    
    if (_points.length == 0) {
        return;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [UIColor orangeColor].CGColor);
    
    short *ptr = (short *)_points.bytes;
    unsigned long len = _points.length / sizeof(short);
    unsigned long groupCnt = len / self.bounds.size.width;

    unsigned long pointCnt = self.bounds.size.width;
    short newPointsY[pointCnt];
    short average = 0;
    maxY = 0;
    for (int i=0; i<pointCnt; i++) {
        average = 0;
        for (int j=0; j<groupCnt; j++) {
            average = (average + ptr[i * groupCnt + j]) / 2;
        }
        maxY = MAX(average, maxY);
        newPointsY[i] = average;
    }
    unsigned long pos = 0;
    
    short v = *(newPointsY + pos);
    CGFloat y = [self coordinateYFromShort:v];
    CGContextMoveToPoint(context, 0, y);
    pos++;
    
    while (pos < pointCnt) {
        v = newPointsY[pos];
        y = [self coordinateYFromShort:v];
        CGContextAddLineToPoint(context, pos, y);
        pos++;
    }
    
    [[UIColor blueColor] setStroke];
    CGContextDrawPath(context, kCGPathStroke);
    
    
    NSString *text = [NSString stringWithFormat:@"峰值: %.0f", maxY];
    // 文本段落样式
    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle alloc] init];
    textStyle.lineBreakMode = NSLineBreakByWordWrapping; // 结尾部分的内容以……方式省略 ( "...wxyz" ,"abcd..." ,"ab...yz")
    textStyle.alignment = NSTextAlignmentLeft; //（两端对齐的）文本对齐方式：（左，中，右，两端对齐，自然）
    textStyle.lineSpacing = 5; // 字体的行间距
    textStyle.firstLineHeadIndent = 5.0; // 首行缩进
    textStyle.headIndent = 0.0; // 整体缩进(首行除外)
    textStyle.tailIndent = 0.0; //
    textStyle.minimumLineHeight = 20.0; // 最低行高
    textStyle.maximumLineHeight = 20.0; // 最大行高
    textStyle.paragraphSpacing = 15; // 段与段之间的间距
    textStyle.paragraphSpacingBefore = 22.0f; // 段首行空白空间/* Distance between the bottom of the previous paragraph (or the end of its paragraphSpacing, if any) and the top of this paragraph. */
    textStyle.baseWritingDirection = NSWritingDirectionLeftToRight; // 从左到右的书写方向（一共➡️三种）
    textStyle.lineHeightMultiple = 15; /* Natural line height is multiplied by this factor (if positive) before being constrained by minimum and maximum line height. */
    textStyle.hyphenationFactor = 1; //连字属性 在iOS，唯一支持的值分别为0和1
    // 文本属性
    NSMutableDictionary *textAttributes = [[NSMutableDictionary alloc] init];
    // NSParagraphStyleAttributeName 段落样式
    [textAttributes setValue:textStyle forKey:NSParagraphStyleAttributeName];
    // NSFontAttributeName 字体名称和大小
    [textAttributes setValue:[UIFont systemFontOfSize:12.0] forKey:NSFontAttributeName];
    // NSForegroundColorAttributeNam 颜色
    [textAttributes setValue:[UIColor redColor] forKey:NSForegroundColorAttributeName];
    // 绘制文字
    [text drawInRect:rect withAttributes:textAttributes];
}

@end
