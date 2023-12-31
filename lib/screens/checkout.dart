import 'package:klinikkecantikan/custom/box_decorations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:klinikkecantikan/my_theme.dart';
import 'package:klinikkecantikan/screens/order_list.dart';
//import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:klinikkecantikan/helpers/shared_value_helper.dart';
import 'package:klinikkecantikan/repositories/payment_repository.dart';
import 'package:klinikkecantikan/repositories/cart_repository.dart';
import 'package:klinikkecantikan/repositories/coupon_repository.dart';
import 'package:klinikkecantikan/helpers/shimmer_helper.dart';
import 'package:klinikkecantikan/app_config.dart';
import 'package:klinikkecantikan/custom/toast_component.dart';
import 'package:toast/toast.dart';
import 'package:klinikkecantikan/screens/offline_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Checkout extends StatefulWidget {
  int order_id; // only need when making manual payment from order details
  bool manual_payment_from_order_details; // only need when making manual payment from order details
  String list;
  final bool isWalletRecharge;
  final double rechargeAmount;
  final String? title;

  Checkout(
      {Key? key,
      this.order_id = 0,
      this.manual_payment_from_order_details = false,
      this.list = "both",
      this.isWalletRecharge = false,
      this.rechargeAmount =0.0,
      this.title})
      : super(key: key);

  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  var _selected_payment_method_index = 0;
  var _selected_payment_method = "";
  var _selected_payment_method_key = "";
  var _selected_payment_name = "";
  var _selected_payment_details = [];

  ScrollController _mainScrollController = ScrollController();
  TextEditingController _couponController = TextEditingController();
  var _paymentTypeList = [];
  bool _isInitial = true;
  var _totalString = ". . .";
  var _grandTotalValue = 0.00;
  var _subTotalString = ". . .";
  var _taxString = ". . .";
  var _shippingCostString = ". . .";
  var _discountString = ". . .";
  var _used_coupon_code = "";
  var _coupon_applied = false;
  BuildContext? loadingcontext;
  String payment_type = "cart_payment";
  String? _title;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    /*print("user data");
    print(is_logged_in.$);
    print(access_token.value);
    print(user_id.$);
    print(user_name.$);*/

    fetchAll();
  }

  @override
  void dispose() {
    super.dispose();
    _mainScrollController.dispose();
  }

  fetchAll() {
    fetchList();

    if (is_logged_in.$ == true) {
      if (widget.isWalletRecharge || widget.manual_payment_from_order_details) {
        _grandTotalValue = widget.rechargeAmount;
        payment_type = "wallet_payment";
      } else {
        fetchSummary();
        //payment_type = payment_type;
      }
    }
  }

  fetchList() async {
    var paymentTypeResponseList =
        await PaymentRepository().getPaymentResponseList(list: widget.list,mode: widget.isWalletRecharge?"wallet":"order");
    _paymentTypeList.addAll(paymentTypeResponseList);
    if (_paymentTypeList.length > 0) {
      _selected_payment_method = _paymentTypeList[0].payment_type;
      _selected_payment_method_key = _paymentTypeList[0].payment_type_key;
      _selected_payment_name = _paymentTypeList[0].name;
      _selected_payment_details = _paymentTypeList[0].data;
    }
    _isInitial = false;
    setState(() {});
  }

  fetchSummary() async {
    var cartSummaryResponse = await CartRepository().getCartSummaryResponse();

    if (cartSummaryResponse != null) {
      _subTotalString = cartSummaryResponse.sub_total!;
      _taxString = cartSummaryResponse.tax!;
      _shippingCostString = cartSummaryResponse.shipping_cost!;
      _discountString = cartSummaryResponse.discount!;
      _totalString = cartSummaryResponse.grand_total!;
      _grandTotalValue = cartSummaryResponse.grand_total_value!;
      _used_coupon_code = cartSummaryResponse.coupon_code!;
      _couponController.text = _used_coupon_code;
      _coupon_applied = cartSummaryResponse.coupon_applied!;
      setState(() {});
    }
  }

  reset() {
    _paymentTypeList.clear();
    _isInitial = true;
    _selected_payment_method_index = 0;
    _selected_payment_method = "";
    _selected_payment_method_key = "";
    _selected_payment_name = "";
    _selected_payment_details = [];
    setState(() {});

    reset_summary();
  }

  reset_summary() {
    _totalString = ". . .";
    _grandTotalValue = 0.00;
    _subTotalString = ". . .";
    _taxString = ". . .";
    _shippingCostString = ". . .";
    _discountString = ". . .";
    _used_coupon_code = "";
    _couponController.text = _used_coupon_code;
    _coupon_applied = false;

    setState(() {});
  }

  Future<void> _onRefresh() async {
    reset();
    fetchAll();
  }

  onPopped(value) {
    reset();
    fetchAll();
  }

  onCouponApply() async {
    var coupon_code = _couponController.text.toString();
    if (coupon_code == "") {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!.checkout_screen_coupon_code_warning,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    }

    var couponApplyResponse =
        await CouponRepository().getCouponApplyResponse(coupon_code);
    if (couponApplyResponse.result == false) {
      ToastComponent.showDialog(couponApplyResponse.message!,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    reset_summary();
    fetchSummary();
  }

  onCouponRemove() async {
    var couponRemoveResponse =
        await CouponRepository().getCouponRemoveResponse();

    if (couponRemoveResponse.result == false) {
      ToastComponent.showDialog(couponRemoveResponse.message!,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    reset_summary();
    fetchSummary();
  }

  onPressPlaceOrderOrProceed() {
    if (_selected_payment_method == "") {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!.common_payment_choice_warning,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

   if (_selected_payment_method == "wallet_system") {
     print("cek payment ${_selected_payment_method} & ${_selected_payment_method_key} & ${_selected_payment_name}");
      pay_by_wallet();
    }
    else if (_selected_payment_method == "cash_payment") {
     print("cek payment ${_selected_payment_method} & ${_selected_payment_method_key} & ${_selected_payment_name}");
      pay_by_cod();
    }
    else if (_selected_payment_method == "manual_payment" && widget.manual_payment_from_order_details == false) {
     pay_by_manual_payment();
     print("cek payment ${_selected_payment_method} & ${_selected_payment_method_key} & ${_selected_payment_name} & ${_selected_payment_details[0]}");

    }
    else if (_selected_payment_method == "manual_payment" && widget.manual_payment_from_order_details == true) {
    //  Navigator.push(context, MaterialPageRoute(builder: (context) {
   //     return OfflineScreen(
   //       order_id: widget.order_id,
    //      payment_type: "manual_payment",
    //      details: _paymentTypeList[_selected_payment_method_index].details,
    //      offline_payment_id: _paymentTypeList[_selected_payment_method_index]
    //          .offline_payment_id,
   //       isWalletRecharge: widget.isWalletRecharge,
   //       rechargeAmount: widget.rechargeAmount,
   //     );
   //   })).then((value) {
   //     onPopped(value);
   //   });
    }

  }

  pay_by_wallet() async {
    var orderCreateResponse = await PaymentRepository()
        .getOrderCreateResponseFromWallet(
            _selected_payment_method_key, _grandTotalValue, _selected_payment_name);

    if (orderCreateResponse.result == false) {
      ToastComponent.showDialog(orderCreateResponse.message!, gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return OrderList(from_checkout: true);
    }));
  }

  pay_by_cod() async {
    loading();
    var orderCreateResponse = await PaymentRepository()
        .getOrderCreateResponseFromCod(_selected_payment_method_key, _selected_payment_name);
    Navigator.of(loadingcontext!).pop();
    if (orderCreateResponse.result == false) {
      ToastComponent.showDialog(orderCreateResponse.message!, gravity: Toast.center, duration: Toast.lengthLong);
      Navigator.of(context).pop();
      return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return OrderList(from_checkout: true);
    }));
  }

  pay_by_manual_payment() async {
    loading();
    var orderCreateResponse = await PaymentRepository()
        .getOrderCreateResponseFromManualPayment(_selected_payment_method_key, _selected_payment_name, _selected_payment_details[0]);
Navigator.pop(loadingcontext!);
    if (orderCreateResponse.result == false) {
      ToastComponent.showDialog(orderCreateResponse.message!, gravity: Toast.center, duration: Toast.lengthLong);
      Navigator.of(context).pop();
      return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return OrderList(from_checkout: true);
    }));
  }

  onPaymentMethodItemTap(index) {
    if (_selected_payment_method_key !=
        _paymentTypeList[index].payment_type_key) {
      setState(() {
        _selected_payment_method_index = index;
        _selected_payment_method = _paymentTypeList[index].payment_type;
        _selected_payment_method_key = _paymentTypeList[index].payment_type_key;
        _selected_payment_name = _paymentTypeList[index].name;
        _selected_payment_details = _paymentTypeList[index].data;
      });
    }

    //print(_selected_payment_method);
    //print(_selected_payment_method_key);
  }

  onPressDetails() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: EdgeInsets.only(
                  top: 16.0, left: 2.0, right: 2.0, bottom: 2.0),
              content: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 16.0),
                child: Container(
                  height: 150,
                  child: Column(
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 120,
                                child: Text(
                                  AppLocalizations.of(context)!.checkout_screen_subtotal,
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                      color: MyTheme.font_grey,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Spacer(),
                              Text(
                                _subTotalString,
                                style: TextStyle(
                                    color: MyTheme.font_grey,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          )),
                      Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 120,
                                child: Text(
                                  AppLocalizations.of(context)!.checkout_screen_tax,
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                      color: MyTheme.font_grey,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Spacer(),
                              Text(
                                _taxString,
                                style: TextStyle(
                                    color: MyTheme.font_grey,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          )),
                      Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 120,
                                child: Text(
                                  AppLocalizations.of(context)!.checkout_screen_shipping_cost,
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                      color: MyTheme.font_grey,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Spacer(),
                              Text(
                                _shippingCostString,
                                style: TextStyle(
                                    color: MyTheme.font_grey,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          )),
                      Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 120,
                                child: Text(
                                  AppLocalizations.of(context)!.checkout_screen_discount,
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                      color: MyTheme.font_grey,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Spacer(),
                              Text(
                                _discountString,
                                style: TextStyle(
                                    color: MyTheme.font_grey,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          )),
                      Divider(),
                      Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 120,
                                child: Text(
                                  AppLocalizations.of(context)!.checkout_screen_grand_total,
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                      color: MyTheme.font_grey,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Spacer(),
                              Text(
                                _totalString,
                                style: TextStyle(
                                    color: MyTheme.accent_color,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          )),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: Text(
                    AppLocalizations.of(context)!.common_close_in_all_lower,
                    style: TextStyle(color: MyTheme.medium_grey),
                  ),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
              ],
            ),);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: app_language_rtl.$ ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: buildAppBar(context),
          bottomNavigationBar: buildBottomAppBar(context),
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
                          child: buildPaymentMethodList(),
                        ),
                        Container(
                          height: 140,
                        )
                      ]),
                    )
                  ],
                ),
              ),

              //Apply Coupon and order details container
              Align(
                alignment: Alignment.bottomCenter,
                child: widget.isWalletRecharge
                    ? Container()
                    : Container(
                        decoration: BoxDecoration(
                          color: Colors.white,

                          /*border: Border(
                      top: BorderSide(color: MyTheme.light_grey,width: 1.0),
                    )*/
                        ),
                        height:
                            widget.manual_payment_from_order_details ? 80 : 140,
                        //color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              widget.manual_payment_from_order_details == false
                                  ? Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 16.0),
                                      child: buildApplyCouponRow(context),
                                    )
                                  : Container(),
                              grandTotalSection(),

                            ],
                          ),
                        ),
                      ),
              )
            ],
          )),
    );
  }

  Row buildApplyCouponRow(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 42,
          width: (MediaQuery.of(context).size.width - 32) * (2 / 3),
          child: TextFormField(
            controller: _couponController,
            readOnly: _coupon_applied,
            autofocus: false,
            decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.checkout_screen_enter_coupon_code,
                hintStyle:
                    TextStyle(fontSize: 14.0, color: MyTheme.textfield_grey),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: MyTheme.textfield_grey, width: 0.5),
                  borderRadius: const BorderRadius.only(
                    topLeft: const Radius.circular(8.0),
                    bottomLeft: const Radius.circular(8.0),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: MyTheme.medium_grey, width: 0.5),
                  borderRadius: const BorderRadius.only(
                    topLeft: const Radius.circular(8.0),
                    bottomLeft: const Radius.circular(8.0),
                  ),
                ),
                contentPadding: EdgeInsets.only(left: 16.0)),
          ),
        ),
        !_coupon_applied
            ? Container(
                width: (MediaQuery.of(context).size.width - 32) * (1 / 3),
                height: 42,
                child: TextButton(
                  style: TextButton.styleFrom(
                    //minWidth: MediaQuery.of(context).size.width,
                    //height: 50,
                    backgroundColor: MyTheme.accent_color,
                    shape: RoundedRectangleBorder(
                        borderRadius: const BorderRadius.only(
                      topRight: const Radius.circular(8.0),
                      bottomRight: const Radius.circular(8.0),
                    ))
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.checkout_screen_apply_coupon,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    onCouponApply();
                  },
                ),
              )
            : Container(
                width: (MediaQuery.of(context).size.width - 32) * (1 / 3),
                height: 42,
                child: TextButton(
                style: TextButton.styleFrom(
                  //minWidth: MediaQuery.of(context).size.width,
                  //height: 50,
                  backgroundColor: MyTheme.accent_color,
                  shape: RoundedRectangleBorder(
                      borderRadius: const BorderRadius.only(
                    topRight: const Radius.circular(8.0),
                    bottomRight: const Radius.circular(8.0),
                  ))
                ),
                  child: Text(
                    AppLocalizations.of(context)!.checkout_screen_remove,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    onCouponRemove();
                  },
                ),
              )
      ],
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(CupertinoIcons.arrow_left, color: MyTheme.dark_grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Text(
        widget.title!,
        style: TextStyle(fontSize: 16, color: MyTheme.accent_color),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  buildPaymentMethodList() {
    if (_isInitial && _paymentTypeList.length == 0) {
      return SingleChildScrollView(
          child: ShimmerHelper()
              .buildListShimmer(item_count: 5, item_height: 100.0));
    } else if (_paymentTypeList.length > 0) {
      return SingleChildScrollView(
        child: ListView.separated(
          separatorBuilder: (context,index){
            return SizedBox(height: 14,);
          },
          itemCount: _paymentTypeList.length,
          scrollDirection: Axis.vertical,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: buildPaymentMethodItemCard(index),
            );
          },
        ),
      );
    } else if (!_isInitial && _paymentTypeList.length == 0) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            AppLocalizations.of(context)!.common_no_payment_method_added,
            style: TextStyle(color: MyTheme.font_grey),
          )));
    }
  }

  GestureDetector buildPaymentMethodItemCard(index) {
    return GestureDetector(
            onTap: () {
              onPaymentMethodItemTap(index);
            },
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 400),
                  decoration: BoxDecorations.buildBoxDecoration_1().copyWith(
                    border: Border.all(
                        color:_selected_payment_method_key ==
                            _paymentTypeList[index].payment_type_key? MyTheme.accent_color:MyTheme.light_grey,
                        width: _selected_payment_method_key ==
                            _paymentTypeList[index].payment_type_key?2.0:0.0)
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                            width: 100,
                            height: 100,
                            child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child:
                                    /*Image.asset(
                          _paymentTypeList[index].image,
                          fit: BoxFit.fitWidth,
                        ),*/
                                    FadeInImage.assetNetwork(
                                  placeholder: 'assets/placeholder.png',
                                  image: _paymentTypeList[index].payment_type ==
                                          "manual_payment"
                                      ?
                                          _paymentTypeList[index].image
                                      : _paymentTypeList[index].image,
                                  fit: BoxFit.fitWidth,
                                ))),
                        Container(
                          width: 150,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Text(
                                  _paymentTypeList[index].title,
                                  textAlign: TextAlign.left,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: TextStyle(
                                      color: MyTheme.font_grey,
                                      fontSize: 14,
                                      height: 1.6,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]),
                ),
                Positioned(
                  right: 16,
                  top: 16,
                  child: buildPaymentMethodCheckContainer(
                      _selected_payment_method_key ==
                          _paymentTypeList[index].payment_type_key),
                )
              ],
            ),
          );
  }

  Widget buildPaymentMethodCheckContainer(bool check) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 400),
      opacity: check?1:0,
      child: Container(
        height: 16,
        width: 16,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0), color: Colors.green),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: FaIcon(FontAwesomeIcons.check, color: Colors.white, size: 10),
        ),
      ),
    );
     /* Visibility(
      visible: check,
      child: Container(
        height: 16,
        width: 16,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0), color: Colors.green),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: FaIcon(FontAwesomeIcons.check, color: Colors.white, size: 10),
        ),
      ),
    );*/
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
                //minWidth: MediaQuery.of(context).size.width,
                //height: 50,
                backgroundColor: MyTheme.accent_color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0.0),
                )
              ),
              child: Text(
                widget.isWalletRecharge
                    ? AppLocalizations.of(context)!.recharge_wallet_screen_recharge_wallet
                    : widget.manual_payment_from_order_details
                        ? AppLocalizations.of(context)!.common_proceed_in_all_caps
                        : AppLocalizations.of(context)!.checkout_screen_place_my_order,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                onPressPlaceOrderOrProceed();
              },
            )
      ),
    );
  }


  Widget grandTotalSection(){
   return Container(
      height: 40,
      width: double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: MyTheme.soft_accent_color),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            Padding(
              padding:
              const EdgeInsets.only(left: 16.0),
              child: Text(
                AppLocalizations.of(context)!
                    .checkout_screen_total_amount,
                style: TextStyle(
                    color: MyTheme.font_grey,
                    fontSize: 14),
              ),
            ),
            Visibility(
              visible: !widget.manual_payment_from_order_details,
              child: Padding(
                padding:
                const EdgeInsets.only(left: 8.0),
                child: InkWell(
                  onTap: () {
                    onPressDetails();
                  },
                  child: Text(
                    AppLocalizations.of(context)!.common_see_details,
                    style: TextStyle(
                      color: MyTheme.font_grey,
                      fontSize: 12,
                      decoration:
                      TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),
            Spacer(),
            Padding(
              padding:
              const EdgeInsets.only(right: 16.0),
              child: Text(widget.manual_payment_from_order_details?widget.rechargeAmount.toString():_totalString,
                  style: TextStyle(
                      color: MyTheme.accent_color,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  loading() {
    showDialog(
        context: context,
        builder: (context) {
          loadingcontext = context;
          return AlertDialog(
              content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(
                width: 10,
              ),
              Text("${AppLocalizations.of(context)!.loading_text}"),
            ],
          ));
        });
  }
}
