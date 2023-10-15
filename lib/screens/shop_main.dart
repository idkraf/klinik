import 'package:klinikkecantikan/my_theme.dart';
import 'package:klinikkecantikan/presenter/cart_counter.dart';
import 'package:klinikkecantikan/screens/filter.dart';
import 'package:klinikkecantikan/screens/category_products.dart';
import 'package:klinikkecantikan/screens/category_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:klinikkecantikan/repositories/sliders_repository.dart';
import 'package:klinikkecantikan/repositories/category_repository.dart';
import 'package:klinikkecantikan/repositories/product_repository.dart';

import 'package:klinikkecantikan/ui_elements/product_card.dart';
import 'package:klinikkecantikan/helpers/shimmer_helper.dart';
import 'package:klinikkecantikan/helpers/shared_value_helper.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:klinikkecantikan/custom/box_decorations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'cart.dart';
import 'messenger_list.dart';

class ShopMain extends StatefulWidget {

  ShopMain({Key? key, this.title, this.show_back_button = false, go_back = true, this.counter})
      : super(key: key);
  final CartCounter? counter;

  final String? title;
  bool? show_back_button;
  bool? go_back;

  @override
  _ShopMainState createState() => _ShopMainState();
}

class _ShopMainState extends State<ShopMain> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  ScrollController? _allProductScrollController;
  ScrollController? _mainScrollController = ScrollController();
  ScrollController? _featuredCategoryScrollController;

  var _bannerTwoImageList = [];
  bool _isBannerTwoInitial = true;
  int _current_slider = 0;

  var _featuredCategoryList = [];
  bool _isCategoryInitial = true;

  var _allProductList = [];

  bool _isAllProductInitial = true;
  int _totalAllProductData = 0;
  int _allProductPage = 1;
  bool _showAllLoadingContainer = false;

  @override
  void initState() {

    fetchAll();
    _mainScrollController!.addListener(() {
      if (_mainScrollController!.position.pixels ==
          _mainScrollController!.position.maxScrollExtent) {
        setState(() {
          _allProductPage++;
        });
        _showAllLoadingContainer = true;
        fetchAllProducts();
      }
    });
  }

  fetchAll() {
    fetchBannerTwoImages();
    fetchFeaturedCategories();
    fetchAllProducts();
  }

  fetchBannerTwoImages() async {
    var bannerTwoResponse = await SlidersRepository().getBannerTwoImages();
    bannerTwoResponse.sliders!.forEach((slider) {
      _bannerTwoImageList.add(slider.photo);
    });
    _isBannerTwoInitial = false;
    setState(() {});
  }

  fetchFeaturedCategories() async {
    var categoryResponse = await CategoryRepository().getFeturedCategories();
    _featuredCategoryList.addAll(categoryResponse.categories!);
    _isCategoryInitial = false;
    setState(() {});
  }

  fetchAllProducts() async {
    var productResponse =
    await ProductRepository().getFilteredProducts(page: _allProductPage);

    _allProductList.addAll(productResponse.products!);
    _isAllProductInitial = false;
    _totalAllProductData = productResponse.meta!.total!;
    _showAllLoadingContainer = false;
    setState(() {});
  }

  reset(){
    _bannerTwoImageList.clear();
    _isBannerTwoInitial = true;
    _isCategoryInitial = true;
    _featuredCategoryList.clear();
    _allProductList.clear();
    resetAllProductList();
  }

  resetAllProductList() {
    _isAllProductInitial = true;
    _totalAllProductData = 0;
    _allProductPage = 1;
    _showAllLoadingContainer = false;
    setState(() {});
  }


  @override
  void dispose() {

  }

  Future<void> _onRefresh() async {
    reset();
    fetchAll();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return SafeArea(
        child: Scaffold(
            key: _scaffoldKey,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(56),
              child: buildAppBar(statusBarHeight, context),
            ),
            body: Stack(
              children: [
                RefreshIndicator(
                  color: MyTheme.primary_color,
                  backgroundColor: Colors.white,
                  onRefresh: _onRefresh,
                  displacement: 0,
                  child: CustomScrollView(
                    controller: _mainScrollController,
                    physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                    slivers: <Widget>[
                      SliverList(
                        delegate: SliverChildListDelegate([
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              18.0,
                              20.0,
                              18.0,
                              0.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.home_screen_featured_categories,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        ]),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 154,
                          child: buildHomeFeaturedCategories(context),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildListDelegate([
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              18.0,
                              18.0,
                              20.0,
                              0.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.home_screen_all_products,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                buildHomeAllProducts2(context),
                              ],
                            ),
                          ),
                          Container(
                            height: 80,
                          )
                        ]),
                      ),
                    ],
                  ),
                ),
                Align(
                    alignment: Alignment.center,
                    child: buildProductLoadingContainer())
              ],
            )
        )
    );

  }

  AppBar buildAppBar(double statusBarHeight, BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: false,
      elevation: 0,
      actions: [
        IconButton(
          icon: Image.asset( "assets/cart.png",height: 25), //Icon( Icons.shopping_cart), //
          onPressed: () {
            // do something
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return Cart(has_bottomnav: false,from_navigation:false,counter: widget.counter);
                },
              ),
            );
          },
        ),
      ],
      title:
      Padding(
          padding: const EdgeInsets.only(top: 0, bottom: 0, left: 0, right: 0),
          child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return Filter();
                }));
              },
              child: buildHomeSearchBox(context))
      ),
    );
  }
  buildHomeSearchBox(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecorations.buildBoxDecoration_1(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.home_screen_search,
              style: TextStyle(fontSize: 13.0, color: MyTheme.textfield_grey),
            ),
            Image.asset(
              'assets/search.png',
              height: 16,
              //color: MyTheme.dark_grey,
              color: MyTheme.dark_grey,
            ),
          ],
        ),
      ),
    );

  }
  Widget buildHomeBannerTwo(context) {
    if (_isBannerTwoInitial && _bannerTwoImageList.length == 0) {
      return Padding(
          padding:
          const EdgeInsets.only(left: 0, right: 0, top: 20, bottom: 20),
          child: ShimmerHelper().buildBasicShimmer(height: 440));
    } else if (_bannerTwoImageList.length > 0) {
      return Padding(
        padding: app_language_rtl.$
            ? const EdgeInsets.only(right: 9.0)
            : const EdgeInsets.only(left: 9.0),
        child: CarouselSlider(
          options: CarouselOptions(
              aspectRatio: 440 / 440,
              viewportFraction: 0.7,
              enableInfiniteScroll: true,
              reverse: false,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 5),
              autoPlayAnimationDuration: Duration(milliseconds: 1000),
              autoPlayCurve: Curves.easeInExpo,
              enlargeCenterPage: false,
              scrollDirection: Axis.horizontal,
              onPageChanged: (index, reason) {
                setState(() {
                  _current_slider = index;
                });
              }),
          items: _bannerTwoImageList.map((i) {
            return Builder(
              builder: (BuildContext context) {
                return Padding(
                  padding: const EdgeInsets.only(
                      left: 10, right: 10, top: 20, bottom: 20),
                  child: Container(
                      width: double.infinity,
                      //decoration: BoxDecorations.buildBoxDecoration_1(),
                      child: ClipRRect(
                        //borderRadius: BorderRadius.all(Radius.circular(6)),
                          child: FadeInImage.assetNetwork(
                            placeholder: 'assets/placeholder_rectangle.png',
                            image: i,
                            fit: BoxFit.cover,
                          ))),
                );
              },
            );
          }).toList(),
        ),
      );
    }else {
      // should not be happening
      return Container(
        height: 100,
      );
    }
  }
  Widget buildHomeFeaturedCategories(context) {
    if (_isCategoryInitial && _featuredCategoryList.length == 0) {
      return ShimmerHelper().buildHorizontalGridShimmerWithAxisCount(
          crossAxisSpacing: 14.0,
          mainAxisSpacing: 14.0,
          item_count: 10,
          mainAxisExtent: 170.0,
          controller: _featuredCategoryScrollController);
    } else if (_featuredCategoryList.length > 0) {
      //snapshot.hasData
      return GridView.builder(
          padding:
          const EdgeInsets.only(left: 18, right: 18, top: 13, bottom: 20),
          scrollDirection: Axis.horizontal,
          controller: _featuredCategoryScrollController,
          itemCount: _featuredCategoryList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 3,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              mainAxisExtent: 170.0),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return CategoryProducts(
                    category_id: _featuredCategoryList[index].id,
                    category_name: _featuredCategoryList[index].name,
                  );
                }));
              },
              child: Container(
                decoration: BoxDecorations.buildBoxDecoration_1(),
                child: Row(
                  children: <Widget>[
                    Container(
                        child: ClipRRect(
                            borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(6), right: Radius.zero),
                            child: FadeInImage.assetNetwork(
                              placeholder: 'assets/placeholder.png',
                              image: _featuredCategoryList[index].banner,
                              fit: BoxFit.cover,
                            ))),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _featuredCategoryList[index].name,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                          softWrap: true,
                          style:
                          TextStyle(fontSize: 12, color: MyTheme.font_grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
    } else if (!_isCategoryInitial && _featuredCategoryList.length == 0) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
                AppLocalizations.of(context)!.home_screen_no_category_found,
                style: TextStyle(color: MyTheme.font_grey),
              )));
    } else {
      // should not be happening
      return Container(
        height: 100,
      );
    }
  }
  Container buildProductLoadingContainer() {
    return Container(
      height: _showAllLoadingContainer ? 36 : 0,
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: Text(_totalAllProductData == _allProductList.length
            ? AppLocalizations.of(context)!.common_no_more_products
            : AppLocalizations.of(context)!.common_loading_more_products),
      ),
    );
  }
  Widget buildHomeAllProducts(context) {
    if (_isAllProductInitial && _allProductList.length == 0) {
      return SingleChildScrollView(
          child: ShimmerHelper().buildProductGridShimmer(
              scontroller: _allProductScrollController));
    } else if (_allProductList.length > 0) {
      //snapshot.hasData
      return GridView.builder(
        // 2
        //addAutomaticKeepAlives: true,
        itemCount: _allProductList.length,
        controller: _allProductScrollController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.618),
        padding: EdgeInsets.all(16.0),
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          // 3
          return ProductCard(
            id: _allProductList[index].id,
            image: _allProductList[index].thumbnail_image,
            name: _allProductList[index].name,
            main_price: _allProductList[index].main_price,
            stroked_price: _allProductList[index].stroked_price,
            has_discount: _allProductList[index].has_discount,
            discount: _allProductList[index].discount,
          );
        },
      );
    } else if (_totalAllProductData == 0) {
      return Center(
          child: Text(
              AppLocalizations.of(context)!.common_no_product_is_available));
    } else {
      return Container(); // should never be happening
    }
  }

  Widget buildHomeAllProducts2(context) {
    if (_isAllProductInitial && _allProductList.length == 0) {
      return SingleChildScrollView(
          child: ShimmerHelper().buildProductGridShimmer(
              scontroller: _allProductScrollController));
    } else if (_allProductList.length > 0) {
      return MasonryGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          itemCount: _allProductList.length,
          shrinkWrap: true,
          padding: EdgeInsets.only(top: 20.0, bottom: 10, left: 18, right: 18),
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return ProductCard(
              id: _allProductList[index].id,
              image: _allProductList[index].thumbnail_image,
              name: _allProductList[index].name,
              main_price: _allProductList[index].main_price,
              stroked_price: _allProductList[index].stroked_price,
              has_discount: _allProductList[index].has_discount,
              discount: _allProductList[index].discount,
            );
          });
    } else if (_totalAllProductData == 0) {
      return Center(
          child: Text(
              AppLocalizations.of(context)!.common_no_product_is_available));
    } else {
      return Container(); // should never be happening
    }
  }
}