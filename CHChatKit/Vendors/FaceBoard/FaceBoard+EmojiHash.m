//
//  FaceBoard+EmojiHash.m
//  CSChatDemo
//
//  Created by XiaoSong on 15/12/15.
//  Copyright © 2015年 Chausson. All rights reserved.
//

#import "FaceBoard+EmojiHash.h"

@implementation FaceBoard (EmojiHash)
- (void)configurationEmoji{

     self.emojiArray = [NSArray arrayWithObjects:
                   [self imageNamed:@"emo_001"],
                   [self imageNamed:@"emo_002"],
                   [self imageNamed:@"emo_003"],
                   [self imageNamed:@"emo_004"],
                   [self imageNamed:@"emo_005"],
                   [self imageNamed:@"emo_006"],
                   [self imageNamed:@"emo_007"],
                   [self imageNamed:@"emo_008"],
                   [self imageNamed:@"emo_009"],
                   [self imageNamed:@"emo_010"],
                   [self imageNamed:@"emo_011"],
                   [self imageNamed:@"emo_012"],
                   [self imageNamed:@"emo_013"],
                   [self imageNamed:@"emo_014"],
                   [self imageNamed:@"emo_015"],
                   [self imageNamed:@"emo_016"],
                   [self imageNamed:@"emo_017"],
                   [self imageNamed:@"emo_018"],
                   [self imageNamed:@"emo_019"],
                   [self imageNamed:@"emo_020"],
                   [self imageNamed:@"emo_021"],
                   [self imageNamed:@"emo_022"],
                   [self imageNamed:@"emo_023"],
                   [self imageNamed:@"emo_024"],
                   [self imageNamed:@"emo_025"],
                   [self imageNamed:@"emo_026"],
                   [self imageNamed:@"emo_027"],
                   [self imageNamed:@"emo_028"],
                   [self imageNamed:@"emo_029"],
                   [self imageNamed:@"emo_030"],
                   [self imageNamed:@"emo_031"],
                   [self imageNamed:@"emo_032"],
                   [self imageNamed:@"emo_033"],
                   [self imageNamed:@"emo_034"],
                   [self imageNamed:@"emo_035"],
                   [self imageNamed:@"emo_036"],
                   [self imageNamed:@"emo_037"],
                   [self imageNamed:@"emo_038"],
                   [self imageNamed:@"emo_039"],
                   [self imageNamed:@"emo_040"],
                   [self imageNamed:@"emo_041"],
                   [self imageNamed:@"emo_042"],
                   [self imageNamed:@"emo_043"],
                   [self imageNamed:@"emo_044"],
                   [self imageNamed:@"emo_045"],
                   [self imageNamed:@"emo_046"],

                   [self imageNamed:@"emo_047"],
                   [self imageNamed:@"emo_048"],
                   [self imageNamed:@"emo_049"],
                   [self imageNamed:@"emo_050"],
                   [self imageNamed:@"emo_051"],
                   [self imageNamed:@"emo_052"],
                   [self imageNamed:@"emo_053"],
                   [self imageNamed:@"emo_054"],
                   [self imageNamed:@"emo_055"],
                   [self imageNamed:@"emo_056"],

                   nil];
    
    self.symbolArray = [NSArray arrayWithObjects:
                    @"\U0001F604", //@"\ue415",
                    @"\U0001F60A", //@"\ue056",
                    @"\U0001F603", //@"\ue057",
                    @"\u263A",  //@"\ue414",
                    @"\U0001F609", //@"\ue405",
                    @"\U0001F60D", //@"\ue106",
                    @"\U0001F618", //@"\ue418",
                    @"\U0001F61A", //@"\ue417",
                    @"\U0001F633", //@"\ue40d",
                    @"\U0001F60C", //@"\ue40a",
                    @"\U0001F601", //@"\ue404",
                    @"\U0001F61C", //@"\ue105",
                    @"\U0001F61D", //@"\ue409",
                    @"\U0001F612", //@"\ue40e",
                    @"\U0001F60F", //@"\ue402",
                    @"\U0001F613", //@"\ue108",
                    @"\U0001F614", //@"\ue403",
                    @"\U0001F61E", //@"\ue058",
                    @"\U0001F616", //@"\ue407",
                    @"\U0001F625", //@"\ue401",
                    @"\U0001F630", //@"\ue40f",
                    @"\U0001F628", //@"\ue40b",
                    @"\U0001F623", //@"\ue406",
                    @"\U0001F622", //@"\ue413",
                    @"\U0001F62D", //@"\ue411",
                    @"\U0001F602", //@"\ue412",
                    @"\U0001F632", //@"\ue410",
                    @"\U0001F631", //@"\ue107",
                    @"\U0001F620", //@"\ue059",
                    @"\U0001F621", //@"\ue416",
                    @"\U0001F62A", //@"\ue408",
                    @"\U0001F637", //@"\ue40c",
                    @"\U0001F47F", //@"\ue11a",
                    @"\U0001F47D", //@"\ue10c",
                    @"\u2764", //@"\ue022",
                    @"\U0001F494", //@"\ue023",
                    @"\U0001F498", //@"\ue329",
                    @"\U0001F31F", //@"\ue32f",
                    @"\U0001F4A4", //@"\ue13c",
                    @"\U0001F4A6", //@"\ue331",
                    @"\U0001F385", //@"\ue03e",
                    @"\U0001F525", //@"\ue11d",
                    @"\U0001F4A9", //@"\ue05a",
                    @"\U0001F44D", //@"\ue421",
                    @"\U0001F44E", //@"\ue00e",
                    @"\U0001F44A", //@"\ue00d",
                    @"\U0001F466", //@"\ue001",
                    @"\U0001F467", //@"\ue002",
                    @"\U0001F469", //@"\ue005",
                    @"\U0001F468", //@"\ue004",

                    @"\u2600", //@"\ue04a",
                    @"\u2614", //@"\ue04b",
                    @"\u2601", //@"\ue049",
                    @"\u26c4", //@"\ue048",

                    @"\U0001F319", //@"\ue005",
                    @"\u26A1", //@"\ue004",
                    nil];
}
- (UIImage *)imageNamed:(NSString *)name{
    NSString *pngName = [name stringByAppendingString:@"@2x.png"];
    NSString *jpgName = [name stringByAppendingString:@"@2x.jpg"];
    NSString *file = [[NSBundle mainBundle] pathForResource:pngName ofType:nil];
    if (file.length == 0) {
        file = [[NSBundle mainBundle] pathForResource:jpgName ofType:nil];
    }
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:file];

    return image;
}
@end
