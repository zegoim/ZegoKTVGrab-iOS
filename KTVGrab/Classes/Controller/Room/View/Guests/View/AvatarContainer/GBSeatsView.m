//
//  ZGKTVRoomGuestView.m
//  GoChat
//
//  Created by Vic on 2021/10/25.
//  Copyright © 2021 zego. All rights reserved.
//

#import "GBSeatsView.h"
#import "GBSeatCell.h"
#import <Masonry/Masonry.h>

@interface GBSeatsView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *gridView;
@property (nonatomic, strong) NSMutableArray<GBSeatCellVM *> *cellVMs;
@property (nonatomic, strong) NSMutableDictionary *cellIndexTable;

@end

@implementation GBSeatsView

- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.seatsCount = 6;
    self.columns = 3;
    self.cellIndexTable = [NSMutableDictionary dictionary];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveQualityViewVisibilityUpdateNotification:)
                                                 name:kGBSeatQualityVisibilityNotificationName object:nil];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  NSInteger columns = self.columns;
  if (columns <= 0) {
    assert(0);
  }
  NSInteger rows = ceil(self.seatsCount / (CGFloat)columns);
  if (rows <= 0) {
    assert(0);
  }
  CGFloat w = CGRectGetWidth(self.bounds) / columns;
  CGFloat h = CGRectGetHeight(self.bounds) / rows;

  UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
  layout.itemSize = CGSizeMake(w, h);
  layout.minimumInteritemSpacing = 0;
  layout.minimumLineSpacing = 0;

  [self.gridView setCollectionViewLayout:layout];
}

- (void)updateConstraints {
  [self.gridView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self).offset(1);
    make.bottom.equalTo(self);
    make.left.equalTo(self);
    make.right.equalTo(self);
  }];
  [super updateConstraints];
}

- (UICollectionView *)gridView {
  if (!_gridView) {
    UICollectionView *view = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[UICollectionViewFlowLayout new]];
    view.backgroundColor = [UIColor clearColor];
    view.dataSource = self;
    view.delegate = self;
    view.scrollEnabled = NO;
    [view registerClass:GBSeatCell.class forCellWithReuseIdentifier:NSStringFromClass(GBSeatCell.class)];
    [self addSubview:view];
    _gridView = view;
  }
  return _gridView;
}

- (NSMutableArray<GBSeatCellVM *> *)cellVMs {
  if (!_cellVMs) {
    _cellVMs = [NSMutableArray array];
    for (int i = 0; i < self.seatsCount; i++) {
      GBSeatCellVM *cellVM = [[GBSeatCellVM alloc] initWithIndex:i + 1];
      [_cellVMs addObject:cellVM];
    }
  }
  return _cellVMs;
}

#pragma mark - Public
- (void)updateSeatList:(NSArray<GBSeatInfo *> *)seatList {
  self.cellVMs = nil;
  
  for (GBSeatInfo *seat in seatList) {
    NSUInteger seatIndex = seat.seatIndex;
    NSInteger index = seatIndex - 1;
    if (index < 0 || index >= self.cellVMs.count) {
      continue;
    }
    GBSeatCellVM *cellVM = [self.cellVMs objectAtIndex:index];
    [cellVM setSeatInfo:seat];
  }
  [self reloadUI];
}

- (void)updateSeatMisc:(GBSeatInfo *)seat {
  if (!seat) {
    return;
  }
  GBSeatCell *cell = [self.cellIndexTable objectForKey:@(seat.seatIndex)];
  [cell.cellVM setSeatInfo:seat];
  [cell setCellVM:cell.cellVM];
}

- (void)reloadUI {
  [self.cellIndexTable removeAllObjects];
  [self.gridView reloadData];
}

#pragma mark - UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  NSUInteger count = self.seatsCount;
  return count;
}

- (GBSeatCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  GBSeatCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(GBSeatCell.class) forIndexPath:indexPath];
  GBSeatCellVM *cellVM = self.cellVMs[indexPath.item];
  [self.cellIndexTable setObject:cell forKey:@(cellVM.index)];
  [cell setCellVM:cellVM];
  return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  if (self.onSelectItemAtIndex) {
    self.onSelectItemAtIndex(indexPath.item);
  }
}

- (void)didReceiveQualityViewVisibilityUpdateNotification:(NSNotification *)noti {
  BOOL visible = [noti.userInfo[kGBSeatQualityVisibilityNotificationKey] boolValue];
  for (GBSeatCellVM *cellVM in self.cellVMs) {
    cellVM.showTestData = visible;
    [self updateSeatMisc:cellVM.seatInfo];
  }
}

@end
