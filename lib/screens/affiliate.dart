import 'package:klinikkecantikan/custom/box_decorations.dart';
import 'package:klinikkecantikan/custom/device_info.dart';
import 'package:klinikkecantikan/custom/useful_elements.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:klinikkecantikan/my_theme.dart';
import 'package:klinikkecantikan/app_config.dart';
import 'package:klinikkecantikan/repositories/affiliate_repository.dart';
import 'package:klinikkecantikan/helpers/shimmer_helper.dart';
import 'package:klinikkecantikan/custom/toast_component.dart';
import 'package:klinikkecantikan/screens/wallet.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:klinikkecantikan/helpers/shared_value_helper.dart';

import '../helpers/reg_ex_inpur_formatter.dart';
import '../repositories/affiliate_repository.dart';


class Affiliate extends StatefulWidget {
  @override
  _AffiliateState createState() => _AffiliateState();
}

class _AffiliateState extends State<Affiliate> {
  ScrollController _xcrollController = ScrollController();

  List<dynamic> _list = [];
  List<dynamic> _affiliate_ids = [];
  bool _isInitial = true;
  int _page = 1;
  int _totalData = 0;
  int? balancePoin = 0;
  int? numberklik = 0;
  int? numberitem = 0;
  int? numberdelivered = 0;
  int? numbercancel = 0;
  String? bank = "";
  bool _showLoadingContainer = false;

  //untuk withdraw poin
  TextEditingController _amountController = TextEditingController();
  final _amountValidator = RegExInputFormatter.withRegex(
      '^\$|^(0|([1-9][0-9]{0,}))(\\.[0-9]{0,})?\$');

  //untuk informasi payout atau bank withdraw
  TextEditingController _bankController = TextEditingController();
  TextEditingController _referalKodeController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _referalKodeController.text = referral_code.$ != "" ? referral_code.$ : "";
    fetchInfo();

    fetchData();

    _xcrollController.addListener(() {
      //print("position: " + _xcrollController.position.pixels.toString());
      //print("max: " + _xcrollController.position.maxScrollExtent.toString());

      if (_xcrollController.position.pixels ==
          _xcrollController.position.maxScrollExtent) {
        setState(() {
          _page++;
        });
        _showLoadingContainer = true;
        fetchData();
      }
    });
  }

  fetchInfo() async {
    var affiliateResponse = await AffiliateRepository().getAffiliateInfoResponse();
    numberklik = affiliateResponse.numberklik;
    numberitem = affiliateResponse.numberitem;
    numberdelivered = affiliateResponse.numberdelivered;
    numbercancel = affiliateResponse.numberdelivered;
    balancePoin = affiliateResponse.balance;
    bank = affiliateResponse.bank;
    print("balance: ${affiliateResponse.balance}");


    setState(() {});
  }

  fetchData() async {
    var affiliateResponse = await AffiliateRepository().getAffiliateResponse(page: _page);
    _list.addAll(affiliateResponse.affiliate!);
    _isInitial = false;
    _totalData = affiliateResponse.meta!.total!;
    print("${affiliateResponse.meta!.total}");
    _showLoadingContainer = false;

    setState(() {});
  }

  reset() {
    _list.clear();
    _affiliate_ids.clear();
    _isInitial = true;
    _totalData = 0;
    _page = 1;
    _showLoadingContainer = false;
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

    SnackBar _convertedSnackbar = SnackBar(
      content: Text(
        AppLocalizations.of(context)!.club_point_screen_snackbar_points_converted,
        style: TextStyle(color: MyTheme.font_grey),
      ),
      backgroundColor: MyTheme.soft_accent_color,
      duration: const Duration(seconds: 3),
      action: SnackBarAction(
        label: AppLocalizations.of(context)!.club_point_screen_snackbar_show_wallet,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return Wallet();
          })).then((value) {
            onPopped(value);
          });
        },
        textColor: MyTheme.accent_color,
        disabledTextColor: Colors.grey,
      ),
    );

    return Directionality(
      textDirection: app_language_rtl.$ ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: buildAppBar(context),
        body: Stack(
          children: [
            Container(
                height: DeviceInfo(context).height! / 3.5,
                width: DeviceInfo(context).width!,
                color: MyTheme.accent_color,
                alignment: Alignment.topRight,
                child: Image.asset(
                  "assets/background_1.png",
                )),
            RefreshIndicator(
              color: MyTheme.accent_color,
              backgroundColor: Colors.white,
              onRefresh: _onRefresh,
              displacement: 0,
              child: CustomScrollView(
                controller: _xcrollController,
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  SliverList(
                    delegate: SliverChildListDelegate([
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: buildList(_convertedSnackbar),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
            Align(
                alignment: Alignment.bottomCenter, child: buildLoadingContainer())
          ],
        ),
      ),
    );
  }

  Container buildLoadingContainer() {
    return Container(
      height: _showLoadingContainer ? 36 : 0,
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: Text(_totalData == _list.length
            ? AppLocalizations.of(context)!.common_no_more_items
            : AppLocalizations.of(context)!.common_loading_more_items),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: false,
      leading: Builder(
        builder: (context) => IconButton(
          icon: UsefulElements.backButton(context),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Text(
        "Poin",
        style: TextStyle(fontSize: 16, color: MyTheme.dark_font_grey,fontWeight: FontWeight.bold),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  buildList(_convertedSnackbar) {
   // if (_isInitial && _list.length == 0) {
   //   return SingleChildScrollView(
   //       child: ShimmerHelper()
   //           .buildListShimmer(item_count: 10, item_height: 100.0));
   // } else if (_list.length > 0) {
      return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.0),
              child: buildHorizontalSettings(),
           ),

          Text('Kode Referal Saya:', style: TextStyle(color: Colors.white70),),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.0),
            child: buildHorizontalReferalKode(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.0),
            child: buildCountersRow(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 38.0),
            child: Text(
              "Histori Poin",
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: 16,
                  color: MyTheme.accent_color_shadow,
                  fontWeight: FontWeight.w500),
            ),
          ),
          _isInitial && _list.length == 0 ? ShimmerHelper().buildListShimmer(item_count: 10, item_height: 100.0) :
          _list.length > 0 ? ListView.separated(
            separatorBuilder: (context,index){
              return SizedBox(height:14 ,);
            },
            itemCount: _list.length,
            scrollDirection: Axis.vertical,
            padding: EdgeInsets.all(0.0),
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return buildItemCard(index,_convertedSnackbar);
            },
          ) :
          _totalData == 0 ? Text(AppLocalizations.of(context)!.common_no_data_available)
          :Container()

        ],)
      );
   // } else if (_totalData == 0) {
   //   return Center(child: Text(AppLocalizations.of(context)!.common_no_data_available));
   // } else {
   //   return Container(); // should never be happening
   // }
  }

  Widget buildHorizontalSettings() {
    return Container(
       width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(top: 20,bottom: 20),
      //decoration: BoxDecorations.buildBoxDecoration_1(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: DeviceInfo(context).width!/3,
            height: 60,
            decoration: BoxDecorations.buildBoxDecoration_1().copyWith(
              color: MyTheme.accent_color,
              borderRadius: BorderRadius.circular(8),
              // border:
              // Border.all(color: Color.fromRGBO(112, 112, 112, .3), width: 1),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    "$balancePoin",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    "Balance Poin",
                    style: TextStyle(
                      color: MyTheme.light_grey,
                      fontSize: 10,

                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              buildShowAddPayoutFormDialog(context);
            },
            child: Column(
              children: [
                Image.asset(
                  "assets/wallet.png",
                  height: 26,
                  width: 26,
                  color: MyTheme.white,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "Payout",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12,
                      color: MyTheme.white,
                      fontWeight: FontWeight.w500),
                )
              ],
            ),
          ),
          InkWell(
            onTap: () {
              buildShowAddWithdrawFormDialog(context);
            },
            child: Column(
              children: [
                Image.asset(
                  "assets/add.png",
                  height: 26,
                  width: 26,
                  color: MyTheme.white,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "Penarikan",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12,
                      color: MyTheme.white,
                      fontWeight: FontWeight.w500),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget buildHorizontalReferalKode() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(top: 20,bottom: 20),
      //decoration: BoxDecorations.buildBoxDecoration_1(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child:
            TextField(
              controller: _referalKodeController,
              readOnly: true,
             // decoration: new InputDecoration(
             //     border:OutlineInputBorder(
             //         borderSide: BorderSide(
             //           color: Colors.white,
             //           style: BorderStyle.solid,
             //           width: 1
             //         )
             //     ),
             //     hintText: "Kode referral anda:"),
              style: TextStyle(
                color: Colors.white
              ),
            )
          ),
          ElevatedButton(
              onPressed: (){
                final data = ClipboardData(text:_referalKodeController.text);
                Clipboard.setData(data);
              },
              child: Text('copy')
          )
        ],
      ),
    );
  }

  Widget buildCountersRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildCountersRowItem(
          "$numberklik",
          "Klik",
        ),
        buildCountersRowItem(
          "$numberitem",
          "Produk",
        ),
        buildCountersRowItem(
          "$numberdelivered",
          "Order",
        ),
        buildCountersRowItem(
          "$numbercancel",
          "Batal",
        ),
      ],
    );
  }
  Widget buildItemCard(index,_convertedSnackbar) {
    return Container(
      decoration: BoxDecorations.buildBoxDecoration_1(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            Container(
                width: DeviceInfo(context).width!/2.5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order Kode: ${_list[index].orderCode}",
                      style: TextStyle(
                        color: MyTheme.dark_font_grey,
                        fontSize: 13,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Referal: ${_list[index].user_name}",
                      style: TextStyle(
                          color: MyTheme.dark_font_grey,
                          fontSize: 13,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),

                    Row(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.common_date+" : ",
                          style: TextStyle(
                            fontSize: 12,
                            color:  MyTheme.dark_font_grey,
                          ),
                        ),
                        Text(
                          _list[index].date,
                          style: TextStyle(
                            fontSize: 12,
                            color: MyTheme.dark_font_grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                )),
            Container(
              //color: Colors.red,
                width: DeviceInfo(context).width!/2.5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,

                  children: [
                    Text(
                      "${_list[index].amount.toString()} Poin",
                      style: TextStyle(
                          color: MyTheme.accent_color,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "${_list[index].product_name.toString()}",
                      style: TextStyle(
                          color: MyTheme.accent_color,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget buildCountersRowItem(String counter, String title) {
    return Container(
      margin: EdgeInsets.only(top: 20),
      padding: EdgeInsets.symmetric(vertical: 14),
      width: DeviceInfo(context).width! / 5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: MyTheme.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            counter,
            maxLines: 2,
            style: TextStyle(
                fontSize: 16,
                color: MyTheme.dark_font_grey,
                fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            title,
            maxLines: 2,
            style: TextStyle(
              color: MyTheme.dark_font_grey,
            ),
          ),
        ],
      ),
    );
  }

  onPressProceed() async{
    var amount_String = _amountController.text.toString();

    if(amount_String == ""){
      ToastComponent.showDialog( AppLocalizations.of(context)!.wallet_screen_amount_warning, gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    var amount = double.parse(amount_String);
    var payoutInfoResponse = await AffiliateRepository().updateWithdrawalResponse(amount:amount);
    if (payoutInfoResponse.result == false) {
      ToastComponent.showDialog(payoutInfoResponse.message!, gravity: Toast.center,
          duration: Toast.lengthLong);
    }else{
      Navigator.of(context, rootNavigator: true).pop();
    }

  }
  Future buildShowAddWithdrawFormDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (_) => Directionality(
          textDirection: app_language_rtl.$ ? TextDirection.rtl : TextDirection.ltr,
          child: AlertDialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 10),
            contentPadding: EdgeInsets.only(
                top: 36.0, left: 36.0, right: 36.0, bottom: 2.0),
            content: Container(
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Padding(
                      padding: const EdgeInsets.only(top:8.0,bottom: 8.0),
                      child: Text( "Masukkan jumlah poin yang akan di cairkan ke rekening anda",
                          style: TextStyle(
                              color: MyTheme.dark_font_grey, fontSize: 13,fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Container(
                        height: 40,
                        child: TextField(
                          controller: _amountController,
                          autofocus: false,
                          keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [_amountValidator],
                          decoration: InputDecoration(
                              fillColor: MyTheme.light_grey,
                              filled: true,
                              hintText:  AppLocalizations.of(context)!.wallet_screen_enter_amount,
                              hintStyle: TextStyle(
                                  fontSize: 12.0,
                                  color: MyTheme.textfield_grey),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: MyTheme.noColor,
                                    width: 0.0),
                                borderRadius: const BorderRadius.all(
                                  const Radius.circular(8.0),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: MyTheme.noColor,
                                    width:0.0),
                                borderRadius: const BorderRadius.all(
                                  const Radius.circular(8.0),
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 8.0)),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text("Withdrawal poin membutuhkan waktu 3hari herja",
                          style: TextStyle(
                              color: MyTheme.accent_color, fontSize: 10,fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextButton(

                      style: TextButton.styleFrom(
                        //minWidth: 75,
                        //height: 30,
                          minimumSize:  Size(75, 30),
                          backgroundColor: Color.fromRGBO(253, 253, 253, 1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6.0),
                              side: BorderSide(
                                  color: MyTheme.accent_color, width: 1.0))
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.common_close_ucfirst,
                        style: TextStyle(

                          fontSize: 10,
                          color: MyTheme.accent_color,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                    ),
                  ),
                  SizedBox(
                    width: 1,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: TextButton(

                      style: TextButton.styleFrom(
                          minimumSize:  Size(75, 30),
                          backgroundColor: MyTheme.accent_color,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.0),)
                      ),
                      child: Text(
                        "${AppLocalizations.of(context)!.common_proceed} Sekarang",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.normal),
                      ),
                      onPressed: () {
                        onPressProceed();
                      },
                    ),
                  )
                ],
              )
            ],
          ),
        ));
  }

  onPressConfigurePayout() async{
    var bank_String = _bankController.text.toString();

    if(bank_String == ""){
      ToastComponent.showDialog( AppLocalizations.of(context)!.wallet_screen_amount_warning, gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }
    //repo
    var payoutInfoResponse = await AffiliateRepository().updateInfoPayoutResponse(bank:bank_String);
    if (payoutInfoResponse.result == false) {
      ToastComponent.showDialog(payoutInfoResponse.message!, gravity: Toast.center,
          duration: Toast.lengthLong);
    }else{
      Navigator.of(context, rootNavigator: true).pop();
    }

  }
  Future buildShowAddPayoutFormDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (_) => Directionality(
          textDirection: app_language_rtl.$ ? TextDirection.rtl : TextDirection.ltr,
          child: AlertDialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 10),
            contentPadding: EdgeInsets.only(
                top: 36.0, left: 36.0, right: 36.0, bottom: 2.0),
            content: Container(
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Padding(
                      padding: const EdgeInsets.only(top:8.0,bottom: 8.0),
                      child: Text( "Setting Informasi Bank",
                          style: TextStyle(
                              color: MyTheme.dark_font_grey, fontSize: 13,fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Container(
                        //height: 40,
                        child: TextField(
                          controller: _bankController,
                          minLines: 3,
                          maxLines: 5,
                          autofocus: false,
                          decoration: InputDecoration(
                              fillColor: MyTheme.light_grey,
                              filled: true,
                              hintText: "Nama Bank, Nama Pemilik Rekening, Nomor Rekening,",
                              hintStyle: TextStyle(
                                  fontSize: 12.0,
                                  color: MyTheme.textfield_grey),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: MyTheme.noColor,
                                    width: 0.0),
                                borderRadius: const BorderRadius.all(
                                  const Radius.circular(8.0),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: MyTheme.noColor,
                                    width:0.0),
                                borderRadius: const BorderRadius.all(
                                  const Radius.circular(8.0),
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 8.0)),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text("Silahkan isi Informasi Bank Anda untuk withdraw",
                          style: TextStyle(
                              color: MyTheme.accent_color, fontSize: 10,fontWeight: FontWeight.bold)),
                    ),

                    bank!.isNotEmpty ? Padding(
                      padding: const EdgeInsets.only(top:8.0,bottom: 8.0),
                      child: Text("info payout anda: $bank",
                          style: TextStyle(
                              color: MyTheme.dark_font_grey, fontSize: 13,fontWeight: FontWeight.bold)),
                    ):Container(),

                  ],
                ),
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextButton(

                      style: TextButton.styleFrom(
                        //minWidth: 75,
                        //height: 30,
                          minimumSize:  Size(75, 30),
                          backgroundColor: Color.fromRGBO(253, 253, 253, 1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6.0),
                              side: BorderSide(
                                  color: MyTheme.accent_color, width: 1.0))
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.common_close_ucfirst,
                        style: TextStyle(
                          fontSize: 10,
                          color: MyTheme.accent_color,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                    ),
                  ),
                  SizedBox(
                    width: 1,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: TextButton(

                      style: TextButton.styleFrom(
                          minimumSize:  Size(75, 30),
                          backgroundColor: MyTheme.accent_color,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.0),)
                      ),
                      child: Text(
                        "${AppLocalizations.of(context)!.common_proceed} Sekarang",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.normal),
                      ),
                      onPressed: () {
                        onPressConfigurePayout();
                      },
                    ),
                  )
                ],
              )
            ],
          ),
        ));
  }

}
