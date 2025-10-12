
class OrderItem {
  int? id;
  int? menuItemId;
  String name;
  int num;

  OrderItem({this.id, this.menuItemId, required this.name, this.num = 1});

  OrderItem.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        name = res["item_name"],
        num = res["num"];

}