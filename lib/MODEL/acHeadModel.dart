class AcheadModel {
  String? accCode;
  String? accName;
  String? accGroup;
  AcheadModel({this.accCode, this.accName, this.accGroup});
  AcheadModel.fromJson(Map<String, dynamic> json) {
    accCode = json['acc_code'];
    accName = json['acc_name'];
    accGroup = json['acc_group'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['acc_code'] = accCode;
    data['acc_name'] = accName;
    data['acc_group'] = accGroup;
    return data;
  }
}
