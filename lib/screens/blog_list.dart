import 'package:klinikkecantikan/custom/device_info.dart';
import 'package:klinikkecantikan/custom/useful_elements.dart';
import 'package:klinikkecantikan/data_model/blog_response.dart';
import 'package:klinikkecantikan/helpers/shimmer_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:klinikkecantikan/my_theme.dart';
import 'package:klinikkecantikan/helpers/shared_value_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:async';

import '../custom/box_decorations.dart';
import '../repositories/blog_repository.dart';
import 'blog_detail.dart';

class BlogList extends StatefulWidget {
  @override
  _BlogListState createState() => _BlogListState();
}

class _BlogListState extends State<BlogList> {

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: app_language_rtl.$ ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: buildAppBar(context),
        body: buildList(context),
      ),
    );
  }

  Widget buildList(context) {
    return FutureBuilder<BlogResponse>(
        future: BlogRepository().getBlogs(),
        builder: (context,AsyncSnapshot<BlogResponse> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Network Error!"),);
          }else
          if (snapshot.hasData) {
            BlogResponse response = snapshot.data!;
            return SingleChildScrollView(
              child: ListView.separated(
                padding: const EdgeInsets.all(0),
                separatorBuilder: (context, index) {
                  return SizedBox(
                    width: 14,
                  );
                },
                itemCount: response.blogs!.length,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return buildListItem(response, index);
                },
              ),
            );
          } else {
            return buildShimmer();
          }
        });
  }

  CustomScrollView buildShimmer() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ListView.separated(
            separatorBuilder: (context, index) {
              return SizedBox(
                height: 20,
              );
            },
            itemCount: 20,
            scrollDirection: Axis.vertical,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return buildBannerShimmer();
            },
          ),
        )
      ],
    );
  }
  buildListItem(BlogResponse response, index) {
    return Container(
      width: DeviceInfo(context).width!,
      decoration: BoxDecorations.buildBoxDecoration_1().copyWith(),
      child:GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return BlogDetail(
                id: response.blogs![index].id,
                title: response.blogs![index].title,
                bannerUrl: response.blogs![index].banner,
                short: response.blogs![index].short_description,
                deskripsi: response.blogs![index].description,
              );
            }));
          },
          child:Stack(children: [ Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildBanner( response, index),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(
                  response.blogs![index].title!,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                      color: MyTheme.font_grey,
                      fontSize: 14,
                      height: 1.2,
                      fontWeight: FontWeight.w700),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Text(
                  response.blogs![index].short_description!,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(
                      color: MyTheme.font_grey,
                      fontSize: 14,
                      height: 1.2,
                      fontWeight: FontWeight.w400),
                ),
              ),
            ],
          ),],)
      ),
    );
  }

  Container buildBanner(response, index) {
    return Container(
      child: FadeInImage.assetNetwork(
        placeholder: 'assets/placeholder_rectangle.png',
        image: response.blogs[index].banner,
        fit: BoxFit.fitWidth,
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

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: false,
      leading: Builder(
        builder: (context) => IconButton(
          icon: UsefulElements.backButton(context, color: "white"),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Text(
        "Berita",
        style: TextStyle(fontSize: 16, color: MyTheme.white,fontWeight: FontWeight.bold),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }
}
