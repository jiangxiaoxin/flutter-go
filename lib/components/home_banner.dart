import 'dart:async';
import 'package:flutter/material.dart';
import '../model/story.dart';

/// 首页的轮播图
class HomeBanner extends StatefulWidget {
  final List<StoryModel> bannerStories;
  final OnTapBannerItem onTap;

  HomeBanner(this.bannerStories, this.onTap, {Key key})
      :super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _BannerState();
  }
}

class _BannerState extends State<HomeBanner> {
  int virtualIndex = 0;
  int realIndex = 1;
  PageController controller;
  Timer timer;

  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: realIndex); // 初始默认显示页就是1，就是因为手动在最前添加了最后那个页的副本
    timer = Timer.periodic(Duration(seconds: 5), (timer) { // 自动滚动
      // TODO：试试这样子都显示啥！
      // TODO：如果跳的页超出了length呢？jumpTo和animateTo会有什么区别？
      print(realIndex);
      controller.animateToPage(realIndex + 1,
          duration: Duration(milliseconds: 300),
          curve: Curves.linear);
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 226.0,
      child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            PageView(
              controller: controller,
              onPageChanged: _onPageChanged,
              children: _buildItems()
            ),
            _buildIndicator(), // 下面的小点
          ]),
    );
  }

  List<Widget> _buildItems() { // 排列轮播数组
    List<Widget> items = [];
    if (widget.bannerStories.length > 0) {
      // 头部添加一个尾部Item，模拟循环
      items.add(
          _buildItem(widget.bannerStories[widget.bannerStories.length - 1])
      );
      // 正常添加Item
      items.addAll(
          widget.bannerStories.map((story) => _buildItem(story)).toList(
              growable: false)
      );
      // 尾部
      items.add(_buildItem(widget.bannerStories[0]));
    }
    return items;
  }

  Widget _buildItem(StoryModel story) {
    return GestureDetector(
      onTap: () { // 按下
        if (widget.onTap != null) {
          widget.onTap(story);
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
         Image.network(story.image, fit: BoxFit.cover),
          _buildItemTitle(story.title), // 内容文字,大意
        ],),);
  }

  Widget _buildItemTitle(String title) {
    return Container(
      decoration: BoxDecoration( /// 背景的渐变色
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: const Alignment(0.0, -0.8),
          colors: [const Color(0xa0000000), Colors.transparent],
        ),
      ),
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 22.0, horizontal: 16.0),
        child: Text(
          title, style: TextStyle(color: Colors.white, fontSize: 18.0),),),
    );
  }

  Widget _buildIndicator() {
    List<Widget> indicators = [];
    for (int i = 0; i < widget.bannerStories.length; i++) {
      indicators.add(Container(
          width: 6.0,
          height: 6.0,
          margin: EdgeInsets.symmetric(horizontal: 1.5, vertical: 10.0),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i == virtualIndex ? Colors.white : Colors.grey)));
    }
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: indicators);
  }

  //TODO：看下这个index是啥？应该是页面滚动之后的那个目标页码。
  _onPageChanged(int index) {
    realIndex = index;
    int count = widget.bannerStories.length;
    if (index == 0) {
      virtualIndex = count - 1; // 用来更新轮播图indicator的，因为在创建轮播图时，在itemlist里前后都添加了一个元素，所以如果index==0，其实指示的应该是最后一个。如果index===count+1，指示的应该是第一个，其他情况下都应该index-1
      /// TODO：itemlist在前后都添加了一个额外的元素，那这里还有必要去修正jump的page吗？index==0，显示的就是最后一个的，jumpToPage（count）也只是调到原本应该显示的最后一个，这不都一样的吗？
      /// count是原本要正常展示的最后一个页，0也是最后一个页，不过是因为手动在最前面添加了最后那个页。jumpToPage跳过去，中间就没有了缓动效果。
      /// TODO：这里jumpToPage应该是为了修正realIndex的问题。设定timer去定时翻页，却从来没有重置realIndex值，用jump来改。但是这样真的好吗？
      controller.jumpToPage(count);
    } else if (index == count + 1) {
      virtualIndex = 0;
      controller.jumpToPage(1);
    } else {
      virtualIndex = index - 1;
    }
    setState(() {});
  }
}

typedef void OnTapBannerItem(StoryModel story);