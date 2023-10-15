import 'package:klinikkecantikan/custom/box_decorations.dart';
import 'package:klinikkecantikan/custom/device_info.dart';
import 'package:klinikkecantikan/custom/lang_text.dart';
import 'package:klinikkecantikan/custom/toast_component.dart';
import 'package:klinikkecantikan/custom/useful_elements.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:klinikkecantikan/my_theme.dart';
import 'package:klinikkecantikan/ui_elements/product_card.dart';
import 'package:klinikkecantikan/repositories/product_repository.dart';
import 'package:klinikkecantikan/helpers/shimmer_helper.dart';
import 'package:klinikkecantikan/helpers/string_helper.dart';
import 'package:klinikkecantikan/helpers/shared_value_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:toast/toast.dart';

import '../helpers/flutter_html/flutter_html.dart';

class BlogDetail extends StatefulWidget {
  BlogDetail(
      {Key? key,
        this.id,
        this.title,
        this.short,
        this.deskripsi,
        this.bannerUrl})
      : super(key: key);

  final int? id;
  final String? bannerUrl;
  final String? title;
  final String? short;
  final String? deskripsi;

  @override
  _BlogDetailState createState() => _BlogDetailState();
}

class _BlogDetailState extends State<BlogDetail> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: app_language_rtl.$ ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: buildAppBar(context),
        body: buildList(context),
      ),
    );
  }

  bool shouldProductBoxBeVisible(product_name, search_key) {
    if (search_key == "") {
      return true; //do not check if the search key is empty
    }
    return StringHelper().stringContains(product_name, search_key);
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      toolbarHeight: 75,
      leading: Builder(
        builder: (context) => IconButton(
          icon: UsefulElements.backButton(context),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  buildList(context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 18),
            child: Text(
              widget.title!,
              style: TextStyle(
                  color: MyTheme.font_grey,
                  fontSize: 18,
                  height: 1.2,
                  fontWeight: FontWeight.w700),
            ),
          ),
          buildBanner(),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 18, 16, 18),
            child: Text(
              widget.short!,
              style: TextStyle(
                  color: MyTheme.font_grey,
                  fontSize: 14,
                  height: 1.2,
                  fontWeight: FontWeight.w700),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
            child:
            Html(data: widget.deskripsi!),

          ),
        ],
      ),
    );

  }

  Container buildBanner() {
    return Container(
      child: FadeInImage.assetNetwork(
        placeholder: 'assets/placeholder_rectangle.png',
        image: widget.bannerUrl!,
        fit: BoxFit.cover,
        width: DeviceInfo(context).width!,
        height: 180,
      ),
    );
  }

  Widget buildBannerShimmer() {
    return ShimmerHelper().buildBasicShimmerCustomRadius(
        width: DeviceInfo(context).width!,
        height: 180,
        color: MyTheme.medium_grey_50
    );
  }
}
