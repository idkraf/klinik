// To parse this JSON data, do
//
//     final clubpointResponse = clubpointResponseFromJson(jsonString);

import 'dart:convert';

AffiliateResponse affiliateResponseFromJson(String? str) => AffiliateResponse.fromJson(json.decode(str!));

String? affiliateResponseToJson(AffiliateResponse data) => json.encode(data.toJson());

class AffiliateResponse {
  AffiliateResponse({
    this.affiliate,
    this.links,
    this.meta,
    this.success,
    this.status,
  });

  List<AffiliateModel>? affiliate;
  Links? links;
  Meta? meta;
  bool? success;
  int? status;

  factory AffiliateResponse.fromJson(Map<String, dynamic> json) => AffiliateResponse(
    affiliate: List<AffiliateModel>.from(json["data"].map((x) => AffiliateModel.fromJson(x))),
    links: Links.fromJson(json["links"]),
    meta: Meta.fromJson(json["meta"]),
    success: json["success"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(affiliate!.map((x) => x.toJson())),
    "links": links!.toJson(),
    "meta": meta!.toJson(),
    "success": success,
    "status": status,
  };
}

class AffiliateModel {
  AffiliateModel({
    this.id,
    this.user_id,
    this.user_name,
    this.product_name,
    this.orderCode,
    this.amount,
    this.date,
  });

  int? id;
  int? user_id;
  var orderCode;
  String? user_name;
  String? product_name;
  double? amount;
  String? date;

  factory AffiliateModel.fromJson(Map<String, dynamic> json) => AffiliateModel(
    id: json["id"],
    user_id: json["user_id"],
    orderCode: json["order_code"],
    user_name: json["user_name"],
    product_name: json["product_name"],
    amount: json["amount"].toDouble(),
    date: json["date"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": user_id,
    "order_code": orderCode,
    "user_name": user_name,
    "product_name": product_name,
    "amount": amount,
    "date": date,
  };
}

class Links {
  Links({
    this.first,
    this.last,
    this.prev,
    this.next,
  });

  String? first;
  String? last;
  dynamic prev;
  String? next;

  factory Links.fromJson(Map<String, dynamic> json) => Links(
    first: json["first"],
    last: json["last"],
    prev: json["prev"],
    next: json["next"],
  );

  Map<String, dynamic> toJson() => {
    "first": first,
    "last": last,
    "prev": prev,
    "next": next,
  };
}

class Meta {
  Meta({
    this.currentPage,
    this.from,
    this.lastPage,
    this.path,
    this.perPage,
    this.to,
    this.total,
  });

  int? currentPage;
  int? from;
  int? lastPage;
  String? path;
  int? perPage;
  int? to;
  int? total;

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
    currentPage: json["current_page"],
    from: json["from"],
    lastPage: json["last_page"],
    path: json["path"],
    perPage: json["per_page"],
    to: json["to"],
    total: json["total"],
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "from": from,
    "last_page": lastPage,
    "path": path,
    "per_page": perPage,
    "to": to,
    "total": total,
  };
}
