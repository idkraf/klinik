import 'package:klinikkecantikan/custom/box_decorations.dart';
import 'package:klinikkecantikan/custom/common_functions.dart';
import 'package:klinikkecantikan/custom/device_info.dart';
import 'package:klinikkecantikan/custom/text_styles.dart';
import 'package:klinikkecantikan/custom/useful_elements.dart';
import 'package:klinikkecantikan/presenter/cart_counter.dart';
import 'package:klinikkecantikan/screens/select_address.dart';
import 'package:klinikkecantikan/screens/shipping_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:klinikkecantikan/my_theme.dart';
import 'package:klinikkecantikan/ui_sections/drawer.dart';
import 'package:flutter/widgets.dart';
import 'package:klinikkecantikan/repositories/cart_repository.dart';
import 'package:klinikkecantikan/helpers/shared_value_helper.dart';
import 'package:klinikkecantikan/helpers/shimmer_helper.dart';
import 'package:klinikkecantikan/custom/toast_component.dart';
import 'package:toast/toast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:klinikkecantikan/custom/common_functions.dart';

import '../custom/currency_format.dart';

class Cart extends StatefulWidget {
  Cart({Key? key, this.has_bottomnav,this.from_navigation = false, this.counter}) : super(key: key);
  final bool? has_bottomnav;
  final bool? from_navigation;
  final CartCounter? counter;

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController _mainScrollController = ScrollController();
  var _shopList = [];
  bool _isInitial = true;
  var _cartTotal = 0.00;
  var _cartTotalString = "0";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    /*print("user data");
    print(is_logged_in.$);
    print(access_token.value);
    print(user_id.$);
    print(user_name.$);*/

    if (is_logged_in.$ == true) {
      fetchData();
    }
  }


  @override
  void dispose() {
    super.dispose();
    _mainScrollController.dispose();
  }


  getCartCount()async {
    //var res = await CartRepository().getCartCount();
    //widget.counter!.controller!.sink.add(res.count!);
  }


  int? owner_id;
  fetchData() async {
    getCartCount();
    var cartResponseList =
        await CartRepository().getCartResponseList(user_id.$);

    if (cartResponseList != null && cartResponseList.length > 0) {
      _shopList = cartResponseList;
      owner_id = cartResponseList.first.owner_id;
    }
    _isInitial = false;
    getSetCartTotal();
    setState(() {});
  }

  getSetCartTotal() {
    _cartTotal = 0.00;
    if (_shopList.length > 0) {
      _shopList.forEach((shop) {
        if (shop.cart_items.length > 0) {
          shop.cart_items.forEach((cart_item) {

            _cartTotal += double.parse( ((cart_item.price_product + cart_item.tax) * cart_item.quantity).toStringAsFixed(2));
            _cartTotalString = "${_cartTotal.toStringAsFixed(0)}";

          //  if(cart_item.wholesale.toString().isNotEmpty) {
              cart_item.wholesale.forEach((element) {
                dynamic minQty = element['min_qty'];
                dynamic maxQty = element['max_qty'];
                dynamic wprice = double.parse(element['price']);

                if (cart_item.quantity >= int.parse(minQty) && cart_item.quantity <= int.parse(maxQty)) {
                 // partialTotal = (wprice.toDouble() + cart_item.tax) * cart_item.quantity;
                 // partialTotalString = partialTotal.toStringAsFixed(0);
                  _cartTotal = double.parse( ((wprice + cart_item.tax) * cart_item.quantity).toStringAsFixed(2));
                  _cartTotalString = "${_cartTotal.toStringAsFixed(0)}";
                }
              });
          //  }
          });
        }
      });
    }

    setState(() {});
  }

  partialTotalString(index) {
    var partialTotal = 0.00;
    var partialTotalString = "0";
    if (_shopList[index].cart_items.length > 0) {
      _shopList[index].cart_items.forEach((cart_item) {

        partialTotal += (cart_item.price_product + cart_item.tax) * cart_item.quantity;
        partialTotalString ="${partialTotal.toStringAsFixed(0)}";

        if(cart_item.wholesale.toString().isNotEmpty) {
          cart_item.wholesale.forEach((element) {
            dynamic minQty = element['min_qty'];
            dynamic maxQty = element['max_qty'];
            dynamic wprice = double.parse(element['price']);

            if (cart_item.quantity >= int.parse(minQty) && cart_item.quantity <= int.parse(maxQty)) {
              //print("cek min: $minQty and ${wprice.toDouble()}");
              //_singlePrice = wprice;
              partialTotal = (wprice.toDouble() + cart_item.tax) * cart_item.quantity;
              //print("cek: $partialTotal and ${wprice.toDouble()}");
              partialTotalString = partialTotal.toStringAsFixed(0);
            }
          });
        }

      });
    }

    return partialTotalString;
  }

  partialProdukString(seller_index, item_index) {

    var partialTotal = 0.00;
    var partialTotalString = "0";

    if (_shopList[seller_index].cart_items.length > 0) {

      partialTotal += _shopList[seller_index].cart_items[item_index].price_product * _shopList[seller_index] .cart_items[item_index].quantity;
      partialTotalString ="${partialTotal.toStringAsFixed(0)}";

      if(_shopList[seller_index].cart_items[item_index].wholesale.toString().isNotEmpty) {
        _shopList[seller_index].cart_items[item_index].wholesale.forEach((element) {
          dynamic minQty = element['min_qty'];
          dynamic maxQty = element['max_qty'];
          dynamic wprice = double.parse(element['price']);

          if (_shopList[seller_index].cart_items[item_index].quantity >= int.parse(minQty) && _shopList[seller_index].cart_items[item_index].quantity <= int.parse(maxQty)) {
            print("cek min: $minQty");
            //_singlePrice = wprice;
            partialTotal = wprice.toDouble() * _shopList[seller_index].cart_items[item_index].quantity;
            partialTotalString = partialTotal.toStringAsFixed(0);
          }
        });
      }

    }

    return partialTotalString;
  }

  onQuantityIncrease(seller_index, item_index) {
    if (_shopList[seller_index].cart_items[item_index].quantity <
        _shopList[seller_index].cart_items[item_index].upper_limit) {
      _shopList[seller_index].cart_items[item_index].quantity++;
      getSetCartTotal();
      setState(() {});
    } else {
      ToastComponent.showDialog(
          "${AppLocalizations.of(context)!.cart_screen_cannot_order_more_than} ${_shopList[seller_index].cart_items[item_index].upper_limit} ${AppLocalizations.of(context)!.cart_screen_items_of_this}",
          gravity: Toast.center,
          duration: Toast.lengthLong);
    }
  }

  onQuantityDecrease(seller_index, item_index) {
    if (_shopList[seller_index].cart_items[item_index].quantity >
        _shopList[seller_index].cart_items[item_index].lower_limit) {
      _shopList[seller_index].cart_items[item_index].quantity--;
      getSetCartTotal();
      setState(() {});
    } else {
      ToastComponent.showDialog(
          "${AppLocalizations.of(context)!.cart_screen_cannot_order_more_than} ${_shopList[seller_index].cart_items[item_index].lower_limit} ${AppLocalizations.of(context)!.cart_screen_items_of_this}",
          gravity: Toast.center,
          duration: Toast.lengthLong);
    }
  }

  onPressDelete(cart_id) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: EdgeInsets.only(
                  top: 16.0, left: 2.0, right: 2.0, bottom: 2.0),
              content: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Text(
                  AppLocalizations.of(context)!.cart_screen_sure_remove_item,
                  maxLines: 3,
                  style: TextStyle(color: MyTheme.font_grey, fontSize: 14),
                ),
              ),
              actions: [
                TextButton(
                  child: Text(
                    AppLocalizations.of(context)!.cart_screen_cancel,
                    style: TextStyle(color: MyTheme.medium_grey),
                  ),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: MyTheme.soft_accent_color,
                  ),
                  //color: MyTheme.soft_accent_color,
                  child: Text(
                    AppLocalizations.of(context)!.cart_screen_confirm,
                    style: TextStyle(color: MyTheme.dark_grey),
                  ),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    confirmDelete(cart_id);
                  },
                ),
              ],
            ));
  }

  confirmDelete(cart_id) async {
    var cartDeleteResponse =
        await CartRepository().getCartDeleteResponse(cart_id);

    if (cartDeleteResponse.result == true) {
      ToastComponent.showDialog(cartDeleteResponse.message!,
          gravity: Toast.center, duration: Toast.lengthLong);

      reset();
      fetchData();
    } else {
      ToastComponent.showDialog(cartDeleteResponse.message!,
          gravity: Toast.center, duration: Toast.lengthLong);
    }
  }

  onPressUpdate() {
    process(mode: "update");
  }

  onPressProceedToShipping() {
    process(mode: "proceed_to_shipping");
  }

  process({mode}) async {
    var cart_ids = [];
    var cart_quantities = [];
    if (_shopList.length > 0) {
      _shopList.forEach((shop) {
        if (shop.cart_items.length > 0) {
          shop.cart_items.forEach((cart_item) {
            cart_ids.add(cart_item.id);
            cart_quantities.add(cart_item.quantity);
          });
        }
      });
    }

    if (cart_ids.length == 0) {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!.cart_screen_cart_empty,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    }

    var cart_ids_string = cart_ids.join(',').toString();
    var cart_quantities_string = cart_quantities.join(',').toString();

    print(cart_ids_string);
    print(cart_quantities_string);

    var cartProcessResponse = await CartRepository()
        .getCartProcessResponse(cart_ids_string, cart_quantities_string);

    if (cartProcessResponse.result == false) {
      ToastComponent.showDialog(cartProcessResponse.message!,
          gravity: Toast.center, duration: Toast.lengthLong);
    } else {

      ToastComponent.showDialog(cartProcessResponse.message!,
          gravity: Toast.center, duration: Toast.lengthLong);

      if (mode == "update") {
        reset();
        fetchData();
      } else if (mode == "proceed_to_shipping") {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return SelectAddress(
              owner_id: owner_id!);
        })).then((value) {
          onPopped(value);
        });
      }
    }

  }

  reset() {
    _shopList = [];
    _isInitial = true;
    _cartTotal = 0.00;
    _cartTotalString = "0";

    setState(() {});
  }

  Future<void> _onRefresh() async {
    reset();
    fetchData();
  }

  onPopped(value) async {
    reset();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: app_language_rtl.$ ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
          key: _scaffoldKey,
          //drawer: MainDrawer(),
          backgroundColor: Colors.white,
          appBar: buildAppBar(context),
          body: Stack(
            children: [
              RefreshIndicator(
                color: MyTheme.accent_color,
                backgroundColor: Colors.white,
                onRefresh: _onRefresh,
                displacement: 0,
                child: CustomScrollView(
                  controller: _mainScrollController,
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    SliverList(
                      delegate: SliverChildListDelegate([
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: buildCartSellerList(),
                        ),
                        Container(
                          height: widget.has_bottomnav! ? 140 : 100,
                        )
                      ]),
                    )
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: buildBottomContainer(),
              )
            ],
          )),
    );
  }

  Container buildBottomContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        /*border: Border(
                  top: BorderSide(color: MyTheme.light_grey,width: 1.0),
                )*/
      ),

      height: widget.has_bottomnav! ? 200 : 120,
      //color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0,vertical: 4),
        child: Column(
          children: [
            Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.0),
                  color: MyTheme.soft_accent_color),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      AppLocalizations.of(context)!.cart_screen_total_amount,
                      style:
                          TextStyle(color: MyTheme.dark_font_grey, fontSize: 13,fontWeight: FontWeight.w700),
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(CurrencyFormat.convertToIdr(int.parse(_cartTotalString)),
                        style: TextStyle(
                            color: MyTheme.accent_color,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(
                    width: (MediaQuery.of(context).size.width - 48) * (1 / 3),
                    height: 58,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        // border:
                        //     Border.all(color: MyTheme.accent_color, width: 1),
                        borderRadius: app_language_rtl.$
                            ? const BorderRadius.only(
                                topLeft: const Radius.circular(0.0),
                                bottomLeft: const Radius.circular(0.0),
                                topRight: const Radius.circular(6.0),
                                bottomRight: const Radius.circular(6.0),
                              )
                            : const BorderRadius.only(
                                topLeft: const Radius.circular(6.0),
                                bottomLeft: const Radius.circular(6.0),
                                topRight: const Radius.circular(0.0),
                                bottomRight: const Radius.circular(0.0),
                              )),
                    child: TextButton(
                      //minWidth: MediaQuery.of(context).size.width,
                      //height: 50,
                      //color: MyTheme.soft_accent_color,
                      style: TextButton.styleFrom(
                        minimumSize:  Size(MediaQuery.of(context).size.width, 50),
                        backgroundColor: MyTheme.soft_accent_color,
                        shape: app_language_rtl.$
                            ? RoundedRectangleBorder(
                            borderRadius: const BorderRadius.only(
                              topLeft: const Radius.circular(0.0),
                              bottomLeft: const Radius.circular(0.0),
                              topRight: const Radius.circular(6.0),
                              bottomRight: const Radius.circular(6.0),
                            ))
                            : RoundedRectangleBorder(
                            borderRadius: const BorderRadius.only(
                              topLeft: const Radius.circular(6.0),
                              bottomLeft: const Radius.circular(6.0),
                              topRight: const Radius.circular(0.0),
                              bottomRight: const Radius.circular(0.0),
                            )),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.cart_screen_update_cart,
                        style: TextStyle(
                            color: MyTheme.dark_font_grey,
                            fontSize: 13,
                            fontWeight: FontWeight.w700),
                      ),
                      onPressed: () {
                        onPressUpdate();
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(
                    height: 58,
                    width: (MediaQuery.of(context).size.width - 48) * (2 / 3),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border:
                            Border.all(color: MyTheme.accent_color, width: 1),
                        borderRadius: app_language_rtl.$
                            ? const BorderRadius.only(
                                topLeft: const Radius.circular(6.0),
                                bottomLeft: const Radius.circular(6.0),
                                topRight: const Radius.circular(0.0),
                                bottomRight: const Radius.circular(0.0),
                              )
                            : const BorderRadius.only(
                                topLeft: const Radius.circular(0.0),
                                bottomLeft: const Radius.circular(0.0),
                                topRight: const Radius.circular(6.0),
                                bottomRight: const Radius.circular(6.0),
                              )),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        minimumSize:  Size(MediaQuery.of(context).size.width, 50),
                        //minWidth: MediaQuery.of(context).size.width,
                        //height: 50,
                        //color: MyTheme.accent_color,
                        backgroundColor: MyTheme.accent_color,
                        shape: app_language_rtl.$
                          ? RoundedRectangleBorder(
                              borderRadius: const BorderRadius.only(
                              topLeft: const Radius.circular(6.0),
                              bottomLeft: const Radius.circular(6.0),
                              topRight: const Radius.circular(0.0),
                              bottomRight: const Radius.circular(0.0),
                            ))
                          : RoundedRectangleBorder(
                              borderRadius: const BorderRadius.only(
                              topLeft: const Radius.circular(0.0),
                              bottomLeft: const Radius.circular(0.0),
                              topRight: const Radius.circular(6.0),
                              bottomRight: const Radius.circular(6.0),
                            )),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.cart_screen_proceed_to_shipping,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700),
                      ),
                      onPressed: () {
                        onPressProceedToShipping();
                      },
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      leading: Builder(
        builder: (context) =>
            widget.from_navigation! ? UsefulElements.backToMain(context, go_back: false) : UsefulElements.backButton(context),
      ),
      title: Text(
        AppLocalizations.of(context)!.cart_screen_shopping_cart,
        style: TextStyles.buildAppBarTexStyle(),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  buildCartSellerList() {
    if (is_logged_in.$ == false) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            AppLocalizations.of(context)!.cart_screen_please_log_in,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    } else if (_isInitial && _shopList.length == 0) {
      return SingleChildScrollView(
          child: ShimmerHelper()
              .buildListShimmer(item_count: 5, item_height: 100.0));
    } else if (_shopList.length > 0) {
      return SingleChildScrollView(
        child: ListView.separated(
          separatorBuilder: (context, index) => SizedBox(
            height: 26,
          ),
          itemCount: _shopList.length,
          scrollDirection: Axis.vertical,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Text(
                        _shopList[index].name,
                        style: TextStyle(
                            color: MyTheme.dark_font_grey,
                            fontWeight: FontWeight.w700,
                            fontSize: 12),
                      ),
                      Spacer(),
                      Text(
                        CurrencyFormat.convertToIdr(int.parse(partialTotalString(index))),
                        style: TextStyle(
                            color: MyTheme.accent_color,
                            fontWeight: FontWeight.w700,
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
                buildCartSellerItemList(index),
              ],
            );
          },
        ),
      );
    } else if (!_isInitial && _shopList.length == 0) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            AppLocalizations.of(context)!.cart_screen_cart_empty,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    }
  }

  SingleChildScrollView buildCartSellerItemList(seller_index) {
    return SingleChildScrollView(
      child: ListView.separated(
        separatorBuilder: (context, index) => SizedBox(
          height: 14,
        ),
        itemCount: _shopList[seller_index].cart_items.length,
        scrollDirection: Axis.vertical,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return buildCartSellerItemCard(seller_index, index);
        },
      ),
    );
  }

  buildCartSellerItemCard(seller_index, item_index) {
    return Container(
      height: 120,
      decoration: BoxDecorations.buildBoxDecoration_1(),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
                width: DeviceInfo(context).width!/4,
                height: 120,
                child: ClipRRect(
                    borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(6), right: Radius.zero),
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/placeholder.png',
                      image: _shopList[seller_index]
                          .cart_items[item_index]
                          .product_thumbnail_image,
                      fit: BoxFit.cover,
                    ))),
            Container(
              //color: Colors.red,
              width: DeviceInfo(context).width!/3,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _shopList[seller_index]
                          .cart_items[item_index]
                          .product_name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                          color: MyTheme.font_grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 23.0),
                      child: Row(
                        children: [
                          Text(
                            CurrencyFormat.convertToIdr(int.parse(partialProdukString(seller_index, item_index))),
                            //(_shopList[seller_index].cart_items[item_index].price *_shopList[seller_index].cart_items[item_index].quantity).toStringAsFixed(0)
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                                color: MyTheme.accent_color,
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
            Container(
              width: 32,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      onPressDelete(
                          _shopList[seller_index].cart_items[item_index].id);
                    },
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 14.0),
                        child: Image.asset(
                          'assets/trash.png',
                          height: 16,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      onQuantityIncrease(seller_index, item_index);
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration:
                          BoxDecorations.buildCartCircularButtonDecoration(),
                      child: Icon(
                        Icons.add,
                        color: MyTheme.accent_color,
                        size: 12,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Text(
                      _shopList[seller_index]
                          .cart_items[item_index]
                          .quantity
                          .toString(),
                      style:
                          TextStyle(color: MyTheme.accent_color, fontSize: 16),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      onQuantityDecrease(seller_index, item_index);
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration:
                          BoxDecorations.buildCartCircularButtonDecoration(),
                      child: Icon(
                        Icons.remove,
                        color: MyTheme.accent_color,
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ]),
    );
  }
}
