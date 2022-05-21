import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:sports_matching/repo/item_service.dart';
import 'package:sports_matching/screens/item/similar_item.dart';
import 'package:sports_matching/states/category_notifier.dart';
import 'package:sports_matching/states/user_notifier.dart';
import 'package:sports_matching/utils/time_calculation.dart';
import '../../constants/common_size.dart';
import 'package:extended_image/extended_image.dart';
import '../../data/item_model.dart';
import '../../data/user_model.dart';
class ItemDetailScreen extends StatefulWidget {
  final String itemKey;
  const ItemDetailScreen(this.itemKey, {Key? key}) : super(key: key);

  @override
  _ItemDetailScreenState createState() => _ItemDetailScreenState();
}


class _ItemDetailScreenState extends State<ItemDetailScreen> {
  PageController _pageController = PageController();
  ScrollController _scrollController = ScrollController();
  bool isAppbarCollapsed = false;
  Size? _size;
  num? _statusBarHeight;
  Widget _textGap = SizedBox(height: common_padding);
  Widget _divider = Divider(
      height: common_padding,
      thickness: 2,
      color: Colors.grey[100],
  );
  @override
  void initState() {
    print('_size: $_size');
    print('_statusBarHeight $_statusBarHeight');
    _scrollController.addListener(() {
      if(_size == null || _statusBarHeight == null)
        return;
      if(isAppbarCollapsed){
        if(_scrollController.offset < _size!.width - kToolbarHeight - _statusBarHeight!){
          isAppbarCollapsed = false;
          setState(() {});
        }

      }else{
        if(_scrollController.offset > _size!.width - kToolbarHeight - _statusBarHeight!){
          isAppbarCollapsed = true;
          setState(() {});
        }
      }
    });
    super.initState();
  }
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ItemModel>(
      future: ItemService().getItem(widget.itemKey),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          ItemModel itemModel = snapshot.data!;
          UserModel userModel = context.read<UserNotifier>().userModel!;
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              _size = MediaQuery.of(context).size;
              _statusBarHeight = MediaQuery.of(context).padding.top;
              return Stack(
                fit: StackFit.expand,
                children: [
                  Scaffold(
                    bottomNavigationBar: SafeArea(
                      top: false,
                      bottom: true,
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(border: Border(top: BorderSide(color:  Colors.grey[300]!))),
                        child: Padding(
                          padding: const EdgeInsets.all(common_small_padding),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.favorite_border),
                                onPressed: (){}
                              ),
                              VerticalDivider(thickness: 1, width: common_small_padding*2+1, indent: common_small_padding, endIndent: common_small_padding,),
                              SizedBox(width: common_small_padding,),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('요구레벨 : 10', style: TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w200)),
                                  Text('보디빌딩', style: TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w200))
                                ],
                              ),
                              Expanded(child: Container()),
                              TextButton(onPressed: (){}, child: Text('참가하기'))
                            ],
                          ),
                        ),
                      ),
                    ),
                    body: CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        _imagesAppbar(itemModel),
                        // SliverToBoxAdapter(
                        //   child: Container(
                        //     height: _size!.height * 2,
                        //     color: Colors.cyan,
                        //     child:
                        //     Center(child: Text('item key is${widget.itemKey}')),
                        //   ),
                        // ),
                        SliverPadding(
                          padding: EdgeInsets.all(common_padding),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                                _userSection(userModel),
                                _divider,
                              Text(itemModel.title, style: Theme.of(context).textTheme.headline6),
                              _textGap,
                              Row(
                                children: [
                                  Text(categoriesMapEngToKor[itemModel.category]??"선택", style: TextStyle(color: Colors.black54, fontSize: 9, fontWeight: FontWeight.w200, decoration: TextDecoration.underline)),
                                  Text(' · ${TimeCalculation().getTimeDiff(itemModel.createdDate)}', style: TextStyle(color: Colors.black54, fontSize: 9, fontWeight: FontWeight.w200)),
                                ],
                              ),
                              _textGap,
                              Text(itemModel.detail, style: TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w200)),
                              _textGap,
                              Text('조회수', style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w100)),
                              _textGap,
                              Divider(
                                height: 2,
                                thickness: 2,
                                color: Colors.grey[200],
                              ),
                              MaterialButton(onPressed: (){},padding: EdgeInsets.zero, child: Align(alignment: Alignment.centerLeft, child: Text('이 게시글 신고하기', style: TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w200)))),
                              Divider(
                                height: 2,
                                thickness: 2,
                                color: Colors.grey[200],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${userModel.email}의 다른 게시글'),
                                  SizedBox(
                                    width: _size!.width/4,
                                    child: MaterialButton(
                                      onPressed: () {  },
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text('더보기',  style: TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w200, decoration: TextDecoration.underline)),
                                      ),

                                    ),
                                  )
                                ],
                              ),
                            ]),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.all(common_small_padding),
                          sliver: SliverGrid.count(
                              crossAxisCount: 2,
                              mainAxisSpacing: common_small_padding,
                              crossAxisSpacing: common_small_padding,
                              childAspectRatio: 6/7,
                              children: List.generate(10, (index)=> SimilarItem())
                          ),
                        )
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    height: kToolbarHeight + _statusBarHeight!,
                    child: Container(
                      height: kToolbarHeight + _statusBarHeight!,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black12,
                                Colors.black12,
                                Colors.black12,
                                Colors.black12,
                                Colors.transparent
                              ])),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    height: kToolbarHeight+_statusBarHeight!,
                    child: Scaffold(
                      backgroundColor: Colors.transparent,
                      appBar: AppBar(
                        backgroundColor: isAppbarCollapsed?Colors.red:Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: isAppbarCollapsed?Colors.black87:Colors.white,
                      ),
                    ),
                  )
                ],
              );
            },
          );
        }
        return Container();
      },
    );
  }

  SliverAppBar _imagesAppbar(ItemModel itemModel) {
    return SliverAppBar(
                        pinned: true,
                        expandedHeight: _size!.width,
                        flexibleSpace: FlexibleSpaceBar(
                          title: SizedBox(
                            child: SmoothPageIndicator(
                                controller: _pageController, // PageController
                                count: itemModel.imageDownloadurls.length,
                                effect: WormEffect(
                                    activeDotColor: Colors.white,
                                    dotColor: Colors.white24,
                                    radius: 2,
                                    dotHeight: 4,
                                    dotWidth: 4
                                ), // your preferred effect
                                onDotClicked: (index) {}),
                          ),
                              centerTitle: true,
                              background: PageView.builder(
                                controller: _pageController,
                                allowImplicitScrolling: true,
                                itemBuilder: (BuildContext context, int index) {
                                  return ExtendedImage.network(
                                    itemModel.imageDownloadurls[index],
                                    fit: BoxFit.cover,
                                    scale: 0.1,
                                  );
                                },
                                itemCount: itemModel.imageDownloadurls.length,
                              ),
                        ),
                      );
  }

  Widget _userSection(UserModel userModel) {
    return Row(
                              children: [
                                ExtendedImage.network(
                                  'https://picsum.photos/50',
                                  fit: BoxFit.cover,
                                  width: _size!.width/10,
                                  height: _size!.width/10,
                                  shape: BoxShape.circle,
                                ),
                                SizedBox(width: common_small_padding,),
                                SizedBox(
                                  height: _size!.width/9,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(userModel.email, style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w400)),
                                      Text(userModel.address, style: TextStyle(color: Colors.black54, fontSize: 11, fontWeight: FontWeight.w100))
                                    ]
                                  ),
                                ),
                                Expanded(child: Container()),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 40,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: [
                                              FittedBox(
                                                  child: Text(
                                                    userModel.userMannerScore.toString(),
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.red,
                                                        fontSize: 10
                                                    ),
                                                  )
                                              ),
                                              SizedBox(height: 6,),
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(2),
                                                child: LinearProgressIndicator(
                                                  color: Colors.red,
                                                  value: 0.373,
                                                  minHeight: 3,
                                                  backgroundColor: Colors.grey[200],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 6,),
                                        ImageIcon(ExtendedAssetImageProvider('assets/imgs/happiness.png'), color: Colors.red)
                                      ],
                                    ),
                                    SizedBox(height: 6,),
                                    Text('매너점수', style: TextStyle(decoration: TextDecoration.underline, color: Colors.black54, fontSize: 11, fontWeight: FontWeight.w100),
                                    )
                                  ],
                                )
                              ],
                            );
  }
}