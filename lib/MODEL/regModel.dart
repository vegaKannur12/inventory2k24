class RegisterModel {
  String? msg;
  int? flag;
  String? com_id;
  String? com_name;
  String? reg_key;
  String? api_path;
  RegisterModel(
      {this.msg,
      this.flag,
      this.com_id,
      this.com_name,
      this.reg_key,
      this.api_path});
  RegisterModel.fromJson(Map<String, dynamic> json) {
    msg = json['msg'];
    flag = json['flag'];
    com_id = json['company_id'];
    com_name = json['company_name'];
    reg_key = json['reg_key'];
    api_path = json['api_path'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['msg'] = msg;
    data['flag'] = flag;
    data['company_id'] = com_id;
    data['company_name'] = com_name;
    data['reg_key'] = reg_key;
    data['api_path'] = api_path;
    return data;
  }
}
