class LoginModel {
  String? msg;
  int? flag;
  String? br_val_id;
  String? sesn_id;
  String? user_id;
  String? user_printNM;
  int? user_typ;
  String? com_id;
  String? br_id;
  String? com_name;
  int? com_state;
  String? com_gst;
  LoginModel(
      {this.msg,
      this.flag,
      this.br_val_id,
      this.sesn_id,
      this.user_id,
      this.user_printNM,
      this.user_typ,
      this.com_id,
      this.br_id,
      this.com_name,
      this.com_state,
      this.com_gst});
  LoginModel.fromJson(Map<String, dynamic> json) {
    msg = json['msg'];
    flag = json['flag'];
    br_val_id = json['branch_validate_id'];
    sesn_id = json['session_id'];
    user_id = json['user_id'];
    user_printNM = json['user_print_name'];
    user_typ = json['user_type'];
    com_id = json['company_id'];
    br_id = json['branch_id'];
    com_name = json['company_name'];
    com_state = json['company_state'];
    com_gst = json['company_GSTIN'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['msg'] = msg;
    data['flag'] = flag;
    data['branch_validate_id'] = br_val_id;
    data['session_id'] = sesn_id;
    data['user_id'] = user_id;
    data['user_print_name'] = user_printNM;
    data['user_type'] = user_typ;
    data['company_id'] = com_id;
    data['branch_id'] = br_id;
    data['company_name'] = com_name;
    data['company_state'] = com_state;
    data['company_GSTIN'] = com_gst;
    return data;
  }
}
