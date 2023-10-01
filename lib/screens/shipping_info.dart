import 'dart:convert';

import 'package:klinikkecantikan/custom/box_decorations.dart';
import 'package:klinikkecantikan/custom/device_info.dart';
import 'package:klinikkecantikan/custom/fade_network_image.dart';
import 'package:klinikkecantikan/custom/lang_text.dart';
import 'package:klinikkecantikan/custom/scroll_to_hide_widget.dart';
import 'package:klinikkecantikan/custom/useful_elements.dart';
import 'package:klinikkecantikan/data_model/carriers_response.dart';
import 'package:klinikkecantikan/data_model/delivery_info_response.dart';
import 'package:klinikkecantikan/data_model/ongkir_response.dart';
import 'package:klinikkecantikan/repositories/cart_repository.dart';
import 'package:klinikkecantikan/repositories/shipping_repository.dart';
import 'package:klinikkecantikan/screens/checkout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:klinikkecantikan/my_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:klinikkecantikan/helpers/shared_value_helper.dart';
import 'package:klinikkecantikan/repositories/address_repository.dart';
import 'package:klinikkecantikan/helpers/shimmer_helper.dart';
import 'package:klinikkecantikan/data_model/city_response.dart';
import 'package:klinikkecantikan/data_model/country_response.dart';
import 'package:klinikkecantikan/custom/toast_component.dart';
import 'package:toast/toast.dart';
import 'package:klinikkecantikan/screens/address.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';

import '../controller/ongkir_controller.dart';

class ShippingInfo extends StatefulWidget {
  int? owner_id;
  int? destinasi;

  ShippingInfo({Key? key, this.owner_id, this.destinasi}) : super(key: key);

  @override
  _ShippingInfoState createState() => _ShippingInfoState();
}

class _ShippingInfoState extends State<ShippingInfo> {
  ScrollController _mainScrollController = ScrollController();

  List<SellerWithShipping> _sellerWiseShippingOption = [];

  List<DeliveryInfoResponse> _deliveryInfoList = [];


  String _shipping_cost_string = ". . . (loading)";

  // Boolean variables
  bool _isFetchDeliveryInfo = false;

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  //double variables
  double mWidth = 0;
  double mHeight = 0;

  double? weight = 0;
  int origin = 152; //default jakarta pusat

  fetchAll() {
    getDeliveryInfo();
  }

  getDeliveryInfo() async {
    _deliveryInfoList = await ShippingRepository().getDeliveryInfo();
    _isFetchDeliveryInfo = true;
    _deliveryInfoList.forEach((element) {
      var shippingOption = carrier_base_shipping.$ ? ShippingOption.Carrier: ShippingOption.HomeDelivery;
      var shippingId = carrier_base_shipping.$ ? element.carriers!.data!.first.id : 0;
      var shippingName = carrier_base_shipping.$ ? element.carriers!.data!.first.name : "";
      var shippingCost = 0;
      //var shippingOption =  ShippingOption.RajaOngkir;
      //var shippingId = carrier_base_shipping.$ ? element.carriers!.data!.first.id : 0;
      print("cek kode: ${element.carriers!.data!.first.kode}");

      _sellerWiseShippingOption.add(
          new SellerWithShipping(element.ownerId, shippingOption, shippingId, shippingCost, shippingName!));
    });

    getSetShippingCost();
    setState(() {});
  }


  getSetShippingCost() async {
    var shippingCostResponse;
    shippingCostResponse = await AddressRepository().getShippingCostResponse(
        destinasi:widget.destinasi,
        shipping_type: _sellerWiseShippingOption);

    if (shippingCostResponse.result == true) {
      print("cek: $shippingCostResponse");
      _shipping_cost_string = shippingCostResponse.value_string;
    } else {
      _shipping_cost_string = "0.0";
    }
    setState(() {});
  }


  resetData(){
    clearData();
    fetchAll();
  }

  clearData() {
    _deliveryInfoList.clear();
    _sellerWiseShippingOption.clear();
    _shipping_cost_string = ". . .";
    _shipping_cost_string = ". . .";
    _isFetchDeliveryInfo = false;
    setState(() {});
  }

  Future<void> _onRefresh() async {
    clearData();
    if (is_logged_in.$ == true) {
      fetchAll();
    }
  }

  onPopped(value) async {
    resetData();
  }

  afterAddingAnAddress() {
    resetData();
  }

  onPickUpPointSwitch() async {
    _shipping_cost_string = ". . .";
    setState(() {});
  }

  changeShippingOption(ShippingOption option, index) {
    print(_sellerWiseShippingOption[index].shippingId);
    print(_sellerWiseShippingOption[index].shippingId);

    if (option.index == 1) {
      _sellerWiseShippingOption[index].shippingId = _deliveryInfoList.first.pickupPoints!.first.id;
    }
    if (option.index == 2) {
      _sellerWiseShippingOption[index].shippingId = _deliveryInfoList.first.carriers!.data!.first.id;
    }
    _sellerWiseShippingOption[index].shippingOption = option;
    getSetShippingCost();

    setState(() {});
  }

  onPressProceed(context) async {
    var shippingCostResponse;
    // print(jsonEncode(_sellerWiseShipping));

    shippingCostResponse =
    await AddressRepository().getShippingCostResponse(
        destinasi:widget.destinasi,
        shipping_type: _sellerWiseShippingOption);

    if (shippingCostResponse.result == false) {
      ToastComponent.showDialog(LangText(context).local!.common_network_error,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Checkout(
          title: AppLocalizations.of(context)!.checkout_screen_checkout,
          isWalletRecharge: false);
    })).then((value) {
      onPopped(value);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (is_logged_in.$ == true) {
      fetchAll();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _mainScrollController.dispose();
  }

  Widget customAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: MyTheme.white,
      automaticallyImplyLeading: false,
      title: buildAppbarTitle(context),
      leading: UsefulElements.backButton(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    mHeight = MediaQuery
        .of(context)
        .size
        .height;
    mWidth = MediaQuery
        .of(context)
        .size
        .width;
    return Directionality(
      textDirection: app_language_rtl.$ ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: MyTheme.white,
            automaticallyImplyLeading: false,
            title: buildAppbarTitle(context),
            leading: UsefulElements.backButton(context),
          ),//customAppBar(context),
          bottomNavigationBar: buildBottomAppBar(context),
          body: buildBody(context)),
    );
  }

  RefreshIndicator buildBody(BuildContext context) {
    return RefreshIndicator(
      color: MyTheme.accent_color,
      backgroundColor: Colors.white,
      onRefresh: _onRefresh,
      displacement: 0,
      child: Container(
        child: buildCartSellerList()// buildBodyChildren(context),
      ),
    );
  }

  Widget buildBodyChildren(BuildContext context) {
    return buildCartSellerList();
  }

  buildCartSellerList() {
    print("cek: $_isFetchDeliveryInfo ${_deliveryInfoList.length}");
    if (is_logged_in.$ == false) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
                AppLocalizations
                    .of(context)!
                    .cart_screen_please_log_in,
                style: TextStyle(color: MyTheme.font_grey),
              )));
    }
    else if (!_isFetchDeliveryInfo && _deliveryInfoList.length == 0) {
      return SingleChildScrollView(
          child: ShimmerHelper()
              .buildListShimmer(item_count: 5, item_height: 100.0));
    }
    else if (_deliveryInfoList.length > 0) {
      return buildCartSellerListBody();
    }
    else if (_isFetchDeliveryInfo && _deliveryInfoList.length == 0) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
                AppLocalizations
                    .of(context)!
                    .cart_screen_cart_empty,
                style: TextStyle(color: MyTheme.font_grey),
              )));
    }
  }

  SingleChildScrollView buildCartSellerListBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: ListView.separated(
          padding: EdgeInsets.only(bottom: 20),
          separatorBuilder: (context, index) =>
              SizedBox(
                height: 26,
              ),
          itemCount: _deliveryInfoList.length,
          scrollDirection: Axis.vertical,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return buildCartSellerListItem(index, context);
          },
        ),
      ),
    );
  }

  Column buildCartSellerListItem(int index, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            _deliveryInfoList[index].name!,
            style: TextStyle(
                color: MyTheme.accent_color,
                fontWeight: FontWeight.w700,
                fontSize: 16),
          ),
        ),
        buildCartSellerItemList(index),

        Padding(
          padding: const EdgeInsets.only(top: 18.0),
          child: Text(

            LangText(context).local!
                .shipping_info_screen_address_choose_delivery,
            style: TextStyle(
                color: MyTheme.dark_font_grey,
                fontWeight: FontWeight.w700,
                fontSize: 12),
          ),
        ),
        SizedBox(height: 5,),
        buildChooseShippingOptions(context, index),
        SizedBox(height: 10,),
        buildShippingListBody(index),
      ],
    );
  }

  Widget buildChooseShippingOptions(BuildContext context, sellerIndex) {
    return Container(
      color: MyTheme.white,
      //MyTheme.light_grey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if(carrier_base_shipping.$)
            buildCarrierOption(context, sellerIndex)
          else
            buildAddressOption(context, sellerIndex),
          SizedBox(width: 14,),
          buildPickUpPointOption(context, sellerIndex),
        ],
      ),
    );
  }

  TextButton buildCarrierOption(BuildContext context, sellerIndex) {
    return TextButton(
      style: TextButton.styleFrom(
          backgroundColor: _sellerWiseShippingOption[sellerIndex].shippingOption ==ShippingOption.Carrier ? MyTheme.accent_color
              : MyTheme.accent_color.withOpacity(0.1),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: BorderSide(color: MyTheme.accent_color)
          ),
          padding: EdgeInsets.only(right: 14)),
      onPressed: () {
        changeShippingOption(ShippingOption.Carrier, sellerIndex);
      },
      child: Container(
        height: 30,
        // width: (mWidth / 4) - 1,
        alignment: Alignment.center,
        child: Row(
          children: [
            Radio(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                fillColor: MaterialStateProperty.resolveWith((states) {
                  if (!states.contains(MaterialState.selected)) {
                    return MyTheme.accent_color;
                  }
                  return MyTheme.white ;
                }),
                value: ShippingOption.Carrier,
                groupValue: _sellerWiseShippingOption[sellerIndex].shippingOption,
                onChanged: (newOption) {
                  changeShippingOption(newOption!, sellerIndex);
                }),
            Text(
              AppLocalizations.of(context)!.shipping_info_screen_no_carrier,
              style:  TextStyle(
                  fontSize: 12,
                  color: _sellerWiseShippingOption[sellerIndex]
                      .shippingOption == ShippingOption.Carrier
                      ? MyTheme.white
                      : MyTheme.accent_color,
                  fontWeight: _sellerWiseShippingOption[sellerIndex]
                      .shippingOption == ShippingOption.Carrier
                      ? FontWeight.w700
                      : FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }

  Container buildShippingListContainer(BuildContext context, index) {
    return Container(
      padding: EdgeInsets.only(top: 100),
      child: CustomScrollView(
        controller: _mainScrollController,
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverList(
              delegate: SliverChildListDelegate([
                buildShippingListBody(index),
                SizedBox(
                  height: 100,
                )
              ]))
        ],
      ),
    );
  }

  Widget buildShippingListBody(sellerIndex) {
    return _sellerWiseShippingOption[sellerIndex].shippingOption !=ShippingOption.PickUpPoint ? buildHomeDeliveryORCarrier(sellerIndex)
        : buildPickupPoint(sellerIndex);
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      leading: Builder(
        builder: (context) =>
            IconButton(
              icon: Icon(CupertinoIcons.arrow_left, color: MyTheme.dark_grey),
              onPressed: () => Navigator.of(context).pop(),
            ),
      ),
      title: Text(
        "${AppLocalizations
            .of(context)!
            .shipping_info_screen_shipping_cost} ${_shipping_cost_string}",
        style: TextStyle(fontSize: 16, color: MyTheme.accent_color),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  buildHomeDeliveryORCarrier(sellerArrayIndex) {
    if (carrier_base_shipping.$) {
      return buildCarrierSection(sellerArrayIndex);
    } else {
      return Container();
    }
  }

  Container buildLoginWarning() {
    return Container(
        height: 100,
        child: Center(
            child: Text(
              LangText(context).local!.common_login_warning,
              style: TextStyle(color: MyTheme.font_grey),
            )));
  }

  Widget buildPickupPoint(sellerArrayIndex) {
    if (is_logged_in.$ == false) {
      return buildLoginWarning();
    } else if (_isFetchDeliveryInfo && _deliveryInfoList.length == 0) {
      return buildCarrierShimmer();
    } else if (_deliveryInfoList[sellerArrayIndex].pickupPoints!.length > 0) {
      return ListView.separated(
        separatorBuilder: (context,index)=>SizedBox(height: 14,),
        itemCount: _deliveryInfoList[sellerArrayIndex].pickupPoints!.length,
        scrollDirection: Axis.vertical,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return buildPickupPointItemCard(index, sellerArrayIndex);
        },
      );
    } else if (_isFetchDeliveryInfo && _deliveryInfoList[sellerArrayIndex].pickupPoints!.length == 0) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
                AppLocalizations
                    .of(context)!
                    .no_pickup_point,
                style: TextStyle(color: MyTheme.font_grey),
              )));
    }
    return Container();
  }

  GestureDetector buildPickupPointItemCard(pickupPointIndex, sellerArrayIndex) {
    return GestureDetector(
      onTap: () {
        if (_sellerWiseShippingOption[sellerArrayIndex].shippingId !=
            _deliveryInfoList[sellerArrayIndex].pickupPoints![pickupPointIndex]
                .id) {
          _sellerWiseShippingOption[sellerArrayIndex].shippingId =
              _deliveryInfoList[sellerArrayIndex].pickupPoints![pickupPointIndex]
                  .id;
        }
        setState(() {});
        getSetShippingCost();
      },
      child: Container(
        decoration: BoxDecorations.buildBoxDecoration_1(radius: 8).copyWith(
          border:_sellerWiseShippingOption[sellerArrayIndex].shippingId ==
              _deliveryInfoList[sellerArrayIndex].pickupPoints![pickupPointIndex]
                  .id?
          Border.all(color: MyTheme.accent_color, width: 1.0)
          :Border.all(color: MyTheme.light_grey, width: 1.0)
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: buildPickUpPointInfoItemChildren(
              pickupPointIndex, sellerArrayIndex),
        ),
      ),
    );
  }

  Column buildPickUpPointInfoItemChildren(pickupPointIndex, sellerArrayIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 75,
                child: Text(
                  AppLocalizations
                      .of(context)!
                      .shipping_info_screen_address,
                  style: TextStyle(
                    fontSize: 13,
                    color: MyTheme.dark_font_grey,
                  ),
                ),
              ),
              Container(
                width: 175,
                child: Text(
                  _deliveryInfoList[sellerArrayIndex]
                      .pickupPoints![pickupPointIndex].name!,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 13,
                      color: MyTheme.dark_grey, fontWeight: FontWeight.w600),
                ),
              ),
              Spacer(),
              buildShippingSelectMarkContainer(
                  _sellerWiseShippingOption[sellerArrayIndex].shippingId ==
                      _deliveryInfoList[sellerArrayIndex]
                          .pickupPoints![pickupPointIndex].id)
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 75,
                child: Text(
                  AppLocalizations
                      .of(context)!
                      .address_screen_phone,
                  style: TextStyle(
                    fontSize: 13,
                    color: MyTheme.dark_font_grey,
                  ),
                ),
              ),
              Container(
                width: 200,
                child: Text(
                  _deliveryInfoList[sellerArrayIndex]
                      .pickupPoints![pickupPointIndex].phone!,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 13,
                      color: MyTheme.dark_grey, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildCarrierSection(sellerArrayIndex) {
    if (is_logged_in.$ == false) {
      return buildLoginWarning();
    } else if (!_isFetchDeliveryInfo) {
      return buildCarrierShimmer();
    } else if (_deliveryInfoList[sellerArrayIndex].carriers!.data!.length > 0) {
      return Container(
          child: buildCarrierListView(sellerArrayIndex));
    } else {
      return buildCarrierNoData();
    }
  }

  Container buildCarrierNoData() {
    return Container(
        height: 100,
        child: Center(
            child: Text(
              AppLocalizations
                  .of(context)!
                  .shipping_info_screen_no_carrier_point,
              style: TextStyle(color: MyTheme.font_grey),
            )));
  }

  Widget buildCarrierListView(sellerArrayIndex) {
    return ListView.separated(
      itemCount: _deliveryInfoList[sellerArrayIndex].carriers!.data!.length,
      scrollDirection: Axis.vertical,
      separatorBuilder: (context,index){
        return SizedBox(height:14,);
      },
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        // if (_sellerWiseShippingOption[sellerArrayIndex].shippingId == 0) {
        //   _sellerWiseShippingOption[sellerArrayIndex].shippingId = _deliveryInfoList[sellerArrayIndex].carriers.data[index].id;
        //   setState(() {});
        // }
        return buildCarrierInfoItemChildren(index, sellerArrayIndex);//buildCarrierItemCard(index, sellerArrayIndex);
      },
    );
  }

  Widget buildCarrierShimmer() {
    return ShimmerHelper().buildListShimmer(item_count: 2, item_height: 50.0);
  }

  GestureDetector buildCarrierItemCard(carrierIndex, sellerArrayIndex) {
    return GestureDetector(
      onTap: () {
        if (_sellerWiseShippingOption[sellerArrayIndex].shippingId != _deliveryInfoList[sellerArrayIndex].carriers!.data![carrierIndex].id) {
          _sellerWiseShippingOption[sellerArrayIndex].shippingId =_deliveryInfoList[sellerArrayIndex].carriers!.data![carrierIndex].id;
          setState(() {});
          getSetShippingCost();
        }
      },
      child: Container(
        decoration: BoxDecorations.buildBoxDecoration_1(radius: 8).copyWith(
            border:_sellerWiseShippingOption[sellerArrayIndex].shippingId ==
                _deliveryInfoList[sellerArrayIndex].carriers!.data![carrierIndex]
                    .id?
            Border.all(color: MyTheme.accent_color, width: 1.0)
                :Border.all(color: MyTheme.light_grey, width: 1.0)
        ),
        child: buildCarrierInfoItemChildren(carrierIndex, sellerArrayIndex),
      ),
    );
  }

  Widget buildCarrierInfoItemChildren(carrierIndex, sellerArrayIndex) {
            return GestureDetector(
                onTap: () {
                  if (_sellerWiseShippingOption[sellerArrayIndex].shippingId != _deliveryInfoList[sellerArrayIndex].carriers!.data![carrierIndex].id) {
                    _sellerWiseShippingOption[sellerArrayIndex].shippingId = _deliveryInfoList[sellerArrayIndex].carriers!.data![carrierIndex].id;

                    setState(() {});
                    getSetShippingCost();
                  }
                },
                child: Container(
                    decoration: BoxDecorations.buildBoxDecoration_1(radius: 8).copyWith(
                        border:_sellerWiseShippingOption[sellerArrayIndex].shippingId ==
                            _deliveryInfoList[sellerArrayIndex].carriers!.data![carrierIndex]
                                .id?
                        Border.all(color: MyTheme.accent_color, width: 1.0)
                            :Border.all(color: MyTheme.light_grey, width: 1.0)
                    ),
                    child:Stack(
                      children: [
                        Container(
                          width: DeviceInfo(context).width! / 1.3,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              MyImage.imageNetworkPlaceholder(
                                  height: 75.0,
                                  width: 75.0,
                                  radius: BorderRadius.only(topLeft: Radius.circular(6),
                                      bottomLeft: Radius.circular(6)),
                                  url: _deliveryInfoList[sellerArrayIndex].carriers!
                                      .data![carrierIndex].logo),
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: Text(
                                        _deliveryInfoList[sellerArrayIndex].carriers!
                                            .data![carrierIndex].name!,
                                        maxLines: 2,
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: MyTheme.dark_font_grey,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(top: 10),
                                      child: Text(
                                        _deliveryInfoList[sellerArrayIndex].carriers!
                                            .data![carrierIndex].transitTime.toString() +
                                            " " + LangText(context).local!.common_day,
                                        maxLines: 2,
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: MyTheme.dark_font_grey,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Spacer(),
                              //starting builder call response rajaongkir
                              Container(
                                child:
                                Text(
                                  _deliveryInfoList[sellerArrayIndex].carriers!.data![carrierIndex].transitPrice.toString(),
                                  maxLines: 2,
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: MyTheme.dark_font_grey,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),

                              //end builder call price rajaongkir
                              SizedBox(width: 16,)
                            ],
                          ),
                        ),

                        Positioned(
                          right: 16,
                          top: 10,
                          child: buildShippingSelectMarkContainer(
                              _sellerWiseShippingOption[sellerArrayIndex].shippingId ==
                                  _deliveryInfoList[sellerArrayIndex].carriers!
                                      .data![carrierIndex].id),
                        )

                      ],
                    )
                ));
  }

  Widget _buildCarrierInfoItemChildren(carrierIndex, sellerArrayIndex) {

    double _berat = 0;
    int _qty = 0;
    //starting here get data cost
    //origin: tempat pengiriman data dari toko alif?
    origin = _deliveryInfoList[sellerArrayIndex].origin;

    //weight: berat produk data dari?
    if(_deliveryInfoList[sellerArrayIndex].cartItems!=null) {
      _deliveryInfoList[sellerArrayIndex].cartItems!.forEach((element) {
        _berat = element.weight!.toDouble();
        _qty = element.quantity;
      });
      weight = 1000 * (_berat * _qty);
      print("berat: $weight");
      //convert kg to gram
    }

    //kurir: nama kurir data dari?
    String kurir = _deliveryInfoList[sellerArrayIndex].carriers!.data![carrierIndex].kode!;
    //destination: penerima pengiriman dari pembeli?
    //int ongkir = 0;

   return GetBuilder<OngkirController>(builder: (ongkirController){
      return FutureBuilder<OngkirResponse>(
        future: ongkirController.cekongkir(origin, widget.destinasi, weight, kurir),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          var servis = _deliveryInfoList[sellerArrayIndex].carriers!.data![carrierIndex].service!;
          return GestureDetector(
                onTap: () {
                  if (_sellerWiseShippingOption[sellerArrayIndex].shippingId != _deliveryInfoList[sellerArrayIndex].carriers!.data![carrierIndex].id) {

                    _sellerWiseShippingOption[sellerArrayIndex].shippingId = _deliveryInfoList[sellerArrayIndex].carriers!.data![carrierIndex].id;
                    //update ongkir to tabel cart
                    _sellerWiseShippingOption[sellerArrayIndex].shippingCost = snapshot.data!.data!.first.cost.first.value;

                    setState(() {});
                    getSetShippingCost();
                    //update info ongkir to cart
                    print("cek service: $servis");
                  }
                },
                child: Container(
                decoration: BoxDecorations.buildBoxDecoration_1(radius: 8).copyWith(
                border:_sellerWiseShippingOption[sellerArrayIndex].shippingId ==
                    _deliveryInfoList[sellerArrayIndex].carriers!.data![carrierIndex]
                        .id?
                Border.all(color: MyTheme.accent_color, width: 1.0)
                    :Border.all(color: MyTheme.light_grey, width: 1.0)
            ),
          child:Stack(
            children: [
              Container(
                width: DeviceInfo(context).width! / 1.3,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MyImage.imageNetworkPlaceholder(
                        height: 75.0,
                        width: 75.0,
                        radius: BorderRadius.only(topLeft: Radius.circular(6),
                            bottomLeft: Radius.circular(6)),
                        url: _deliveryInfoList[sellerArrayIndex].carriers!
                            .data![carrierIndex].logo),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: DeviceInfo(context).width! / 3,
                            child: Text(
                              _deliveryInfoList[sellerArrayIndex].carriers!
                                  .data![carrierIndex].name!,
                              maxLines: 2,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: MyTheme.dark_font_grey,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 10),
                            child: Text(
                              _deliveryInfoList[sellerArrayIndex].carriers!
                                  .data![carrierIndex].transitTime.toString() +
                                  " " + LangText(context).local!.common_day,
                              maxLines: 2,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: MyTheme.dark_font_grey,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    //starting builder call response rajaongkir
                    Container(
                      child:
                      Text(
                        //_deliveryInfoList[sellerArrayIndex].carriers!.data![carrierIndex].transitPrice.toString(),
                        snapshot.data!.data!.first.service == _deliveryInfoList[sellerArrayIndex].carriers!.data![carrierIndex].service! ?
                        "${snapshot.data!.data!.first.cost.first.value}"
                        : "0",
                        maxLines: 2,
                        style: TextStyle(
                            fontSize: 13,
                            color: MyTheme.dark_font_grey,
                            fontWeight: FontWeight.w600),
                      ),
                    ),

                    //end builder call price rajaongkir
                    SizedBox(width: 16,)
                  ],
                ),
              ),

              Positioned(
                right: 16,
                top: 10,
                child: buildShippingSelectMarkContainer(
                    _sellerWiseShippingOption[sellerArrayIndex].shippingId ==
                        _deliveryInfoList[sellerArrayIndex].carriers!
                            .data![carrierIndex].id),
              )

            ],
          )
          ));
        }
      );

    });
  }

  Container buildShippingSelectMarkContainer(bool check) {
    return check
        ? Container(
      height: 16,
      width: 16,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0), color: Colors.green),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: FaIcon(FontAwesomeIcons.check, color: Colors.white, size: 10),
      ),
    )
        : Container();
  }

  BottomAppBar buildBottomAppBar(BuildContext context) {
    return BottomAppBar(
      child: Container(
        height: 58,
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
        child:
            TextButton(
        style: TextButton.styleFrom(
              backgroundColor: MyTheme.accent_color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0.0),
              )),
              child: Text(
                AppLocalizations
                    .of(context)!
                    .shipping_info_screen_btn_proceed_to_checkout,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                onPressProceed(context);
              },
            )
      ),
    );
  }

  Container buildAppbarTitle(BuildContext context) {
    return Container(
      width: MediaQuery
          .of(context)
          .size
          .width - 40,
      child: Text(
        "${AppLocalizations
            .of(context)!
            .shipping_info_screen_shipping_cost} ${_shipping_cost_string}",
        style: TextStyle(
            fontSize: 16,
            color: MyTheme.dark_font_grey,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Container buildAppbarBackArrow() {
    return Container(
      width: 40,
      child: UsefulElements.backButton(context),
    );
  }

  TextButton buildPickUpPointOption(BuildContext context, sellerIndex) {
    return TextButton(
      style: TextButton.styleFrom(
      backgroundColor: _sellerWiseShippingOption[sellerIndex].shippingOption ==
          ShippingOption.PickUpPoint ? MyTheme.accent_color : MyTheme
          .accent_color.withOpacity(0.1),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(color: MyTheme.accent_color)
      ),
      padding: EdgeInsets.only(right: 14)),
      onPressed: () {
        setState(() {
          changeShippingOption(ShippingOption.PickUpPoint, sellerIndex);
        });
      },
      child: Container(
        alignment: Alignment.center,
        height:30,
        //width: (mWidth / 4) - 1,
        child: Row(
          children: [
            Radio(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                fillColor: MaterialStateProperty.resolveWith((states) {
                  if (!states.contains(MaterialState.selected)) {
                    return MyTheme.accent_color;
                  }
                  return MyTheme.white ;
                }),
                value: ShippingOption.PickUpPoint,
                groupValue: _sellerWiseShippingOption[sellerIndex]
                    .shippingOption,
                onChanged: (newOption) {
                  changeShippingOption(newOption!, sellerIndex);
                }),
            //SizedBox(width: 10,),
            Text(
              AppLocalizations
                  .of(context)!
                  .pickup_point,
              style: TextStyle(
                fontSize: 12,
                  color: _sellerWiseShippingOption[sellerIndex]
                      .shippingOption == ShippingOption.PickUpPoint
                      ? MyTheme.white
                      : MyTheme.accent_color,
                  fontWeight: _sellerWiseShippingOption[sellerIndex]
                      .shippingOption == ShippingOption.PickUpPoint
                      ? FontWeight.w700
                      : FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }

  TextButton buildAddressOption(BuildContext context, sellerIndex) {
    return TextButton(
        style: TextButton.styleFrom(
      backgroundColor: _sellerWiseShippingOption[sellerIndex].shippingOption == ShippingOption.HomeDelivery ? MyTheme.accent_color
          : MyTheme.accent_color.withOpacity(0.1),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(color: MyTheme.accent_color)
      ),
      padding: EdgeInsets.only(right: 14)),
      onPressed: () {
        changeShippingOption(ShippingOption.HomeDelivery, sellerIndex);
      },
      child: Container(
        height: 30,
        // width: (mWidth / 4) - 1,
        alignment: Alignment.center,
        child: Row(
          children: [
            Radio(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                fillColor: MaterialStateProperty.resolveWith((states) {
                  if (!states.contains(MaterialState.selected)) {
                    return MyTheme.accent_color;
                  }
                  return MyTheme.white ;
                }),
                value: ShippingOption.HomeDelivery,
                groupValue: _sellerWiseShippingOption[sellerIndex].shippingOption,
                onChanged: (newOption) {
                  changeShippingOption(newOption!, sellerIndex);
                }),
            Text(
              AppLocalizations.of(context)!.shipping_info_screen_home_delivery,
              style: TextStyle(
                  fontSize: 12,
                  color: _sellerWiseShippingOption[sellerIndex].shippingOption == ShippingOption.HomeDelivery ? MyTheme.white
                      : MyTheme.accent_color,
                  fontWeight: _sellerWiseShippingOption[sellerIndex].shippingOption == ShippingOption.HomeDelivery ? FontWeight.w700
                      : FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }

  SingleChildScrollView buildCartSellerItemList(seller_index) {
    return SingleChildScrollView(
      child: ListView.separated(
        separatorBuilder: (context, index) =>
            SizedBox(
              height: 14,
            ),
        itemCount: _deliveryInfoList[seller_index].cartItems!.length,
        scrollDirection: Axis.vertical,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return buildCartSellerItemCard(index, seller_index);
        },
      ),
    );
  }

  buildCartSellerItemCard(itemIndex, sellerIndex) {
    return Container(
      height: 80,
      decoration: BoxDecorations.buildBoxDecoration_1(),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
                width: DeviceInfo(context).width! / 4,
                height: 120,
                child: ClipRRect(
                    borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(6), right: Radius.zero),
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/placeholder.png',
                      image: _deliveryInfoList[sellerIndex]
                          .cartItems![itemIndex]
                          .productThumbnailImage!,
                      fit: BoxFit.cover,
                    ))),
            SizedBox(width: 10,),
            Container(
              //color: Colors.red,
              width: DeviceInfo(context).width! / 2,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _deliveryInfoList[sellerIndex]
                          .cartItems![itemIndex]
                          .productName!,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                          color: MyTheme.font_grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ),
          ]),
    );
  }

}

enum ShippingOption { HomeDelivery, PickUpPoint, Carrier}
//enum ShippingOption { HomeDelivery, PickUpPoint, Carrier, RajaOngkir }

class SellerWithShipping {
  int sellerId;
  ShippingOption shippingOption;
  int shippingId;
  int shippingCost;
  String shippingName;

  SellerWithShipping(this.sellerId, this.shippingOption, this.shippingId, this.shippingCost, this.shippingName);

  Map toJson() =>
      {
        'seller_id': sellerId,
        'shipping_type': shippingOption == ShippingOption.HomeDelivery? "home_delivery"
            : shippingOption == ShippingOption.Carrier ? "carrier"
           // : shippingOption == ShippingOption.RajaOngkir ? "raja_ongkir"
            : "pickup_point",
        'shipping_id': shippingId,
        'shipping_name': shippingName,
        'shipping_cost': shippingCost,
      };

}
//
// class SellerWithForReqBody{
//   int sellerId;
//   String shippingType;
//
//   SellerWithForReqBody(this.sellerId, this.shippingType);
// }
