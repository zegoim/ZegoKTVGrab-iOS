//
//  ZegoAudioReverbSelectView.m
//  HalfScreenTransitioning
//
//  Created by Vic on 2022/2/21.
//

#import "GBAudioReverbSelectView.h"
#import "GBAudioTitleLabel.h"
#import "GBAudioConfigItem.h"
#import "GBAudioConfigItemVM.h"
#import <Masonry/Masonry.h>
#import "GBExpress.h"

static NSString * const kKTVAudioReverbSelectionCellID = @"KTVAudioReverbSelectionCellID";

@interface GBAudioReverbSelectView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) id<GBAudioReverbListener> listener;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, copy) NSArray<GBAudioConfigItemVM *> *itemVMs;
@property (nonatomic, copy) NSArray *reverbDataSource;
@property (nonatomic, strong) GBAudioConfigItemVM *lastSelectedItemVM;

@end

@implementation GBAudioReverbSelectView

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    [self setupUI];
  }
  return self;
}

- (void)setupUI {
  self.translatesAutoresizingMaskIntoConstraints = NO;
  
  [self setupSubviews];
  [self setDefaultReverb];
}

- (void)setupSubviews {
  GBAudioTitleLabel *label = [[GBAudioTitleLabel alloc] init];
  label.text = @"混响";
  
  UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
  layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
  layout.itemSize = CGSizeMake(50, 74);
  layout.minimumLineSpacing = 27;
  layout.sectionInset = UIEdgeInsetsMake(0, 16, 0, 16);
  UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
  collectionView.backgroundColor = UIColor.clearColor;
  [collectionView registerClass:[GBAudioConfigItem class] forCellWithReuseIdentifier:kKTVAudioReverbSelectionCellID];
  collectionView.showsHorizontalScrollIndicator = NO;
  collectionView.delegate = self;
  collectionView.dataSource = self;
  self.collectionView = collectionView;
  
  [self addSubview:label];
  [self addSubview:collectionView];

  [label mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self).offset(9.5);
    make.left.equalTo(self).offset(16);
  }];
  
  [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.right.equalTo(self);
    make.top.equalTo(label.mas_bottom).offset(15.5);
    make.height.mas_equalTo(75);
    make.bottom.equalTo(self);
  }];
}

- (void)setDefaultReverb {
  [self selectReverbAtIndex:3 manual:NO];
}

- (void)selectReverbAtIndex:(NSUInteger)index manual:(BOOL)manual {
  if (index >= 0 && index < self.itemVMs.count) {
    [self enableReverbAtIndex:index];
    GBAudioConfigItemVM *itemVM = self.itemVMs[index];
    [self selectItemVM:itemVM];
    [self.collectionView reloadData];
    [self.listener onReverbSelectedAtIndex:index manual:manual];
  }
}

- (void)enableReverbAtIndex:(NSUInteger)index {
  if (index >= 0 && index < self.itemVMs.count) {
    GBAudioConfigItemVM *itemVM = self.itemVMs[index];
    [[GBExpress shared] setReverbPreset:itemVM.preset];
  }
}

- (void)selectItemVM:(GBAudioConfigItemVM *)vm {
  self.lastSelectedItemVM.itemSelected = NO;
  vm.itemSelected = YES;
  self.lastSelectedItemVM = vm;
}

#pragma mark - UICollectionView delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return self.itemVMs.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  GBAudioConfigItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kKTVAudioReverbSelectionCellID forIndexPath:indexPath];
  GBAudioConfigItemVM *vm = self.itemVMs[indexPath.item];
  cell.viewModel = vm;
  return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  [self selectReverbAtIndex:indexPath.item manual:YES];
}

- (NSArray<GBAudioConfigItemVM *> *)itemVMs {
  if (!_itemVMs) {
    NSMutableArray *mArr = [NSMutableArray array];
    
    [self.reverbDataSource enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
      GBAudioConfigItemVM *vm = [[GBAudioConfigItemVM alloc] init];
      vm.imageName = [NSString stringWithFormat:@"ktv_effect_%lu", (unsigned long)idx];
      vm.text = obj[@"name"];
      vm.preset = [obj[@"preset"] intValue];
      [mArr addObject:vm];
    }];
    
    _itemVMs = mArr.copy;
  }
  return _itemVMs;
}
  
- (NSArray *)reverbDataSource {
  if (!_reverbDataSource) {
    _reverbDataSource = @[
      @{
        @"name":@"原声",
        @"preset":@0
      },
      @{
        @"name":@"流行",
        @"preset":@8
      },
      @{
        @"name":@"摇滚",
        @"preset":@9
      },
      @{
        @"name":@"录音棚",
        @"preset":@5
      },
      @{
        @"name":@"演唱会",
        @"preset":@10
      },
      @{
        @"name":@"KTV",
        @"preset":@7
      },
      @{
        @"name":@"房间",
        @"preset":@1
      },
      @{
        @"name":@"大教堂",
        @"preset":@6
      },
      @{
        @"name":@"音乐厅",
        @"preset":@3
      },
    ];
  }
  return _reverbDataSource;
}

@end
