import 'dart:convert';

BlogResponse blogResponseFromJson(String? str) => BlogResponse.fromJson(json.decode(str!));

String? blogResponseToJson(BlogResponse data) => json.encode(data.toJson());

class BlogResponse {
  BlogResponse({
    this.blogs,
    this.meta,
    this.success,
    this.status,
  });

  List<Blogs>? blogs;
  Meta? meta;
  bool? success;
  int? status;

  factory BlogResponse.fromJson(Map<String, dynamic> json) => BlogResponse(
    blogs: List<Blogs>.from(json["data"].map((x) => Blogs.fromJson(x))),
    meta: json["meta"] == null ? null : Meta.fromJson(json["meta"]),
    success: json["success"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(blogs!.map((x) => x.toJson())),
    "meta": meta == null ? null : meta!.toJson(),
    "success": success,
    "status": status,
  };
}

class Blogs {
  Blogs({
    this.id,
    this.title,
    this.short_description,
    this.description,
    this.banner,
    this.created_at,
    this.updated_at
  });

  int? id;
  String? title;
  String? short_description;
  String? description;
  String? banner;
  String? created_at;
  String? updated_at;

  factory Blogs.fromJson(Map<String, dynamic> json) => Blogs(
      title: json["title"],
      short_description:json["short_description"],
      description: json["description"],
      id: json["id"],
      banner: json["banner"],
      created_at: json["created_at"],
      updated_at: json["updated_at"]
  );

  Map<String, dynamic> toJson() => {
    "name": title,
    "short_description":short_description,
    "description":description,
    "id": id,
    "banner": banner,
    "created_at":created_at,
    "updated_at":updated_at
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
