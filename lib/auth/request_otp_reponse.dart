class RequestOTPResponse {
  String? id;
  String? createdAt;
  String? updatedAt;
  String? phone;
  String? nonce;

  RequestOTPResponse(
      {this.id,
      this.createdAt,
      this.updatedAt,
      this.phone,
      this.nonce});

  RequestOTPResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    phone = json['phone'];
    nonce = json['nonce'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['phone'] = this.phone;
    data['nonce'] = this.nonce;
    return data;
  }
}
