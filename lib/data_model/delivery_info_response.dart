// To parse this JSON data, do
//
//     final deliveryInfoResponse = deliveryInfoResponseFromJson(jsonString);

import 'dart:convert';

List<DeliveryInfoResponse> deliveryInfoResponseFromJson(String? str) => List<DeliveryInfoResponse>.from(json.decode(str!).map((x) => DeliveryInfoResponse.fromJson(x)));

String? deliveryInfoResponseToJson(List<DeliveryInfoResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DeliveryInfoResponse {
  DeliveryInfoResponse({
    this.name,
    this.ownerId,
    this.cartItems,
    this.carriers,
    this.pickupPoints,
    this.origin,
  });

  String? name;
  var ownerId;
  List<CartItem>? cartItems;
  Carriers? carriers;
  List<PickupPoint>? pickupPoints;
  var origin;

  factory DeliveryInfoResponse.fromJson(Map<String, dynamic> json) => DeliveryInfoResponse(
    name: json["name"],
    ownerId: json["owner_id"],
    cartItems: List<CartItem>.from(json["cart_items"].map((x) => CartItem.fromJson(x))),
    carriers: Carriers.fromJson(json["carriers"]),
    pickupPoints: List<PickupPoint>.from(json["pickup_points"].map((x) => PickupPoint.fromJson(x))),
    origin: json["origin"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "owner_id": ownerId,
    "cart_items": List<dynamic>.from(cartItems!.map((x) => x.toJson())),
    "carriers": carriers!.toJson(),
    "pickup_points": List<dynamic>.from(pickupPoints!.map((x) => x.toJson())),
    "origin": origin,
  };
}

class Carriers {
  Carriers({
    this.data,
  });

  List<Datum>? data;

  factory Carriers.fromJson(Map<String, dynamic> json) => Carriers(
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  Datum({
    this.id,
    this.name,
    this.kode,
    this.service,
    this.logo,
    this.transitTime,
    this.freeShipping,
    this.transitPrice,
  });

  var id;
  String? name;
  String? kode;
  String? service;
  String? logo;
  var transitTime;
  bool? freeShipping;
  String? transitPrice;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    name: json["name"],
    kode: json["kode"],
    service: json["service"],
    logo: json["logo"],
    transitTime: json["transit_time"],
    freeShipping: json["free_shipping"],
    transitPrice: json["transit_price"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "kode": kode,
    "service": service,
    "logo": logo,
    "transit_time": transitTime,
    "free_shipping": freeShipping,
    "transit_price": transitPrice,
  };
}

class CartItem {
  CartItem({
    this.id,
    this.ownerId,
    this.userId,
    this.productId,
    this.productName,
    this.productThumbnailImage,
    this.quantity,
    this.weight,
  });

  var id;
  var ownerId;
  var userId;
  var productId;
  String? productName;
  String? productThumbnailImage;
  var quantity;
  var weight;

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    id: json["id"],
    ownerId: json["owner_id"],
    userId: json["user_id"],
    productId: json["product_id"],
    productName: json["product_name"],
    productThumbnailImage: json["product_thumbnail_image"],
    quantity: json["quantity"],
    weight: json["weight"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "owner_id": ownerId,
    "user_id": userId,
    "product_id": productId,
    "product_name": productName,
    "product_thumbnail_image": productThumbnailImage,
    "quantity": quantity,
    "weight": weight,
  };
}

class PickupPoint {
  PickupPoint({
    this.id,
    this.staffId,
    this.name,
    this.address,
    this.phone,
    this.pickUpStatus,
    this.cashOnPickupStatus,
  });

  var id;
  var staffId;
  String? name;
  String? address;
  String? phone;
  var pickUpStatus;
  dynamic cashOnPickupStatus;

  factory PickupPoint.fromJson(Map<String, dynamic> json) => PickupPoint(
    id: json["id"],
    staffId: json["staff_id"],
    name: json["name"],
    address: json["address"],
    phone: json["phone"],
    pickUpStatus: json["pick_up_status"],
    cashOnPickupStatus: json["cash_on_pickup_status"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "staff_id": staffId,
    "name": name,
    "address": address,
    "phone": phone,
    "pick_up_status": pickUpStatus,
    "cash_on_pickup_status": cashOnPickupStatus,
  };
}
